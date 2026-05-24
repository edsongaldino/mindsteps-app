import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import '../../core/api/api_client.dart';
import 'paciente_detalhe_page.dart';
import 'services/psicologo_service.dart';

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
                    final fotoUrl = paciente['fotoUrl']?.toString();

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
        ),
      ],
      onConfirmar: () async {
        try {
          await service.atualizarPaciente(
            id: paciente['id'].toString(),
            nome: nomeController.text.trim(),
            email: emailController.text.trim(),
            telefone: telefoneController.text.trim(),
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
            telefone: telefoneController.text.trim(),
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

  String? _obterUrlCompleta(String? url) {
    if (url == null || url.isEmpty) return null;
    final baseUrl = ApiClient.dio.options.baseUrl;
    final domain = baseUrl.endsWith('/api')
        ? baseUrl.substring(0, baseUrl.length - 4)
        : baseUrl;
    return '$domain$url';
  }

  @override
  Widget build(BuildContext context) {
    final inicial = nome.isNotEmpty ? nome.substring(0, 1) : '?';
    
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

    final fullFotoUrl = _obterUrlCompleta(fotoUrl);

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
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.softGreen,
              backgroundImage: fullFotoUrl != null
                  ? NetworkImage(fullFotoUrl)
                  : null,
              child: fullFotoUrl != null
                  ? null
                  : Text(
                      inicial,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
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
