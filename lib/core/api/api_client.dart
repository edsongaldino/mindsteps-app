import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../main.dart';
import '../../features/auth/login_page.dart';
import '../auth/auth_storage.dart';

class ApiClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://localhost:7035/api',
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await AuthStorage.obterToken();

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            final isLoginRequest = error.requestOptions.path.contains('/Auth/login');
            if (!isLoginRequest) {
              await AuthStorage.limpar();
              navigatorKey.currentState?.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            }
            return handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                response: error.response,
                message: 'Sessão expirada. Faça login novamente.',
              ),
            );
          }

          return handler.next(error);
        },
      ),
    );
}