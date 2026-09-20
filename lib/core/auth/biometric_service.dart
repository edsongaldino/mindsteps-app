import 'dart:io';
import 'dart:developer' as developer;

import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  // iOS: accessibility first_unlock faz as chaves ficarem acessiveis apos
  // reinicializacao do dispositivo e sobreviverem a reinstalacao do app.
  FlutterSecureStorage get _secureStorage => Platform.isIOS
      ? const FlutterSecureStorage(
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock,
          ),
        )
      : const FlutterSecureStorage();

  static const String _biometricEnabledKey = 'biometric_enabled_flag';
  static const String _secEmailKey = 'biometric_email_key';
  static const String _secPasswordKey = 'biometric_password_key';

  /// Verifica se o dispositivo suporta biometria REAL (face ou digital)
  /// cadastrada. Retorna false se apenas PIN/padrao estiver configurado.
  Future<bool> isBiometricAvailable() async {
    try {
      final bool isSupported = await _localAuth.isDeviceSupported();
      if (!isSupported) return false;
      // canCheckBiometrics so e true quando ha biometria CADASTRADA (face/digital)
      final bool canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) return false;
      // Verifica se ha algum tipo de biometria disponivel
      final List<BiometricType> available = await _localAuth.getAvailableBiometrics();
      return available.isNotEmpty;
    } catch (e) {
      developer.log('BiometricService.isBiometricAvailable error: $e');
      return false;
    }
  }

  /// Retorna os tipos de biometria disponiveis no aparelho.
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      developer.log('BiometricService.getAvailableBiometrics error: $e');
      return [];
    }
  }

  /// Retorna true se o dispositivo possui Face ID / reconhecimento facial.
  Future<bool> hasFaceId() async {
    try {
      final biometrics = await _localAuth.getAvailableBiometrics();
      return biometrics.contains(BiometricType.face);
    } catch (e) {
      developer.log('BiometricService.hasFaceId error: $e');
      return false;
    }
  }

  /// Executa o prompt de autenticacao (Face ID / Touch ID).
  /// biometricOnly: true para garantir que apenas biometria seja aceita
  /// (evita fallback para PIN que confunde usuarios que esperam face scan).
  /// Em caso de falha por biometria nao cadastrada, retorna false graciosamente.
  Future<bool> authenticate() async {
    try {
      final result = await _localAuth.authenticate(
        localizedReason: 'Use o Face ID ou sua digital para entrar no MindSteps',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
          useErrorDialogs: true,
        ),
      );
      developer.log('BiometricService.authenticate result: $result');
      return result;
    } catch (e) {
      developer.log('BiometricService.authenticate error: $e');
      return false;
    }
  }

  /// Salva email e senha criptografados no Keychain (iOS) ou Keystore (Android).
  Future<void> saveCredentials(String email, String password) async {
    try {
      await _secureStorage.write(key: _secEmailKey, value: email);
      await _secureStorage.write(key: _secPasswordKey, value: password);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_biometricEnabledKey, true);
      developer.log('BiometricService: credentials saved');
    } catch (e) {
      developer.log('BiometricService.saveCredentials error: $e');
      rethrow;
    }
  }

  /// Retorna as credenciais salvas, ou null se nao existirem.
  Future<Map<String, String>?> getSavedCredentials() async {
    try {
      final email = await _secureStorage.read(key: _secEmailKey);
      final password = await _secureStorage.read(key: _secPasswordKey);
      if (email != null && email.isNotEmpty && password != null && password.isNotEmpty) {
        return {'email': email, 'senha': password};
      }
      return null;
    } catch (e) {
      developer.log('BiometricService.getSavedCredentials error: $e');
      return null;
    }
  }

  /// Remove credenciais e desabilita a biometria.
  Future<void> clearCredentials() async {
    try {
      await _secureStorage.delete(key: _secEmailKey);
      await _secureStorage.delete(key: _secPasswordKey);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_biometricEnabledKey, false);
    } catch (e) {
      developer.log('BiometricService.clearCredentials error: $e');
    }
  }

  /// Verifica se a biometria foi habilitada pelo usuario E as credenciais existem.
  Future<bool> isBiometricEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isFlagEnabled = prefs.getBool(_biometricEnabledKey) ?? false;
      if (!isFlagEnabled) return false;
      final credentials = await getSavedCredentials();
      final isEnabled = credentials != null;
      developer.log('BiometricService.isBiometricEnabled: $isEnabled');
      return isEnabled;
    } catch (e) {
      developer.log('BiometricService.isBiometricEnabled error: $e');
      return false;
    }
  }
}