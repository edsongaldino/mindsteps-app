import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/splash_page.dart';
import 'core/notifications/notification_manager.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MindStepsApp());
  NotificationManager().inicializar();
}

class MindStepsApp extends StatelessWidget {
  const MindStepsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'MindSteps',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const SplashPage(),
    );
  }
}