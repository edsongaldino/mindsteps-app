import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import 'services/admin_service.dart';

class AdminPsicologosPage extends StatefulWidget {
  const AdminPsicologosPage({super.key});

  @override
  State<AdminPsicologosPage> createState() => _AdminPsicologosPageState();
}

class _AdminPsicologosPageState extends State<AdminPsicologosPage> {
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

                    return _PsicologoCard(
                      nome: nome,
                      email: email,
                      crp: psicologo['crp'] ?? '-',
                      aprovado: psicologo['aprovado'] == true,
                      onEdit: () => _exibirDialogoEditar(context, psicologo),
                    );
                  }),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _exibirDialogoCriar(context),
            child: const Icon(LucideIcons.plus),
          ),
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Psicólogo'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: crpController,
                decoration: const InputDecoration(labelText: 'CRP'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await service.atualizarPsicologo(
                  id: psicologo['id'].toString(),
                  nome: nomeController.text,
                  email: emailController.text,
                  crp: crpController.text,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  _recarregar();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro: $e')),
                  );
                }
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _exibirDialogoCriar(BuildContext context) {
    final nomeController = TextEditingController();
    final emailController = TextEditingController();
    final senhaController = TextEditingController();
    final crpController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo Psicólogo'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: senhaController,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
              ),
              TextField(
                controller: crpController,
                decoration: const InputDecoration(labelText: 'CRP'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await service.criarPsicologo(
                  nome: nomeController.text,
                  email: emailController.text,
                  senha: senhaController.text,
                  crp: crpController.text,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  _recarregar();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro: $e')),
                  );
                }
              }
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }
}

class _PsicologoCard extends StatelessWidget {
  final String nome;
  final String email;
  final String crp;
  final bool aprovado;
  final VoidCallback onEdit;

  const _PsicologoCard({
    required this.nome,
    required this.email,
    required this.crp,
    required this.aprovado,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final inicial = nome.isNotEmpty ? nome.substring(0, 1) : '?';

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
            child: Text(
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