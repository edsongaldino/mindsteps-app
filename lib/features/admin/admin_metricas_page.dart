import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import 'services/admin_service.dart';

class AdminMetricasPage extends StatefulWidget {
  const AdminMetricasPage({super.key});

  @override
  State<AdminMetricasPage> createState() => _AdminMetricasPageState();
}

class _AdminMetricasPageState extends State<AdminMetricasPage> {
  final service = AdminService();

  late Future<Map<String, dynamic>> resumoFuture;

  @override
  void initState() {
    super.initState();
    resumoFuture = service.obterResumo();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: resumoFuture,
      builder: (context, snapshot) {
        final dados = snapshot.data ?? {};

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Métricas',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Visão geral da plataforma.',
                style: TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 20),
              _MetricaCard(
                titulo: 'Usuários totais',
                valor: '${dados['usuarios'] ?? 0}',
                icone: LucideIcons.users,
              ),
              _MetricaCard(
                titulo: 'Psicólogos',
                valor: '${dados['psicologos'] ?? 0}',
                icone: LucideIcons.brain,
              ),
              _MetricaCard(
                titulo: 'Pacientes',
                valor: '${dados['pacientes'] ?? 0}',
                icone: LucideIcons.heartPulse,
              ),
              _MetricaCard(
                titulo: 'Status SaaS',
                valor: 'MVP',
                icone: LucideIcons.rocket,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MetricaCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icone;

  const _MetricaCard({
    required this.titulo,
    required this.valor,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icone, color: AppColors.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            valor,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}