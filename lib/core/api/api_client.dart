import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'dart:io';
import 'package:dio/io.dart';

import '../../main.dart';
import '../../features/auth/login_page.dart';
import '../auth/auth_storage.dart';

class ApiClient {
  static const String localBaseUrl = 'https://localhost:7035/api'; // Change port if needed
  static const String prodBaseUrl = 'https://api.mindsteps.com.br/api';

  static final Dio dio = (() {
    final d = Dio(
      BaseOptions(
        baseUrl: kDebugMode ? localBaseUrl : prodBaseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    if (kDebugMode && !kIsWeb) {
      d.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
          return client;
        },
      );
    }

    d.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await AuthStorage.obterToken();

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          final isAuthMe404 = error.response?.statusCode == 404 && error.requestOptions.path.contains('/Auth/me');
          if (error.response?.statusCode == 401 || isAuthMe404) {
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

    return d;
  })();
}