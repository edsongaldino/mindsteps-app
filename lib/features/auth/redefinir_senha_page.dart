import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import 'auth_service.dart';
import '../../core/auth/auth_storage.dart';
import '../psicologo/psicologo_home_page.dart';

class RedefinirSenhaPage extends StatefulWidget {
  final String email;
  final String codigo;

  const RedefinirSenhaPage({super.key, required this.email, required this.codigo});

  @override
  State<RedefinirSenhaPage> createState() => _RedefinirSenhaPageState();
}

class _RedefinirSenhaPageState extends State<RedefinirSenhaPage> {
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  
  bool _ocultarSenha = true;
  bool _ocultarConfirmarSenha = true;
  bool _carregando = false;

  Future<void> _redefinirSenha() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);

    try {
      final response = await _authService.redefinirSenha(
        email: widget.email,
        codigo: widget.codigo,
        novaSenha: _senhaController.text,
      );

      final token = response['token'];
      final perfil = response['perfil'];
      final aprovado = response['aprovado'] ?? true;

      await AuthStorage.salvarToken(token);
      await AuthStorage.salvarPerfil(perfil);
      await AuthStorage.salvarAprovado(aprovado);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Senha redefinida com sucesso!'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const PsicologoHomePage()),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        String mensagem = e.toString();
        if (mensagem.startsWith('Exception: ')) {
          mensagem = mensagem.substring(11);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.danger,
            content: Text(mensagem),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.lockKeyhole, color: AppColors.secondary, size: 36),
                  ),
                ),
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    'Nova Senha',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.text),
                  ),
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'Crie uma nova senha para sua conta.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted, fontSize: 14, height: 1.4),
                  ),
                ),
                const SizedBox(height: 40),
                
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text('Nova Senha', style: TextStyle(color: AppColors.text, fontSize: 14, fontWeight: FontWeight.w600)),
                ),
                TextFormField(
                  controller: _senhaController,
                  obscureText: _ocultarSenha,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Campo obrigatório';
                    if (v.length < 6) return 'A senha deve ter pelo menos 6 caracteres';
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: const Icon(LucideIcons.lock, size: 20, color: AppColors.muted),
                    filled: true,
                    fillColor: const Color(0xFFF4F6F9),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    suffixIcon: IconButton(
                      icon: Icon(_ocultarSenha ? LucideIcons.eyeOff : LucideIcons.eye, color: AppColors.muted, size: 20),
                      onPressed: () => setState(() => _ocultarSenha = !_ocultarSenha),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text('Confirmar Nova Senha', style: TextStyle(color: AppColors.text, fontSize: 14, fontWeight: FontWeight.w600)),
                ),
                TextFormField(
                  controller: _confirmarSenhaController,
                  obscureText: _ocultarConfirmarSenha,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Campo obrigatório';
                    if (v != _senhaController.text) return 'As senhas não coincidem';
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: const Icon(LucideIcons.lock, size: 20, color: AppColors.muted),
                    filled: true,
                    fillColor: const Color(0xFFF4F6F9),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    suffixIcon: IconButton(
                      icon: Icon(_ocultarConfirmarSenha ? LucideIcons.eyeOff : LucideIcons.eye, color: AppColors.muted, size: 20),
                      onPressed: () => setState(() => _ocultarConfirmarSenha = !_ocultarConfirmarSenha),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _carregando ? null : _redefinirSenha,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _carregando
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Redefinir e Entrar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
