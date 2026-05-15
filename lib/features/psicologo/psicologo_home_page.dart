import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import 'atividades_page.dart';
import 'mais_page.dart';
import 'pacientes_page.dart';
import 'perfil_page.dart';
import 'services/psicologo_service.dart';

class PsicologoHomePage extends StatefulWidget {
  const PsicologoHomePage({super.key});

  @override
  State<PsicologoHomePage> createState() => _PsicologoHomePageState();
}

class _PsicologoHomePageState extends State<PsicologoHomePage> {
  int paginaAtual = 0;

  final pacientesKey = GlobalKey<PacientesPageState>();
  final atividadesKey = GlobalKey<AtividadesPageState>();

  late final List<Widget> paginas;

  @override
  void initState() {
    super.initState();
    paginas = [
      const _DashboardPsicologo(),
      PacientesPage(key: pacientesKey),
      AtividadesPage(key: atividadesKey),
      const MaisPage(),
    ];
  }

  void _onFabPressed() {
    if (paginaAtual == 1) {
      pacientesKey.currentState?.exibirDialogoCriar(context);
    } else if (paginaAtual == 3) {
      atividadesKey.currentState?.exibirDialogoCriar(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool temFab = paginaAtual == 1 || paginaAtual == 3;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: IndexedStack(
          index: paginaAtual > 2 ? paginaAtual - 1 : paginaAtual,
          children: paginas,
        ),
      ),
      floatingActionButton: temFab
          ? FloatingActionButton(
              onPressed: _onFabPressed,
              backgroundColor: AppColors.secondary,
              elevation: 4,
              shape: const CircleBorder(),
              child: const Icon(LucideIcons.plus, color: Colors.white, size: 28),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: paginaAtual,
          onTap: (index) {
            if (index == 2) {
              if (!temFab) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PsicologoPerfilPage()),
                );
              }
            } else {
              setState(() => paginaAtual = index);
            }
          },
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.muted,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          elevation: 20,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(LucideIcons.house, size: 24),
              label: 'Dashboard',
            ),
            const BottomNavigationBarItem(
              icon: Icon(LucideIcons.users, size: 24),
              label: 'Pacientes',
            ),
            BottomNavigationBarItem(
              icon: temFab
                  ? const Icon(Icons.circle, color: Colors.transparent)
                  : const Icon(LucideIcons.user, size: 24),
              label: temFab ? '' : 'Perfil',
            ),
            const BottomNavigationBarItem(
              icon: Icon(LucideIcons.clipboardList, size: 24),
              label: 'Atividades',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz, size: 24),
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
          return const Center(child: CircularProgressIndicator());
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
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _TopoDashboard(),
                const SizedBox(height: 32),
                _GridResumo(
                  pacientesAtivos: resumo['pacientesAtivos'] ?? 0,
                  atividadesEnviadas: resumo['atividadesEnviadas'] ?? 0,
                  pendencias: resumo['pendencias'] ?? 0,
                  adesaoMedia: resumo['adesaoMedia'] ?? 0,
                ),
                const SizedBox(height: 32),
                const _CardHumorSemana(),
                const SizedBox(height: 32),
                const Text(
                  'Atividades pendentes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '5 atividades aguardando respostas',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 16),
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
            const Icon(LucideIcons.circleAlert, color: AppColors.danger, size: 42),
            const SizedBox(height: 14),
            const Text(
              'Não foi possível carregar o dashboard.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.text),
            ),
            const SizedBox(height: 8),
            Text(
              erro,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
            const SizedBox(height: 18),
            ElevatedButton(onPressed: onTentarNovamente, child: const Text('Tentar novamente')),
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
                'Olá, Ana! 👋',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Aqui está o resumo da sua clínica.',
                style: TextStyle(fontSize: 14, color: AppColors.muted),
              ),
            ],
          ),
        ),
        Stack(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(LucideIcons.bell, color: AppColors.primary, size: 28),
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.warning,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
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
      childAspectRatio: 1.1,
      children: [
        _CardResumo(
          '$pacientesAtivos',
          'Pacientes ativos',
          LucideIcons.users,
        ),
        _CardResumo(
          '$atividadesEnviadas',
          'Atividades\nenviadas',
          LucideIcons.fileText,
        ),
        _CardResumo(
          '$pendencias',
          'Pendências',
          LucideIcons.clock,
          isAlert: true,
        ),
        _CardResumo(
          '$adesaoMedia%',
          'Adesão média',
          LucideIcons.trendingUp,
          isSuccess: true,
        ),
      ],
    );
  }
}

class _CardResumo extends StatelessWidget {
  final String valor;
  final String titulo;
  final IconData icone;
  final bool isAlert;
  final bool isSuccess;

  const _CardResumo(
    this.valor,
    this.titulo,
    this.icone, {
    this.isAlert = false,
    this.isSuccess = false,
  });

  @override
  Widget build(BuildContext context) {
    Color iconColor = AppColors.primary;
    if (isAlert) iconColor = AppColors.danger;
    if (isSuccess) iconColor = AppColors.secondary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icone, color: iconColor, size: 20),
              ),
            ],
          ),
          const Spacer(),
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.muted,
              fontWeight: FontWeight.w600,
              height: 1.2,
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
    final pontos = [0.3, 0.4, 0.35, 0.5, 0.45, 0.7, 0.6];
    final dias = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              Icon(LucideIcons.smile, color: AppColors.secondary, size: 20),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 140,
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _linhaGuia('5'),
                    _linhaGuia('4'),
                    _linhaGuia('3'),
                    _linhaGuia('2'),
                    _linhaGuia('1'),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24, right: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(pontos.length, (index) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            margin: EdgeInsets.only(bottom: 130 * pontos[index]),
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
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(dias.length, (index) {
                return Text(
                  dias[index],
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _linhaGuia(String num) {
    return Row(
      children: [
        SizedBox(
          width: 16,
          child: Text(
            num,
            style: const TextStyle(color: AppColors.muted, fontSize: 10),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.border.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}