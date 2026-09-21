import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class LocalNotificationManager {
  static final LocalNotificationManager _instance = LocalNotificationManager._internal();
  factory LocalNotificationManager() => _instance;
  LocalNotificationManager._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _inicializado = false;

  Future<void> inicializar() async {
    if (_inicializado) return;

    tz.initializeTimeZones();
    try {
      final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(currentTimeZone));
    } catch (e) {
      // Fallback
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        // Handle notification tap
      },
    );

    _inicializado = true;
  }

  Future<void> exibirNotificacaoImediata({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'mindsteps_channel',
      'MindSteps Notifications',
      channelDescription: 'Notificações gerais do MindSteps',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);
    await _flutterLocalNotificationsPlugin.show(id, title, body, details);
  }

  Future<void> agendarCheckinDiario() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'daily_checkin',
      'Check-in Diário',
      channelDescription: 'Lembrete diário para registrar emoções',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails details = NotificationDetails(android: androidDetails);

    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 8, 0);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      1000,
      'Bom dia!',
      'Como você está se sentindo hoje? Faça seu check-in diário.',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> agendarVencimentoAtividade(String atividadeId, String titulo, DateTime dataVencimento) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'activity_due',
      'Vencimento de Atividades',
      channelDescription: 'Lembretes de prazos de atividades',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails details = NotificationDetails(android: androidDetails);

    // Agendar para 24h antes
    final dataAviso = dataVencimento.subtract(const Duration(hours: 24));
    final tzDate = tz.TZDateTime.from(dataAviso, tz.local);
    
    if (tzDate.isAfter(tz.TZDateTime.now(tz.local))) {
      final id = atividadeId.hashCode;
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        'Atividade vence amanhã',
        'A atividade "$titulo" vence em 24h. Não se esqueça de concluí-la!',
        tzDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }
}
