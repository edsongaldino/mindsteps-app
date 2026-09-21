import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../core/theme/app_theme.dart';
import 'auth_service.dart';
import 'validacao_codigo_page.dart';

class CadastroPsicologoPage extends StatefulWidget {
  const CadastroPsicologoPage({super.key});

  @override
  State<CadastroPsicologoPage> createState() => _CadastroPsicologoPageState();
}

class _CadastroPsicologoPageState extends State<CadastroPsicologoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  final _crpController = TextEditingController();
  final _documentoController = TextEditingController();

  bool _ocultarSenha = true;
  bool _ocultarConfirmarSenha = true;
  bool _carregando = false;
  final _authService = AuthService();

  Future<void> _solicitarCadastro() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_senhaController.text != _confirmarSenhaController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('As senhas não coincidem.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _carregando = true);
    try {
      await _authService.solicitarCadastroPsicologo(
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        telefone: _telefoneController.text.trim(),
        senha: _senhaController.text,
        crp: _crpController.text.trim(),
        documento: _documentoController.text.trim(),
      );

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Código de verificação enviado para o seu e-mail!'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ValidacaoCodigoPage(email: _emailController.text.trim()),
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
        title: const Text('Criar conta', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bem-vindo ao MindSteps!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Preencha seus dados para receber 30 dias de teste gratuito da nossa plataforma. Não é necessário cartão de crédito agora, o pagamento será solicitado somente após o período de teste caso deseje continuar (via cartão ou boleto).',
                style: TextStyle(color: AppColors.muted, fontSize: 14),
              ),
              const SizedBox(height: 24),
              
              _buildLabel('Nome Completo'),
              _buildTextField(_nomeController, 'Seu nome completo', icon: LucideIcons.user),
              const SizedBox(height: 16),
              
              _buildLabel('E-mail'),
              _buildTextField(_emailController, 'seu@email.com', icon: LucideIcons.mail, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Telefone'),
                        _buildTextField(
                          _telefoneController, 
                          '(00) 00000-0000', 
                          icon: LucideIcons.phone, 
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            TelefoneInputFormatter(),
                          ]
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('CRP'),
                        _buildTextField(
                          _crpController, 
                          '00/00000', 
                          icon: LucideIcons.briefcase,
                          inputFormatters: [
                            MaskTextInputFormatter(
                              mask: '##/######', 
                              filter: { "#": RegExp(r'[0-9]') }
                            )
                          ]
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildLabel('CPF ou CNPJ'),
              _buildTextField(
                _documentoController, 
                'Apenas números', 
                icon: LucideIcons.fileText,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CpfOuCnpjFormatter(),
                ]
              ),
              const SizedBox(height: 16),

              _buildLabel('Senha'),
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

              _buildLabel('Confirmar Senha'),
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
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _carregando ? null : _solicitarCadastro,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _carregando
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Continuar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(color: AppColors.text, fontSize: 14, fontWeight: FontWeight.w600),
          children: const [
            TextSpan(
              text: ' *',
              style: TextStyle(color: AppColors.danger),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, 
    String hint, 
    {required IconData icon, TextInputType? keyboardType, List<TextInputFormatter>? inputFormatters}
  ) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: AppColors.muted),
        filled: true,
        fillColor: const Color(0xFFF4F6F9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }
}
