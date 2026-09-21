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

  Future<void> solicitarCadastroPsicologo({
    required String nome,
    required String email,
    required String senha,
    required String crp,
    required String documento,
    String? telefone,
    String? bio,
  }) async {
    try {
      await ApiClient.dio.post(
        '/Psicologos/solicitar-cadastro',
        data: {
          'nome': nome,
          'email': email,
          'senha': senha,
          'crp': crp,
          'documento': documento,
          'telefone': telefone,
          'bio': bio,
        },
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) throw Exception(data['message']);
      if (data is String && data.isNotEmpty) throw Exception(data);
      throw Exception('Erro ao solicitar cadastro.');
    }
  }

  Future<Map<String, dynamic>> validarCadastro({
    required String email,
    required String codigo,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        '/Psicologos/validar-cadastro',
        data: {
          'email': email,
          'codigo': codigo,
        },
      );
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) throw Exception(data['message']);
      if (data is String && data.isNotEmpty) throw Exception(data);
      throw Exception('Erro ao validar cadastro.');
    }
  }

  Future<Map<String, dynamic>> redefinirSenha({
    required String email,
    required String codigo,
    required String novaSenha,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        '/Auth/redefinir-senha',
        data: {
          'email': email,
          'codigo': codigo,
          'novaSenha': novaSenha,
        },
      );
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) throw Exception(data['message']);
      throw Exception('Erro ao redefinir a senha.');
    }
  }

  Future<void> validarCodigoRecuperacao({
    required String email,
    required String codigo,
  }) async {
    try {
      await ApiClient.dio.post(
        '/Auth/validar-codigo-recuperacao',
        data: {
          'email': email,
          'codigo': codigo,
        },
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) throw Exception(data['message']);
      if (data is String && data.isNotEmpty) throw Exception(data);
      throw Exception('Código de verificação inválido.');
    }
  }
}