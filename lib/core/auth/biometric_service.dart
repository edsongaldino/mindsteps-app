import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _biometricEnabledKey = 'biometric_enabled_flag';
  static const String _secEmailKey = 'biometric_email_key';
  static const String _secPasswordKey = 'biometric_password_key';

  Future<bool> isBiometricAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
      if (!canAuthenticate) return false;

      final List<BiometricType> availableBiometrics = await _localAuth.getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Autentique-se para entrar no MindSteps',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  Future<void> saveCredentials(String email, String password) async {
    await _secureStorage.write(key: _secEmailKey, value: email);
    await _secureStorage.write(key: _secPasswordKey, value: password);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, true);
  }

  Future<Map<String, String>?> getSavedCredentials() async {
    final email = await _secureStorage.read(key: _secEmailKey);
    final password = await _secureStorage.read(key: _secPasswordKey);

    if (email != null && password != null) {
      return {'email': email, 'senha': password};
    }
    return null;
  }

  Future<void> clearCredentials() async {
    await _secureStorage.delete(key: _secEmailKey);
    await _secureStorage.delete(key: _secPasswordKey);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, false);
  }

  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    final isFlagEnabled = prefs.getBool(_biometricEnabledKey) ?? false;
    if (!isFlagEnabled) return false;

    // Double check if credentials exist
    final credentials = await getSavedCredentials();
    return credentials != null;
  }
}
