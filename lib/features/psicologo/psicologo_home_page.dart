import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/auth/auth_storage.dart';
import '../../core/theme/app_theme.dart';
import '../../core/api/api_client.dart';
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
  bool aprovado = true;

  final pacientesKey = GlobalKey<PacientesPageState>();
  final atividadesKey = GlobalKey<AtividadesPageState>();

  late final List<Widget> paginas;

  @override
  void initState() {
    super.initState();
    _carregarAprovado();
    paginas = [
      const _DashboardPsicologo(),
      PacientesPage(key: pacientesKey),
      AtividadesPage(key: atividadesKey),
      const MaisPage(),
    ];
  }

  Future<void> _carregarAprovado() async {
    final status = await AuthStorage.obterAprovado();
    if (mounted) {
      setState(() => aprovado = status);
    }
    try {
      final me = await PsicologoService().obterMe();
      final apiStatus = me['aprovado'] ?? true;
      if (apiStatus != status && mounted) {
        await AuthStorage.salvarAprovado(apiStatus);
        setState(() => aprovado = apiStatus);
      }
    } catch (_) {}
  }

  void _onFabPressed() {
    if (paginaAtual == 1) {
      pacientesKey.currentState?.exibirDialogoCriar(context);
    } else if (paginaAtual == 2) {
      atividadesKey.currentState?.exibirDialogoCriar(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // FAB aparece em Pacientes (1) e Atividades (2) quando aprovado
    final bool temFab = (paginaAtual == 1 || paginaAtual == 2) && aprovado;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: IndexedStack(
          index: paginaAtual, // mapeamento direto: 0=Dashboard, 1=Pacientes, 2=Atividades, 3=Mais
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
      bottomNavigationBar: _CustomBottomNav(
        paginaAtual: paginaAtual,
        onTap: (index) {
          setState(() => paginaAtual = index);
        },
      ),
    );
  }
}

class _CustomBottomNav extends StatelessWidget {
  final int paginaAtual;
  final ValueChanged<int> onTap;

  const _CustomBottomNav({required this.paginaAtual, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF4F46E5);
    const inactiveColor = AppColors.muted;
    const activeBg = Color(0xFFEEF2FF);

    final items = [
      (icon: LucideIcons.house, label: 'In\u00edcio'),
      (icon: LucideIcons.users, label: 'Pacientes'),
      (icon: LucideIcons.clipboardList, label: 'Atividades'),
      (icon: Icons.more_horiz, label: 'Mais'),
    ];

    // Mapear paginaAtual -> navIndex
    // paginas: 0=Dashboard, 1=Pacientes, 2=Atividades, 3=Mais
    int navIndex = paginaAtual;
    if (paginaAtual > 3) navIndex = 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final item = items[i];
              final isSelected = navIndex == i;
              final color = isSelected ? activeColor : inactiveColor;

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? activeBg : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(item.icon, size: 22, color: color),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
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
        final bool isAprovado = resumo['aprovado'] ?? true;

        return RefreshIndicator(
          onRefresh: _recarregar,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TopoDashboard(
                  nome: resumo['nome'] ?? 'Psic\u00f3logo',
                  fotoUrl: resumo['fotoUrl'],
                ),
                const SizedBox(height: 20),
                if (!isAprovado) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.circleAlert, color: AppColors.warning, size: 24),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'Sua conta de psic\u00f3logo est\u00e1 aguardando aprova\u00e7\u00e3o pelo administrador. Recursos de cadastro de pacientes e de novas atividades est\u00e3o desabilitados at\u00e9 a valida\u00e7\u00e3o do seu CRP.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.text.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                const _BannerImpacto(),
                const SizedBox(height: 20),
                const _FeaturesGrid(),
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

  const _ErroDashboard({required this.erro, required this.onTentarNovamente});

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
              'N\u00e3o foi poss\u00edvel carregar o dashboard.',
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
  final String nome;
  final String? fotoUrl;
  const _TopoDashboard({required this.nome, this.fotoUrl});

  String? _obterUrlCompleta(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http')) return url;
    final baseUrl = ApiClient.dio.options.baseUrl;
    final domain = baseUrl.endsWith('/api')
        ? baseUrl.substring(0, baseUrl.length - 4)
        : baseUrl;
    return '$domain$url';
  }

  @override
  Widget build(BuildContext context) {
    final fotoCompleta = _obterUrlCompleta(fotoUrl);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/images/logo_horizontal.png',
                  height: 38,
                  fit: BoxFit.contain,
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Notifica\u00e7\u00f5es em desenvolvimento')),
                        );
                      },
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.bell, color: AppColors.danger, size: 20),
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PsicologoPerfilPage()),
                    ).then((_) {
                      // Se houver refresh automatico, isso ajudará
                    });
                  },
                  child: CircleAvatar(
                    radius: 21,
                    backgroundColor: AppColors.border,
                    backgroundImage: fotoCompleta != null ? NetworkImage(fotoCompleta) : null,
                    child: fotoCompleta == null ? const Icon(LucideIcons.user, color: AppColors.muted, size: 22) : null,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 22),
        Text(
          'Ola, $nome! \u{1F44B}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.text,
            letterSpacing: -0.5,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Obrigado por fazer parte do MindSteps.\nCada passo acompanhado pode ser o in\u00edcio de uma grande transforma\u00e7\u00e3o.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.muted,
            height: 1.4,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}



