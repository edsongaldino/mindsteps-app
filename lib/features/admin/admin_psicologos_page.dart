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

        return RefreshIndicator(
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

                  return _PsicologoCard(
                    nome: usuario?['nome'] ?? psicologo['nome'] ?? 'Psicólogo',
                    email: usuario?['email'] ?? '',
                    crp: psicologo['crp'] ?? '-',
                    aprovado: psicologo['aprovado'] == true,
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

class _PsicologoCard extends StatelessWidget {
  final String nome;
  final String email;
  final String crp;
  final bool aprovado;

  const _PsicologoCard({
    required this.nome,
    required this.email,
    required this.crp,
    required this.aprovado,
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
          Icon(
            aprovado ? LucideIcons.badgeCheck : LucideIcons.clock,
            color: aprovado ? AppColors.success : AppColors.warning,
          ),
        ],
      ),
    );
  }
}