import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import 'paciente_detalhe_page.dart';
import 'services/psicologo_service.dart';

class PacientesPage extends StatefulWidget {
  const PacientesPage({super.key});

  @override
  State<PacientesPage> createState() => _PacientesPageState();
}

class _PacientesPageState extends State<PacientesPage> {
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

                    return _PacienteItem(
                      id: id,
                      nome: nome,
                      descricao: 'Última atividade: Ontem',
                      onEdit: () => _exibirDialogoEditar(context, paciente),
                    );
                  }),
                ],
              ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _exibirDialogoCriar(context),
            backgroundColor: AppColors.primary,
            icon: const Icon(LucideIcons.plus, color: Colors.white),
            label: const Text(
              'Novo paciente',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  void _exibirDialogoEditar(BuildContext context, Map<String, dynamic> paciente) {
    final usuario = paciente['usuario'];
    final nomeController = TextEditingController(text: usuario?['nome'] ?? paciente['nome']);
    final emailController = TextEditingController(text: usuario?['email'] ?? paciente['email']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Paciente'),
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
                await service.atualizarPaciente(
                  id: paciente['id'].toString(),
                  nome: nomeController.text,
                  email: emailController.text,
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo Paciente'),
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
                await service.criarPaciente(
                  nome: nomeController.text,
                  email: emailController.text,
                  senha: senhaController.text,
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
  final VoidCallback onEdit;

  const _PacienteItem({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final inicial = nome.isNotEmpty ? nome.substring(0, 1) : '?';

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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
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
              radius: 22,
              backgroundColor: AppColors.softGreen,
              child: Text(
                inicial,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
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
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    descricao,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onEdit,
              icon: const Icon(LucideIcons.pencil, size: 16),
              color: AppColors.muted.withOpacity(0.5),
            ),
            const Icon(LucideIcons.smile, color: AppColors.success, size: 20),
          ],
        ),
      ),
    );
  }
}
