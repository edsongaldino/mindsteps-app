import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_theme.dart';
import '../../core/api/api_client.dart';
import 'paciente_detalhe_page.dart';
import 'services/psicologo_service.dart';
import 'widgets/paciente_avatar_widget.dart';

class PacientesPage extends StatefulWidget {
  const PacientesPage({super.key});

  @override
  State<PacientesPage> createState() => PacientesPageState();
}

class PacientesPageState extends State<PacientesPage> {
  final service = PsicologoService();

  late Future<List<dynamic>> pacientesFuture;

  @override
  void initState() {
    super.initState();
    pacientesFuture = service.listarPacientesDoPsicologo();
  }

  Future<void> _recarregar() async {
    setState(() {
      pacientesFuture = service.listarPacientesDoPsicologo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: pacientesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Text(
                'Erro ao carregar pacientes: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final pacientes = snapshot.data ?? [];

        return Scaffold(
          backgroundColor: AppColors.background,
          body: RefreshIndicator(
            onRefresh: _recarregar,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Meus pacientes',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const _CampoBuscaPaciente(),
                  const SizedBox(height: 24),
                  if (pacientes.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Text(
                          'Nenhum paciente encontrado.',
                          style: TextStyle(color: AppColors.muted),
                        ),
                      ),
                    ),
                  ...pacientes.map((paciente) {
                    final usuario = paciente['usuario'];
                    final nome =
                        usuario?['nome'] ?? paciente['nome'] ?? 'Paciente';
                    final id = paciente['id']?.toString() ?? '';
                    final fotoUrl = paciente['fotoUrl']?.toString() ??
                        usuario?['fotoUrl']?.toString() ??
                        paciente['avatar']?.toString() ??
                        usuario?['avatar']?.toString();

                    return _PacienteItem(
                      id: id,
                      nome: nome,
                      descricao: 'Última atividade: Ontem',
                      fotoUrl: fotoUrl,
                      onEdit: () => _exibirDialogoEditar(context, paciente),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icone,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.text),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            style: const TextStyle(fontSize: 14, color: AppColors.text),
            decoration: InputDecoration(
              prefixIcon: Icon(icone, size: 18, color: AppColors.muted),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
              hintText: 'Digite o ${label.toLowerCase()}',
              hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  void _exibirPainelLateral({
    required BuildContext context,
    required String titulo,
    required List<Widget> campos,
    required Future<void> Function() onConfirmar,
    required String textoConfirmar,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (ctx, anim1, anim2) {
        bool salvando = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Align(
              alignment: Alignment.centerRight,
              child: Material(
                color: AppColors.background,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    border: Border(left: BorderSide(color: AppColors.border, width: 1)),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                titulo,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.text,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(LucideIcons.x, color: AppColors.muted),
                                onPressed: () => Navigator.pop(ctx),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: campos,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: salvando ? null : () => Navigator.pop(ctx),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Text('Cancelar'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: salvando
                                      ? null
                                      : () async {
                                          setDialogState(() => salvando = true);
                                          try {
                                            await onConfirmar();
                                            if (ctx.mounted) {
                                              Navigator.pop(ctx);
                                            }
                                          } catch (_) {
                                            // Error is handled inside onConfirmar
                                          } finally {
                                            setDialogState(() => salvando = false);
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: salvando
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : Text(textoConfirmar),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOut)),
          child: child,
        );
      },
    );
  }

  void _exibirDialogoEditar(BuildContext context, Map<String, dynamic> paciente) {
    final usuario = paciente['usuario'];
    final nomeController = TextEditingController(text: usuario?['nome'] ?? paciente['nome']);
    final emailController = TextEditingController(text: usuario?['email'] ?? paciente['email']);
    final telefoneController = TextEditingController(text: usuario?['telefone'] ?? paciente['telefone'] ?? '');
    
    final maskFormatter = MaskTextInputFormatter(
      mask: '(##) #####-####',
      filter: { "#": RegExp(r'[0-9]') },
    );

    final senhaController = TextEditingController();

    _exibirPainelLateral(
      context: context,
      titulo: 'Editar Paciente',
      textoConfirmar: 'Salvar',
      campos: [
        _buildTextField(
          controller: nomeController,
          label: 'Nome',
          icone: LucideIcons.user,
        ),
        _buildTextField(
          controller: emailController,
          label: 'Email',
          icone: LucideIcons.mail,
          keyboardType: TextInputType.emailAddress,
        ),
        _buildTextField(
          controller: telefoneController,
          label: 'Telefone',
          icone: LucideIcons.phone,
          keyboardType: TextInputType.phone,
          inputFormatters: [maskFormatter],
        ),
        _buildTextField(
          controller: senhaController,
          label: 'Nova senha (opcional)',
          icone: LucideIcons.lock,
          obscureText: true,
        ),
      ],
      onConfirmar: () async {
        try {
          await service.atualizarPaciente(
            id: paciente['id'].toString(),
            nome: nomeController.text.trim(),
            email: emailController.text.trim(),
            telefone: telefoneController.text.replaceAll(RegExp(r'\D'), ''),
            senha: senhaController.text.trim(),
          );
          _recarregar();
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erro: $e')),
            );
          }
          rethrow;
        }
      },
    );
  }

  void exibirDialogoCriar(BuildContext context) {
    final nomeController = TextEditingController();
    final emailController = TextEditingController();
    final telefoneController = TextEditingController();
    final senhaController = TextEditingController();

    final maskFormatter = MaskTextInputFormatter(
      mask: '(##) #####-####',
      filter: { "#": RegExp(r'[0-9]') },
    );

    _exibirPainelLateral(
      context: context,
      titulo: 'Novo Paciente',
      textoConfirmar: 'Criar',
      campos: [
        _buildTextField(
          controller: nomeController,
          label: 'Nome',
          icone: LucideIcons.user,
        ),
        _buildTextField(
          controller: emailController,
          label: 'Email',
          icone: LucideIcons.mail,
          keyboardType: TextInputType.emailAddress,
        ),
        _buildTextField(
          controller: telefoneController,
          label: 'Telefone',
          icone: LucideIcons.phone,
          keyboardType: TextInputType.phone,
          inputFormatters: [maskFormatter],
        ),
        _buildTextField(
          controller: senhaController,
          label: 'Senha',
          icone: LucideIcons.lock,
          obscureText: true,
        ),
      ],
      onConfirmar: () async {
        try {
          await service.criarPaciente(
            nome: nomeController.text.trim(),
            email: emailController.text.trim(),
            telefone: telefoneController.text.replaceAll(RegExp(r'\D'), ''),
            senha: senhaController.text.trim(),
          );
          _recarregar();
          
          Future.delayed(const Duration(milliseconds: 400), () {
            if (context.mounted) {
              _exibirModalConvite(
                context,
                nomeController.text.trim(),
                emailController.text.trim(),
                telefoneController.text.replaceAll(RegExp(r'\D'), ''),
                senhaController.text.trim(),
              );
            }
          });
        } catch (e) {
          String errMsg = 'Erro ao cadastrar paciente.';
          try {
            final dynamic err = e;
            if (err.response?.data != null) {
              final data = err.response.data;
              if (data is Map && data.containsKey('message')) {
                errMsg = data['message'].toString();
              }
            } else {
              errMsg = e.toString();
            }
          } catch (_) {
            errMsg = e.toString();
          }
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errMsg),
                backgroundColor: AppColors.danger,
              ),
            );
          }
        }
      },
    );
  }

  void _exibirModalConvite(BuildContext context, String nome, String email, String telefone, String senha) {
    final mensagem = '''Olá $nome! Tudo bem?
Seu psicólogo(a) preparou um espaço exclusivo para você no aplicativo MindSteps.
Por lá, você poderá realizar atividades, jogos terapêuticos e muito mais.

📲 Baixe o app aqui: https://mindsteps.app/download

Aqui estão seus dados de acesso:
E-mail: $email
Senha: $senha

Aguardamos você!''';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.softGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(LucideIcons.messageCircle, color: AppColors.success),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Paciente cadastrado!',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text),
                        ),
                        Text(
                          'Envie o convite com os dados de acesso.',
                          style: TextStyle(fontSize: 13, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  mensagem,
                  style: const TextStyle(fontSize: 14, color: AppColors.text, height: 1.5),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: mensagem));
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(content: Text('Mensagem copiada!')),
                        );
                      },
                      icon: const Icon(LucideIcons.copy, size: 18),
                      label: const Text('Copiar'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        String wppNumber = telefone;
                        if (!wppNumber.startsWith('55') && wppNumber.length <= 11) {
                           wppNumber = '55$wppNumber';
                        }
                        
                        final url = Uri.parse('https://wa.me/$wppNumber?text=${Uri.encodeComponent(mensagem)}');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        } else {
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(content: Text('Não foi possível abrir o WhatsApp.')),
                            );
                          }
                        }
                      },
                      icon: const Icon(LucideIcons.send, size: 18),
                      label: const Text('WhatsApp'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Agora não', style: TextStyle(color: AppColors.muted)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CampoBuscaPaciente extends StatelessWidget {
  const _CampoBuscaPaciente();

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Buscar paciente',
        prefixIcon: const Icon(LucideIcons.search, size: 20),
        suffixIcon: IconButton(
          onPressed: () {},
          icon: const Icon(LucideIcons.slidersHorizontal, size: 20),
        ),
      ),
    );
  }
}

class _PacienteItem extends StatelessWidget {
  final String id;
  final String nome;
  final String descricao;
  final String? fotoUrl;
  final VoidCallback onEdit;

  const _PacienteItem({
    required this.id,
    required this.nome,
    required this.descricao,
    this.fotoUrl,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    // Mocking the percentage and icon based on name length for visual variety
    int percentage = 50 + (nome.length * 5) % 50; 
    IconData moodIcon = LucideIcons.smile;
    Color moodColor = AppColors.success;
    
    if (percentage < 60) {
      moodIcon = LucideIcons.meh;
      moodColor = AppColors.warning;
    } else if (percentage < 40) {
      moodIcon = LucideIcons.frown;
      moodColor = AppColors.danger;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PacienteDetalhePage(
              pacienteId: id,
              nome: nome,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            PacienteAvatarWidget(
              fotoUrl: fotoUrl,
              nome: nome,
              radius: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nome,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    descricao,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Icon(moodIcon, color: moodColor, size: 20),
                const SizedBox(width: 6),
                Text(
                  '$percentage%',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
