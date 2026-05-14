import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import 'paciente_atividades_page.dart';
import 'paciente_checkin_page.dart';
import 'paciente_evolucao_page.dart';
import 'paciente_perfil_page.dart';
import 'paciente_registro_pensamento_page.dart';
import 'services/paciente_service.dart';

class PacienteHomePage extends StatefulWidget {
  const PacienteHomePage({super.key});

  @override
  State<PacienteHomePage> createState() => PacienteHomePageState();
}

class PacienteHomePageState extends State<PacienteHomePage> {
  int paginaAtual = 0;

  final paginas = const [
    _DashboardPaciente(),
    PacienteAtividadesPage(),
    PacienteCheckinPage(),
    PacienteEvolucaoPage(),
    PacientePerfilPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: IndexedStack(
          index: paginaAtual,
          children: paginas,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: paginaAtual,
        onDestinationSelected: (index) {
          setState(() => paginaAtual = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(LucideIcons.house),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.clipboardList),
            label: 'Atividades',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.heartPulse),
            label: 'Check-in',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.chartNoAxesColumn),
            label: 'Evolução',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.user),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class _DashboardPaciente extends StatefulWidget {
  const _DashboardPaciente();

  @override
  State<_DashboardPaciente> createState() => _DashboardPacienteState();
}

class _DashboardPacienteState extends State<_DashboardPaciente> {
  final service = PacienteService();

  late Future<Map<String, dynamic>> resumoFuture;

  @override
  void initState() {
    super.initState();
    resumoFuture = service.obterResumoHome();
    _verificarCheckinHoje();
  }

  Future<void> _verificarCheckinHoje() async {
    try {
      final jaFez = await service.verificarCheckinHoje();
      if (!jaFez && mounted) {
        // Redireciona para a página de check-in (índice 2)
        final state = context.findAncestorStateOfType<PacienteHomePageState>();
        state?.setState(() => state.paginaAtual = 2);
      }
    } catch (e) {
      debugPrint('Erro ao verificar check-in hoje: $e');
    }
  }

  Future<void> _recarregar() async {
    setState(() {
      resumoFuture = service.obterResumoHome();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: resumoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Text(
                'Erro ao carregar dados: ${snapshot.error}',
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
                const _TopoPaciente(),
                const SizedBox(height: 22),
                const _CardMensagemDia(),
                const SizedBox(height: 22),

                _GridResumoPaciente(
                  atividades: resumo['atividades'] ?? 0,
                  concluidas: resumo['concluidas'] ?? 0,
                  checkins: resumo['checkins'] ?? 0,
                  humorMedio: resumo['humorMedio'] ?? '-',
                ),

                const SizedBox(height: 22),
                const _CardAtividadeHoje(),
                const SizedBox(height: 18),
                _BotaoPrincipal(
                  texto: 'Registrar pensamento (TCC)',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PacienteRegistroPensamentoPage(),
                      ),
                    ).then((_) => _recarregar());
                  },
                  cor: AppColors.softPurple,
                ),
                const SizedBox(height: 12),
                _BotaoPrincipal(
                  texto: 'Fazer check-in agora',
                  onPressed: () {
                    final state = context.findAncestorStateOfType<PacienteHomePageState>();
                    state?.setState(() => state.paginaAtual = 2);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TopoPaciente extends StatelessWidget {
  const _TopoPaciente();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Olá!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Como você está se sentindo hoje?',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: null,
          icon: Icon(
            LucideIcons.bell,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }
}

class _CardMensagemDia extends StatelessWidget {
  const _CardMensagemDia();

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
            'Um passo de cada vez.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Hoje você não precisa resolver tudo.',
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

class _GridResumoPaciente extends StatelessWidget {
  final int atividades;
  final int concluidas;
  final int checkins;
  final String humorMedio;

  const _GridResumoPaciente({
    required this.atividades,
    required this.concluidas,
    required this.checkins,
    required this.humorMedio,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.25,
      children: [
        _CardResumoPaciente(
          valor: '$atividades',
          titulo: 'Atividades',
          icone: LucideIcons.clipboardList,
          cor: AppColors.softGreen,
        ),
        _CardResumoPaciente(
          valor: '$concluidas',
          titulo: 'Concluídas',
          icone: LucideIcons.circleCheck,
          cor: AppColors.softBlue,
        ),
        _CardResumoPaciente(
          valor: '$checkins',
          titulo: 'Check-ins',
          icone: LucideIcons.heartPulse,
          cor: AppColors.softOrange,
        ),
        _CardResumoPaciente(
          valor: humorMedio,
          titulo: 'Humor médio',
          icone: LucideIcons.smile,
          cor: AppColors.softPurple,
        ),
      ],
    );
  }
}

class _CardResumoPaciente extends StatelessWidget {
  final String valor;
  final String titulo;
  final IconData icone;
  final Color cor;

  const _CardResumoPaciente({
    required this.valor,
    required this.titulo,
    required this.icone,
    required this.cor,
  });

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
              child: Icon(
                icone,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 24,
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

class _CardAtividadeHoje extends StatelessWidget {
  const _CardAtividadeHoje();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.softGreen,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              LucideIcons.bookOpen,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Atividade de hoje',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Continue avançando no seu processo.',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            LucideIcons.chevronRight,
            color: AppColors.muted,
          ),
        ],
      ),
    );
  }
}

class _BotaoPrincipal extends StatelessWidget {
  final String texto;
  final VoidCallback onPressed;
  final Color? cor;

  const _BotaoPrincipal({
    required this.texto,
    required this.onPressed,
    this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: cor != null
            ? ElevatedButton.styleFrom(
                backgroundColor: cor,
                foregroundColor: AppColors.primary,
                elevation: 0,
              )
            : null,
        child: Text(texto),
      ),
    );
  }
}