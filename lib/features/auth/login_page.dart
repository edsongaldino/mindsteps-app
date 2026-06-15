import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import 'auth_service.dart';
import '../../core/auth/auth_storage.dart';
import '../../core/notifications/notification_manager.dart';
import '../admin/admin_home_page.dart';
import '../psicologo/psicologo_home_page.dart';
import '../paciente/paciente_home_page.dart';
import 'recuperar_senha_page.dart';
import '../../core/auth/biometric_service.dart';


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
  final _biometricService = BiometricService();
  bool biometriaDisponivel = false;
  bool biometriaHabilitada = false;

  @override
  void initState() {
    super.initState();
    _checarBiometria();
  }

  Future<void> _checarBiometria() async {
    final disponivel = await _biometricService.isBiometricAvailable();
    final habilitada = await _biometricService.isBiometricEnabled();
    if (mounted) {
      setState(() {
        biometriaDisponivel = disponivel;
        biometriaHabilitada = habilitada;
      });
      if (disponivel && habilitada) {
        // Delay slightly to let the build finish before spawning biometric prompt
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && !carregando) {
            _autenticarComBiometria();
          }
        });
      }
    }
  }

  Future<void> _autenticarComBiometria() async {
    final autenticado = await _biometricService.authenticate();
    if (!autenticado) return;

    final credenciais = await _biometricService.getSavedCredentials();
    if (credenciais == null) return;

    try {
      setState(() => carregando = true);
      final response = await authService.login(
        email: credenciais['email']!,
        senha: credenciais['senha']!,
      );

      final token = response['token'];
      final perfil = response['perfil'];
      final aprovado = response['aprovado'] ?? true;

      await AuthStorage.salvarToken(token);
      await AuthStorage.salvarPerfil(perfil);
      await AuthStorage.salvarAprovado(aprovado);
      NotificationManager().sincronizarToken();

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao autenticar: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => carregando = false);
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  Future<void> entrar() async {
    try {
        setState(() => carregando = true);

        final email = emailController.text.trim();
        final senha = senhaController.text;

        final response = await authService.login(
          email: email,
          senha: senha,
        );

        final token = response['token'];
        final perfil = response['perfil'];
        final aprovado = response['aprovado'] ?? true;

        await AuthStorage.salvarToken(token);
        await AuthStorage.salvarPerfil(perfil);
        await AuthStorage.salvarAprovado(aprovado);
        NotificationManager().sincronizarToken();

        if (biometriaDisponivel && !biometriaHabilitada) {
          if (mounted) {
            final desejaHabilitar = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: const Row(
                  children: [
                    Icon(LucideIcons.sparkles, color: AppColors.secondary),
                    SizedBox(width: 8),
                    Text('Entrar mais rápido?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                content: const Text('Gostaria de habilitar o reconhecimento facial/digital para os próximos acessos?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Agora não', style: TextStyle(color: AppColors.muted)),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Sim, habilitar'),
                  ),
                ],
              ),
            );

            if (desejaHabilitar == true) {
              await _biometricService.saveCredentials(email, senha);
            }
          }
        }

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
                  
                  // Button Entrar (Teal & full width, with Biometrics if available)
                  Row(
                    children: [
                      Expanded(
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
                      if (biometriaDisponivel) ...[
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: carregando ? null : _autenticarComBiometria,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            height: 52,
                            width: 52,
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
                            ),
                            child: const Icon(
                              LucideIcons.fingerprint,
                              color: AppColors.secondary,
                              size: 26,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Não tem uma conta? Criar conta
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Não tem uma conta? ',
                        style: TextStyle(color: AppColors.muted, fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final Uri url = Uri.parse('http://localhost:4200');
                          try {
                            if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                              throw Exception('Não foi possível abrir a página de cadastro.');
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Erro ao abrir navegador: $e')),
                              );
                            }
                          }
                        },
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
