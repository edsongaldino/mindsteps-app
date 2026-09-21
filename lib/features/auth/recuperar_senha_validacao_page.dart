import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pinput/pinput.dart';
import '../../core/theme/app_theme.dart';
import 'auth_service.dart';
import 'redefinir_senha_page.dart';

class RecuperarSenhaValidacaoPage extends StatefulWidget {
  final String email;

  const RecuperarSenhaValidacaoPage({super.key, required this.email});

  @override
  State<RecuperarSenhaValidacaoPage> createState() => _RecuperarSenhaValidacaoPageState();
}

class _RecuperarSenhaValidacaoPageState extends State<RecuperarSenhaValidacaoPage> {
  final _codigoController = TextEditingController();
  final _authService = AuthService();
  bool _carregando = false;

  Future<void> _avancar() async {
    if (_codigoController.text.length != 6) return;

    setState(() => _carregando = true);

    try {
      await _authService.validarCodigoRecuperacao(
        email: widget.email,
        codigo: _codigoController.text,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RedefinirSenhaPage(
            email: widget.email,
            codigo: _codigoController.text,
          ),
        ),
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
        _codigoController.clear();
      }
    } finally {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: const TextStyle(fontSize: 24, color: AppColors.text, fontWeight: FontWeight.bold),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F9),
        borderRadius: BorderRadius.circular(12),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.mailCheck, color: AppColors.secondary, size: 36),
              ),
              const SizedBox(height: 24),
              const Text(
                'Verifique seu e-mail',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.text),
              ),
              const SizedBox(height: 12),
              Text(
                'Enviamos um código de 6 dígitos para o e-mail\n${widget.email}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted, fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 40),
              Pinput(
                controller: _codigoController,
                length: 6,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration?.copyWith(
                    border: Border.all(color: AppColors.secondary, width: 2),
                  ),
                ),
                onCompleted: (pin) => _avancar(),
              ),
              const Spacer(),
              if (_carregando)
                const CircularProgressIndicator(color: AppColors.secondary)
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_codigoController.text.length == 6) {
                        _avancar();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Continuar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
