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
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF7FAFC),
              Color(0xFFE9F7F6),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.88),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 18),
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: AppColors.softGreen,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: const Icon(
                          LucideIcons.brain,
                          size: 42,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 22),
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                          ),
                          children: [
                            TextSpan(text: 'Mind'),
                            TextSpan(
                              text: 'Steps',
                              style: TextStyle(color: AppColors.secondary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Um passo de cada vez.',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 34),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Bem-vindo(a)!',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.text,
                              ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Fique feliz em te ver de novo.',
                          style: TextStyle(color: AppColors.muted),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'E-mail',
                          hintText: 'seu@email.com',
                          prefixIcon: Icon(LucideIcons.mail),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: senhaController,
                        obscureText: ocultarSenha,
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          prefixIcon: const Icon(LucideIcons.lock),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() => ocultarSenha = !ocultarSenha);
                            },
                            icon: Icon(
                              ocultarSenha ? LucideIcons.eye : LucideIcons.eyeOff,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text('Esqueci minha senha'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: carregando ? null : entrar,
                        child: carregando
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                ),
                                )
                            : const Text('Entrar'),
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'ou continue com',
                        style: TextStyle(color: AppColors.muted, fontSize: 13),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(child: _socialButton('G')),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _socialButtonIcon(LucideIcons.apple),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _socialButtonIcon(LucideIcons.mail),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Não tem uma conta?',
                            style: TextStyle(color: AppColors.muted),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text('Criar conta'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialButton(String text) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _socialButtonIcon(IconData icon) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: AppColors.text),
    );
  }
}