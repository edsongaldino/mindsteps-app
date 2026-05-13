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

        return RefreshIndicator(
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
                  return _UsuarioCard(
                    nome: usuario['nome'] ?? 'Usuário',
                    email: usuario['email'] ?? '',
                    perfil: usuario['perfil']?.toString() ?? '-',
                    ativo: usuario['ativo'] == true,
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _UsuarioCard extends StatelessWidget {
  final String nome;
  final String email;
  final String perfil;
  final bool ativo;

  const _UsuarioCard({
    required this.nome,
    required this.email,
    required this.perfil,
    required this.ativo,
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
          Icon(
            ativo ? LucideIcons.circleCheck : LucideIcons.circleX,
            color: ativo ? AppColors.success : AppColors.danger,
          ),
        ],
      ),
    );
  }
}