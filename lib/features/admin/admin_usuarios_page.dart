import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import 'services/admin_service.dart';

class AdminUsuariosPage extends StatefulWidget {
  const AdminUsuariosPage({super.key});

  @override
  State<AdminUsuariosPage> createState() => _AdminUsuariosPageState();
}

class _AdminUsuariosPageState extends State<AdminUsuariosPage> {
  final service = AdminService();

  late Future<List<dynamic>> usuariosFuture;

  @override
  void initState() {
    super.initState();
    usuariosFuture = service.listarUsuarios();
  }

  Future<void> _recarregar() async {
    setState(() {
      usuariosFuture = service.listarUsuarios();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: usuariosFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Text(
                'Erro ao carregar usuários: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final usuarios = snapshot.data ?? [];

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
                    'Usuários',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Gerencie os acessos da plataforma.',
                    style: TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 20),
                  if (usuarios.isEmpty)
                    const Text(
                      'Nenhum usuário encontrado.',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  ...usuarios.map((u) {
                    final usuario = Map<String, dynamic>.from(u);
                    final id = usuario['id']?.toString() ?? '';
                    return _UsuarioCard(
                      id: id,
                      nome: usuario['nome'] ?? 'Usuário',
                      email: usuario['email'] ?? '',
                      perfil: usuario['perfil']?.toString() ?? '-',
                      ativo: usuario['ativo'] == true,
                      onEdit: () => _exibirDialogoEditar(context, usuario),
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

  void _exibirDialogoEditar(BuildContext context, Map<String, dynamic> usuario) {
    final nomeController = TextEditingController(text: usuario['nome']);
    final emailController = TextEditingController(text: usuario['email']);
    int perfilSelecionado = 3;

    final perfilRaw = usuario['perfil'];
    if (perfilRaw == 'Administrador' || perfilRaw == 1) perfilSelecionado = 1;
    if (perfilRaw == 'Psicologo' || perfilRaw == 2) perfilSelecionado = 2;
    if (perfilRaw == 'Paciente' || perfilRaw == 3) perfilSelecionado = 3;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Editar Usuário'),
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
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: perfilSelecionado,
                  decoration: const InputDecoration(labelText: 'Perfil'),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Administrador')),
                    DropdownMenuItem(value: 2, child: Text('Psicólogo')),
                    DropdownMenuItem(value: 3, child: Text('Paciente')),
                  ],
                  onChanged: (v) => setStateDialog(() => perfilSelecionado = v!),
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
                  await service.atualizarUsuario(
                    id: usuario['id'].toString(),
                    nome: nomeController.text,
                    email: emailController.text,
                    perfil: perfilSelecionado,
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
      ),
    );
  }

  void _exibirDialogoCriar(BuildContext context) {
    final nomeController = TextEditingController();
    final emailController = TextEditingController();
    final senhaController = TextEditingController();
    int perfilSelecionado = 3; // Paciente por padrão

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Novo Usuário'),
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
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: perfilSelecionado,
                  decoration: const InputDecoration(labelText: 'Perfil'),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Administrador')),
                    DropdownMenuItem(value: 2, child: Text('Psicólogo')),
                    DropdownMenuItem(value: 3, child: Text('Paciente')),
                  ],
                  onChanged: (v) => setState(() => perfilSelecionado = v!),
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
                  await service.criarUsuario(
                    nome: nomeController.text,
                    email: emailController.text,
                    senha: senhaController.text,
                    perfil: perfilSelecionado,
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
      ),
    );
  }
}

class _UsuarioCard extends StatelessWidget {
  final String id;
  final String nome;
  final String email;
  final String perfil;
  final bool ativo;
  final VoidCallback onEdit;

  const _UsuarioCard({
    required this.id,
    required this.nome,
    required this.email,
    required this.perfil,
    required this.ativo,
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
                  perfil,
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
            ativo ? LucideIcons.circleCheck : LucideIcons.circleX,
            color: ativo ? AppColors.success : AppColors.danger,
          ),
        ],
      ),
    );
  }
}