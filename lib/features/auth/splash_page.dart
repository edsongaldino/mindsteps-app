import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
  bool mostrarSelecao = false;

  @override
  void initState() {
    super.initState();
    verificarLogin();
  }

  Future<void> verificarLogin() async {
    await Future.delayed(const Duration(milliseconds: 1200));

    final token = await AuthStorage.obterToken();
    final perfil = await AuthStorage.obterPerfil();

    if (!mounted) return;

    if (token == null || perfil == null) {
      setState(() => mostrarSelecao = true);
      return;
    }

    Widget destino;
    switch (perfil) {
      case 'Administrador':
        destino = const AdminHomePage();
        break;
      case 'Psicologo':
        destino = const PsicologoHomePage();
        break;
      case 'Paciente':
        destino = const PacienteHomePage();
        break;
      default:
        setState(() => mostrarSelecao = true);
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destino),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: mostrarSelecao ? _buildSelecao() : _buildSplash(),
        ),
      ),
    );
  }

  Widget _buildSplash() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(LucideIcons.brain, size: 80, color: AppColors.primary),
        SizedBox(height: 24),
        Text(
          'MindSteps',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Um passo de cada vez.',
          style: TextStyle(color: AppColors.muted),
        ),
      ],
    );
  }

  Widget _buildSelecao() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.brain, size: 80, color: AppColors.primary),
          const SizedBox(height: 24),
          const Text(
            'MindSteps',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Um passo de cada vez.',
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 60),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Sou Psicólogo'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.border),
              ),
              elevation: 0,
            ),
            child: const Text('Sou Paciente'),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Já tem uma conta? ', style: TextStyle(color: AppColors.muted)),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
                },
                child: const Text(
                  'Entrar',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}