class _FeaturesGrid extends StatelessWidget {
  const _FeaturesGrid();

  void _mostrarDetalhes(
    BuildContext context,
    String titulo,
    String descricaoDetalhada,
    IconData icone,
    Color cor,
    Color bgCor,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: bgCor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icone, color: cor, size: 32),
              ),
              const SizedBox(height: 20),
              Text(
                titulo.replaceAll('\n', ' '),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                descricaoDetalhada,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.muted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Entendi', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.35,
      children: [
        _FeatureCard(
          titulo: 'Atividades\nTerapeuticas',
          descricao: 'Envie atividades baseadas em evid\u00eancias e fortaleça o processo terap\u00eautico.',
          icone: LucideIcons.clipboardCheck,
          iconeColor: const Color(0xFF0D9488),
          bgColor: const Color(0xFFECFDF5),
          iconeBgColor: const Color(0xFFD1FAE5),
          decoIcone: LucideIcons.clipboardList,
          onTap: () => _mostrarDetalhes(
            context,
            'Atividades Terapêuticas',
            'Envie formulários, questionários e tarefas baseadas em evidências para seus pacientes responderem entre as sessões. Acompanhe as respostas em tempo real.',
            LucideIcons.clipboardCheck,
            const Color(0xFF0D9488),
            const Color(0xFFD1FAE5),
          ),
        ),
        _FeatureCard(
          titulo: 'Jogos\nTerapeuticos',
          descricao: 'Desenvolva habilidades de forma l\u00fadica e engajadora.',
          icone: LucideIcons.gamepad2,
          iconeColor: const Color(0xFF7C3AED),
          bgColor: const Color(0xFFF5F3FF),
          iconeBgColor: const Color(0xFFEDE9FE),
          decoIcone: LucideIcons.gamepad2,
          onTap: () => _mostrarDetalhes(
            context,
            'Jogos Terapêuticos',
            'Prescreva jogos focados no desenvolvimento cognitivo, como controle inibitório e atenção seletiva, e acompanhe o desempenho através de scores.',
            LucideIcons.gamepad2,
            const Color(0xFF7C3AED),
            const Color(0xFFEDE9FE),
          ),
        ),
        _FeatureCard(
          titulo: 'Di\u00e1rio de Humor',
          descricao: 'Acompanhe emo\u00e7\u00f5es e identifique padr\u00f5es ao longo do tempo.',
          icone: LucideIcons.smile,
          iconeColor: const Color(0xFF2563EB),
          bgColor: const Color(0xFFEFF6FF),
          iconeBgColor: const Color(0xFFDBEAFE),
          decoIcone: LucideIcons.barChart2,
          onTap: () => _mostrarDetalhes(
            context,
            'Diário de Humor',
            'Os pacientes podem registrar emoções diárias. Use os gráficos gerados para identificar padrões e gatilhos emocionais nas próximas consultas.',
            LucideIcons.smile,
            const Color(0xFF2563EB),
            const Color(0xFFDBEAFE),
          ),
        ),
        _FeatureCard(
          titulo: 'Evolu\u00e7\u00e3o do\nPaciente',
          descricao: 'Visualize progresso, ades\u00e3o e indicadores para orientar suas interven\u00e7\u00f5es.',
          icone: LucideIcons.barChart2,
          iconeColor: const Color(0xFFD97706),
          bgColor: const Color(0xFFFFFBEB),
          iconeBgColor: const Color(0xFFFEF3C7),
          decoIcone: LucideIcons.trendingUp,
          onTap: () => _mostrarDetalhes(
            context,
            'Evolução do Paciente',
            'Acesse dashboards individuais com o histórico de adesão e progresso do paciente em todas as atividades propostas.',
            LucideIcons.barChart2,
            const Color(0xFFD97706),
            const Color(0xFFFEF3C7),
          ),
        ),
        _FeatureCard(
          titulo: 'Check-ins',
          descricao: 'Colete informa\u00e7\u00f5es r\u00e1pidas e mantenha o v\u00ednculo entre as sess\u00f5es.',
          icone: LucideIcons.messageCircle,
          iconeColor: const Color(0xFFDC2626),
          bgColor: const Color(0xFFFEF2F2),
          iconeBgColor: const Color(0xFFFEE2E2),
          decoIcone: LucideIcons.heart,
          onTap: () => _mostrarDetalhes(
            context,
            'Check-ins',
            'Envie perguntas rápidas para saber como o paciente está se sentindo ao longo da semana, fortalecendo a aliança terapêutica.',
            LucideIcons.messageCircle,
            const Color(0xFFDC2626),
            const Color(0xFFFEE2E2),
          ),
        ),
        _FeatureCard(
          titulo: 'Registros\nTerapeuticos',
          descricao: 'Use os registros como ponto de partida para sess\u00f5es mais produtivas.',
          icone: LucideIcons.fileText,
          iconeColor: const Color(0xFF4338CA),
          bgColor: const Color(0xFFEEF2FF),
          iconeBgColor: const Color(0xFFE0E7FF),
          decoIcone: LucideIcons.fileText,
          onTap: () => _mostrarDetalhes(
            context,
            'Registros Terapêuticos',
            'Os pacientes preenchem RPDs (Registro de Pensamentos Disfuncionais) e outros protocolos diretamente pelo app, chegando mais preparados para a sessão.',
            LucideIcons.fileText,
            const Color(0xFF4338CA),
            const Color(0xFFE0E7FF),
          ),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String titulo;
  final String descricao;
  final IconData icone;
  final Color iconeColor;
  final Color bgColor;
  final Color iconeBgColor;
  final IconData decoIcone;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.titulo,
    required this.descricao,
    required this.icone,
    required this.iconeColor,
    required this.bgColor,
    required this.iconeBgColor,
    required this.decoIcone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Material(
        color: bgColor,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              Positioned(
                bottom: -10,
                right: -10,
                child: Icon(decoIcone, size: 70, color: iconeColor.withValues(alpha: 0.09)),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: iconeBgColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(icone, color: iconeColor, size: 18),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            titulo,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      descricao,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BannerImpacto extends StatelessWidget {
  const _BannerImpacto();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 175,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFECEFFD), Color(0xFFF0F4FF)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: 22,
              left: 22,
              right: 175,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SEU IMPACTO IMPORTA',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF7C3AED),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pequenas a\u00e7\u00f5es,\ngrandes mudan\u00e7as.',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                      height: 1.1,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Voc\u00ea faz parte de hist\u00f3rias\nmais saud\u00e1veis todos os dias.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.text.withValues(alpha: 0.55),
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: SizedBox(
                height: 175,
                width: 165,
                child: Image.asset(
                  'assets/images/doctor_banner.jpg',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
            Positioned(
              top: 75,
              right: 12,
              child: Transform.rotate(
                angle: -0.15,
                child: Container(
                  width: 98,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Sa\u00fade mental\ntamb\u00e9m se\nconstr\u00f3i juntos.',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4338CA),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 140,
              right: 106,
              child: Icon(
                LucideIcons.heart,
                size: 15,
                color: const Color(0xFF7C3AED).withValues(alpha: 0.65),
              ),
            ),
          ],
        ),
      ),
    );
  }
}