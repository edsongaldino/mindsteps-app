import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import 'auth_service.dart';
import '../../core/auth/auth_storage.dart';
import '../admin/admin_home_page.dart';
import '../psicologo/psicologo_home_page.dart';
import '../paciente/paciente_home_page.dart';
import 'recuperar_senha_page.dart';


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
      body: Stack(
        children: [
          // Background decorativo (ondas de fundo no canto superior direito)
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.12),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(180),
                  bottomRight: Radius.circular(80),
                  topLeft: Radius.circular(80),
                  topRight: Radius.circular(180),
                ),
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.08),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(120),
                  bottomRight: Radius.circular(50),
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(120),
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Botão de voltar
                  IconButton(
                    icon: const Icon(LucideIcons.arrowLeft, color: AppColors.text, size: 24),
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(height: 20),
                  
                  // Logo
                  Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 120, // Increased size to make emblem big
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.psychology, size: 100, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Title Centered
                  const Center(
                    child: Text(
                      'Bem-vindo(a)!',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Subtitle Centered
                  const Center(
                    child: Text(
                      'Fico feliz em te ver de novo.',
                      style: TextStyle(color: AppColors.muted, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 36),
                  
                  const Text(
                    'E-mail',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: 'seu@email.com',
                      filled: true,
                      fillColor: const Color(0xFFF4F6F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  
                  const Text(
                    'Senha',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: senhaController,
                    obscureText: ocultarSenha,
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      filled: true,
                      fillColor: const Color(0xFFF4F6F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() => ocultarSenha = !ocultarSenha);
                        },
                        icon: Icon(
                          ocultarSenha ? LucideIcons.eyeOff : LucideIcons.eye,
                          size: 20,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Esqueci minha senha (centered & underlined)
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RecuperarSenhaPage()),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Esqueci minha senha',
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Button Entrar (Teal & full width)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: carregando ? null : entrar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: carregando
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                            )
                          : const Text('Entrar'),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  const Center(
                    child: Text(
                      'ou continue com',
                      style: TextStyle(color: AppColors.muted, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Social buttons (circular)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _socialButton(
                        const Text(
                          'G',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.red),
                        ),
                        onTap: () {},
                      ),
                      const SizedBox(width: 20),
                      _socialButton(
                        const Icon(Icons.apple, color: Colors.black, size: 26),
                        onTap: () {},
                      ),
                      const SizedBox(width: 20),
                      _socialButton(
                        const Icon(LucideIcons.mail, color: AppColors.text, size: 22),
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  
                  // Não tem uma conta? Criar conta
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
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialButton(Widget content, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: content,
        ),
      ),
    );
  }
}
