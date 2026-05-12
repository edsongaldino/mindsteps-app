import 'package:flutter/material.dart';
import '../../core/auth/auth_storage.dart';
import '../../core/theme/app_theme.dart';
import '../admin/admin_home_page.dart';
import '../paciente/paciente_home_page.dart';
import '../psicologo/psicologo_home_page.dart';
import 'login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    verificarLogin();
  }

  Future<void> verificarLogin() async {
    await Future.delayed(const Duration(milliseconds: 800));

    final token = await AuthStorage.obterToken();
    final perfil = await AuthStorage.obterPerfil();

    if (!mounted) return;

    if (token == null || perfil == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      return;
    }

    Widget destino;

    switch (perfil) {
      case 'Administrador':
        destino = AdminHomePage();
        break;
      case 'Psicologo':
        destino = PsicologoHomePage();
        break;
      case 'Paciente':
        destino = PacienteHomePage();
        break;
      default:
        destino = LoginPage();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destino),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.psychology_alt, size: 72, color: AppColors.primary),
            SizedBox(height: 18),
            Text(
              'MindSteps',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Um passo de cada vez.',
              style: TextStyle(color: AppColors.muted),
            ),
            SizedBox(height: 28),
            CircularProgressIndicator(color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}