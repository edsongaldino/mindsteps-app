import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';

class AuthService {
  Future<Map<String, dynamic>> login({
    required String email,
    required String senha,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        '/Auth/login',
        data: {
          'email': email,
          'senha': senha,
        },
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map && data['message'] != null) {
        throw Exception(data['message']);
      }

      if (data is String && data.isNotEmpty) {
        throw Exception(data);
      }

      throw Exception('Erro ao realizar login.');
    }
  }

  Future<void> recuperarSenha(String email) async {
    try {
      await ApiClient.dio.post(
        '/Auth/recuperar-senha',
        data: {
          'email': email,
        },
      );
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map && data['message'] != null) {
        throw Exception(data['message']);
      }

      if (data is String && data.isNotEmpty) {
        throw Exception(data);
      }

      throw Exception('Erro ao processar solicitação de recuperação de senha.');
    }
  }

  Future<void> registrarPsicologo({
    required String nome,
    required String email,
    required String senha,
    required String crp,
    String? telefone,
    String? bio,
  }) async {
    try {
      await ApiClient.dio.post(
        '/Psicologos/registrar',
        data: {
          'nome': nome,
          'email': email,
          'senha': senha,
          'crp': crp,
          'telefone': telefone,
          'bio': bio,
        },
      );
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map && data['message'] != null) {
        throw Exception(data['message']);
      }

      if (data is String && data.isNotEmpty) {
        throw Exception(data);
      }

      throw Exception('Erro ao cadastrar psicólogo.');
    }
  }
}