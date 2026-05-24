import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import '../../core/api/api_client.dart';
import 'services/admin_service.dart';

class AdminPsicologosPage extends StatefulWidget {
  const AdminPsicologosPage({super.key});

  @override
  State<AdminPsicologosPage> createState() => AdminPsicologosPageState();
}

class AdminPsicologosPageState extends State<AdminPsicologosPage> {
  final service = AdminService();

  late Future<List<dynamic>> psicologosFuture;

  @override
  void initState() {
    super.initState();
    psicologosFuture = service.listarPsicologos();
  }

  Future<void> _recarregar() async {
    setState(() {
      psicologosFuture = service.listarPsicologos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: psicologosFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Text(
                'Erro ao carregar psicólogos: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final psicologos = snapshot.data ?? [];

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: RefreshIndicator(
            onRefresh: _recarregar,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Psicólogos',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Acompanhe profissionais cadastrados.',
                    style: TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 20),
                  if (psicologos.isEmpty)
                    const Text(
                      'Nenhum psicólogo encontrado.',
                      style: TextStyle(color: AppColors.muted),
                  ),
                ...psicologos.map((p) {
                    final psicologo = Map<String, dynamic>.from(p);
                    final usuario = psicologo['usuario'];
                    final nome =
                        usuario?['nome'] ?? psicologo['nome'] ?? 'Psicólogo';
                    final email = usuario?['email'] ?? '';
                    final fotoUrl = psicologo['fotoUrl']?.toString();

                    return _PsicologoCard(
                      nome: nome,
                      email: email,
                      crp: psicologo['crp'] ?? '-',
                      aprovado: psicologo['aprovado'] == true,
                      fotoUrl: fotoUrl,
                      onEdit: () => _exibirDialogoEditar(context, psicologo),
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

  void _exibirDialogoEditar(
      BuildContext context, Map<String, dynamic> psicologo) {
    final usuario = psicologo['usuario'];
    final nomeController =
        TextEditingController(text: usuario?['nome'] ?? psicologo['nome']);
    final emailController =
        TextEditingController(text: usuario?['email'] ?? psicologo['email']);
    final crpController = TextEditingController(text: psicologo['crp']);
    final telefoneController = TextEditingController(text: usuario?['telefone'] ?? psicologo['telefone'] ?? '');

    _exibirPainelLateral(
      context: context,
      titulo: 'Editar Psicólogo',
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
        _buildTextField(
          controller: crpController,
          label: 'CRP',
          icone: LucideIcons.hash,
        ),
      ],
      onConfirmar: () async {
        try {
          await service.atualizarPsicologo(
            id: psicologo['id'].toString(),
            nome: nomeController.text.trim(),
            email: emailController.text.trim(),
            crp: crpController.text.trim(),
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
    final senhaController = TextEditingController();
    final crpController = TextEditingController();
    final telefoneController = TextEditingController();

    _exibirPainelLateral(
      context: context,
      titulo: 'Novo Psicólogo',
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
        _buildTextField(
          controller: crpController,
          label: 'CRP',
          icone: LucideIcons.hash,
        ),
      ],
      onConfirmar: () async {
        try {
          await service.criarPsicologo(
            nome: nomeController.text.trim(),
            email: emailController.text.trim(),
            senha: senhaController.text.trim(),
            crp: crpController.text.trim(),
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
}

class _PsicologoCard extends StatelessWidget {
  final String nome;
  final String email;
  final String crp;
  final bool aprovado;
  final String? fotoUrl;
  final VoidCallback onEdit;

  const _PsicologoCard({
    required this.nome,
    required this.email,
    required this.crp,
    required this.aprovado,
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
    final fullFotoUrl = _obterUrlCompleta(fotoUrl);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
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
                      fontWeight: FontWeight.w900,
                    ),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nome,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'CRP: $crp',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(LucideIcons.pencil, size: 18),
            color: AppColors.muted,
          ),
          Icon(
            aprovado ? LucideIcons.badgeCheck : LucideIcons.clock,
            color: aprovado ? AppColors.success : AppColors.warning,
          ),
        ],
      ),
    );
  }
}