import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'biometric_service.dart';

class AuthStorage {

  static Future<void> salvarToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<String?> obterToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> salvarPerfil(String perfil) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('perfil', perfil);
  }

  static Future<String?> obterPerfil() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('perfil');
  }

  static Future<void> salvarAprovado(bool aprovado) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('aprovado', aprovado);
  }

  static Future<bool> obterAprovado() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('aprovado') ?? true;
  }

  static Future<void> salvarCredenciaisLembradas(String email, String senha) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('lembrar_acesso', true);
    await prefs.setString('lembrar_email', email);
    try {
      const secureStorage = FlutterSecureStorage();
      await secureStorage.write(key: 'lembrar_senha', value: senha);
    } catch (_) {
      await prefs.setString('lembrar_senha_fallback', senha);
    }
  }

  static Future<Map<String, String>?> obterCredenciaisLembradas() async {
    final prefs = await SharedPreferences.getInstance();
    final lembrar = prefs.getBool('lembrar_acesso') ?? false;
    if (!lembrar) return null;

    final email = prefs.getString('lembrar_email');
    String? senha;
    try {
      const secureStorage = FlutterSecureStorage();
      senha = await secureStorage.read(key: 'lembrar_senha');
    } catch (_) {}
    senha ??= prefs.getString('lembrar_senha_fallback');

    if (email != null && email.isNotEmpty) {
      return {'email': email, 'senha': senha ?? ''};
    }
    return null;
  }

  static Future<void> limparCredenciaisLembradas() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('lembrar_acesso');
    await prefs.remove('lembrar_email');
    await prefs.remove('lembrar_senha_fallback');
    try {
      const secureStorage = FlutterSecureStorage();
      await secureStorage.delete(key: 'lembrar_senha');
    } catch (_) {}
  }

  static Future<void> limpar({bool manterCredenciaisLembradas = true}) async {
    final prefs = await SharedPreferences.getInstance();
    final lembrar = prefs.getBool('lembrar_acesso') ?? false;
    final email = prefs.getString('lembrar_email');
    final senhaFallback = prefs.getString('lembrar_senha_fallback');

    await BiometricService().clearCredentials();
    await prefs.clear();

    if (manterCredenciaisLembradas && lembrar) {
      await prefs.setBool('lembrar_acesso', true);
      if (email != null) await prefs.setString('lembrar_email', email);
      if (senhaFallback != null) await prefs.setString('lembrar_senha_fallback', senhaFallback);
    }
  }
}