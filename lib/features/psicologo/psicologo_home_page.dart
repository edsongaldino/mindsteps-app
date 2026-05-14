import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import 'atividades_page.dart';
import 'mais_page.dart';
import 'pacientes_page.dart';
import 'relatorios_page.dart';
import 'services/psicologo_service.dart';

class PsicologoHomePage extends StatefulWidget {
  const PsicologoHomePage({super.key});

  @override
  State<PsicologoHomePage> createState() => _PsicologoHomePageState();
}

class _PsicologoHomePageState extends State<PsicologoHomePage> {
  int paginaAtual = 0;

  final paginas = const [
    _DashboardPsicologo(),
    PacientesPage(),
    AtividadesPage(),
    RelatoriosPage(),
    MaisPage(),
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: paginaAtual,
          onDestinationSelected: (index) {
            setState(() => paginaAtual = index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(LucideIcons.house),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.users),
              label: 'Pacientes',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.calendar),
              label: 'Atividades',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.fileText),
              label: 'Relatórios',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.ellipsis),
              label: 'Mais',
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardPsicologo extends StatefulWidget {
  const _DashboardPsicologo();

  @override
  State<_DashboardPsicologo> createState() => _DashboardPsicologoState();
}

class _DashboardPsicologoState extends State<_DashboardPsicologo> {
  final service = PsicologoService();

  late Future<Map<String, dynamic>> resumoFuture;

  @override
  void initState() {
    super.initState();
    resumoFuture = service.obterResumoDashboard();
  }

  Future<void> _recarregar() async {
    setState(() {
      resumoFuture = service.obterResumoDashboard();
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
          return _ErroDashboard(
            erro: snapshot.error.toString(),
            onTentarNovamente: _recarregar,
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
                const _TopoDashboard(),
                const SizedBox(height: 22),
                _GridResumo(
                  pacientesAtivos: resumo['pacientesAtivos'] ?? 0,
                  atividadesEnviadas: resumo['atividadesEnviadas'] ?? 0,
                  pendencias: resumo['pendencias'] ?? 0,
                  adesaoMedia: resumo['adesaoMedia'] ?? 0,
                ),
                const SizedBox(height: 22),
                const _CardHumorSemana(),
                const SizedBox(height: 18),
                _BotaoPrincipal(
                  texto: 'Ver meus pacientes',
                  onPressed: () {
                    final state = context.findAncestorStateOfType<_PsicologoHomePageState>();
                    state?.setState(() {
                      state.paginaAtual = 1;
                    });
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

class _ErroDashboard extends StatelessWidget {
  final String erro;
  final VoidCallback onTentarNovamente;

  const _ErroDashboard({
    required this.erro,
    required this.onTentarNovamente,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              LucideIcons.circleAlert,
              color: AppColors.danger,
              size: 42,
            ),
            const SizedBox(height: 14),
            const Text(
              'Não foi possível carregar o dashboard.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              erro,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: onTentarNovamente,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopoDashboard extends StatelessWidget {
  const _TopoDashboard();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Olá, Psicóloga!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Aqui está o resumo da sua clínica hoje.',
                style: TextStyle(fontSize: 13, color: AppColors.muted),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: null,
          icon: Icon(LucideIcons.bell, color: AppColors.text),
        ),
      ],
    );
  }
}

class _GridResumo extends StatelessWidget {
  final int pacientesAtivos;
  final int atividadesEnviadas;
  final int pendencias;
  final int adesaoMedia;

  const _GridResumo({
    required this.pacientesAtivos,
    required this.atividadesEnviadas,
    required this.pendencias,
    required this.adesaoMedia,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _CardResumo(
          '$pacientesAtivos',
          'Pacientes ativos',
          LucideIcons.users,
          AppColors.softGreen,
        ),
        _CardResumo(
          '$atividadesEnviadas',
          'Atividades enviadas',
          LucideIcons.calendar,
          const Color(0xFFF0ECFF),
        ),
        _CardResumo(
          '$pendencias',
          'Pendências',
          LucideIcons.clock,
          const Color(0xFFFFF3E3),
        ),
        _CardResumo(
          '$adesaoMedia%',
          'Adesão média',
          LucideIcons.trendingUp,
          const Color(0xFFEAF4F7),
        ),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icone, color: AppColors.primary, size: 18),
              ),
            ],
          ),
          const Spacer(),
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.muted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardHumorSemana extends StatelessWidget {
  const _CardHumorSemana();

  @override
  Widget build(BuildContext context) {
    final pontos = [0.4, 0.5, 0.45, 0.6, 0.55, 0.65, 0.5];
    final dias = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Humor médio da semana',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              const Icon(LucideIcons.smile, color: AppColors.success, size: 20),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 120,
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                      3,
                      (index) => Container(
                            height: 1,
                            color: AppColors.border.withOpacity(0.5),
                          )),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(pontos.length, (index) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            margin: EdgeInsets.only(bottom: 100 * pontos[index]),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(dias.length, (index) {
              return Text(
                dias[index],
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w500,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _BotaoPrincipal extends StatelessWidget {
  final String texto;
  final VoidCallback onPressed;

  const _BotaoPrincipal({
    required this.texto,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(texto),
    );
  }
}