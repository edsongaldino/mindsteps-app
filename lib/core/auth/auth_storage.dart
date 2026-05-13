import 'package:shared_preferences/shared_preferences.dart';

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

  static Future<void> limpar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}