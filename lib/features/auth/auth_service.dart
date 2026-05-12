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
}