import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import 'services/admin_service.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final service = AdminService();

  late Future<Map<String, dynamic>> resumoFuture;

  @override
  void initState() {
    super.initState();
    resumoFuture = service.obterResumo();
  }

  Future<void> _recarregar() async {
    setState(() {
      resumoFuture = service.obterResumo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: resumoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Text(
                'Erro ao carregar dashboard: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final resumo = snapshot.data ?? {};

        return RefreshIndicator(
          onRefresh: _recarregar,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _TopoAdmin(),
                const SizedBox(height: 22),
                _GridResumoAdmin(
                  usuarios: resumo['usuarios'] ?? 0,
                  psicologos: resumo['psicologos'] ?? 0,
                  pacientes: resumo['pacientes'] ?? 0,
                  admins: resumo['admins'] ?? 0,
                ),
                const SizedBox(height: 22),
                const _CardSaas(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TopoAdmin extends StatelessWidget {
  const _TopoAdmin();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Painel Administrativo',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Gerencie usuários, psicólogos e métricas do MindSteps.',
          style: TextStyle(
            color: AppColors.muted,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _GridResumoAdmin extends StatelessWidget {
  final int usuarios;
  final int psicologos;
  final int pacientes;
  final int admins;

  const _GridResumoAdmin({
    required this.usuarios,
    required this.psicologos,
    required this.pacientes,
    required this.admins,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.22,
      children: [
        _CardResumo('$usuarios', 'Usuários', LucideIcons.users, AppColors.softGreen),
        _CardResumo('$psicologos', 'Psicólogos', LucideIcons.brain, AppColors.softBlue),
        _CardResumo('$pacientes', 'Pacientes', LucideIcons.heartPulse, AppColors.softPurple),
        _CardResumo('$admins', 'Admins', LucideIcons.shieldCheck, AppColors.softOrange),
      ],
    );
  }
}

class _CardResumo extends StatelessWidget {
  final String valor;
  final String titulo;
  final IconData icone;
  final Color cor;

  const _CardResumo(this.valor, this.titulo, this.icone, this.cor);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: cor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icone, color: AppColors.primary, size: 20),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardSaas extends StatelessWidget {
  const _CardSaas();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            LucideIcons.sparkles,
            color: Colors.white,
            size: 30,
          ),
          SizedBox(height: 16),
          Text(
            'MindSteps SaaS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Acompanhe crescimento, usuários ativos e estrutura da plataforma.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}