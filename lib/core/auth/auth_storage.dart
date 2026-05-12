import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  static const _storage = FlutterSecureStorage();

  static Future<void> salvarToken(String token) async {
    await _storage.write(key: 'token', value: token);
  }

  static Future<String?> obterToken() async {
    return await _storage.read(key: 'token');
  }

  static Future<void> salvarPerfil(String perfil) async {
    await _storage.write(key: 'perfil', value: perfil);
  }

  static Future<String?> obterPerfil() async {
    return await _storage.read(key: 'perfil');
  }

  static Future<void> limpar() async {
    await _storage.deleteAll();
  }
}