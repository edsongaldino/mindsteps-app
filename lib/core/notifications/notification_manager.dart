import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../api/api_client.dart';
import '../auth/auth_storage.dart';

class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

  bool _inicializado = false;

  Future<void> inicializar() async {
    if (_inicializado) return;

    try {
      // Tenta inicializar o Firebase. 
      // Se google-services.json/GoogleService-Info.plist não estiver presente,
      // irá capturar o erro para evitar que o app quebre.
      await Firebase.initializeApp();
      
      final messaging = FirebaseMessaging.instance;

      // Solicita permissão de notificação
      await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      // Ouvir mensagens em foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('Mensagem recebida em foreground: ${message.notification?.title}');
        }
      });

      // Ouvir cliques em notificações quando o app está em background/fechado
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('Notificação clicada: ${message.data}');
        }
      });

      _inicializado = true;
      if (kDebugMode) {
        print('Firebase Cloud Messaging inicializado com sucesso.');
      }

      // Se o usuário já estiver logado, atualiza o token
      await sincronizarToken();
    } catch (e) {
      if (kDebugMode) {
        print('Aviso: Não foi possível inicializar o Firebase Messaging (configurações do Firebase pendentes): $e');
      }
    }
  }

  Future<void> sincronizarToken() async {
    if (!_inicializado) return;

    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;

      final userToken = await AuthStorage.obterToken();
      if (userToken == null || userToken.isEmpty) {
        return; // Usuário não logado ainda
      }

      // Obtém dados do usuário logado do endpoint /Auth/me
      final response = await ApiClient.dio.get('/Auth/me');
      final me = response.data;
      final usuarioId = me['usuarioId'] ?? me['id'];

      if (usuarioId != null) {
        final platform = kIsWeb ? 'Web' : (Platform.isAndroid ? 'Android' : 'iOS');
        await ApiClient.dio.post(
          '/Usuarios/$usuarioId/device-token',
          data: {
            'deviceToken': token,
            'plataforma': platform,
          },
        );
        if (kDebugMode) {
          print('Device token sincronizado com sucesso para o usuário $usuarioId.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao sincronizar token com o servidor: $e');
      }
    }
  }
}
