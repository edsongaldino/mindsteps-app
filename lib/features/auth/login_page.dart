import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import 'auth_service.dart';
import '../../core/auth/auth_storage.dart';
import '../admin/admin_home_page.dart';
import '../psicologo/psicologo_home_page.dart';
import '../paciente/paciente_home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  bool ocultarSenha = true;

  bool carregando = false;

  final authService = AuthService();

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  Future<void> entrar() async {
    try {
        setState(() => carregando = true);

        final response = await authService.login(
        email: emailController.text.trim(),
        senha: senhaController.text,
        );

        final token = response['token'];
        final perfil = response['perfil'];

        await AuthStorage.salvarToken(token);
        await AuthStorage.salvarPerfil(perfil);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Login realizado: $perfil'),
        ),
        );

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
            throw Exception('Perfil de usuário inválido.');
        }

        Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => destino),
        );
    } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
        );
    } finally {
        if (mounted) {
        setState(() => carregando = false);
        }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(LucideIcons.arrowLeft, color: AppColors.text),
                ),
              ),
              const SizedBox(height: 20),
              // Logo
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/logo.png'), // Fallback to icon if image missing
                    fit: BoxFit.contain,
                  ),
                ),
                child: const Icon(LucideIcons.brain, size: 60, color: AppColors.primary),
              ),
              const SizedBox(height: 32),
              const Text(
                'Bem-vindo(a)!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Fique feliz em te ver de novo.',
                style: TextStyle(color: AppColors.muted, fontSize: 14),
              ),
              const SizedBox(height: 48),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  hintText: 'seu@email.com',
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: senhaController,
                obscureText: ocultarSenha,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() => ocultarSenha = !ocultarSenha);
                    },
                    icon: Icon(
                      ocultarSenha ? LucideIcons.eye : LucideIcons.eyeOff,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Esqueci minha senha',
                    style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: carregando ? null : entrar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size(double.infinity, 54),
                ),
                child: carregando
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Text('Entrar'),
              ),
              const SizedBox(height: 32),
              const Text(
                'ou continue com',
                style: TextStyle(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialButton('G'),
                  const SizedBox(width: 20),
                  _socialIcon(LucideIcons.apple),
                  const SizedBox(width: 20),
                  _socialIcon(LucideIcons.mail),
                ],
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Não tem uma conta? ',
                    style: TextStyle(color: AppColors.muted, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'Criar conta',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _socialButton(String label) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
        ),
      ),
    );
  }

  Widget _socialIcon(IconData icon) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border),
      ),
      child: Icon(icon, color: AppColors.text, size: 22),
    );
  }
}
