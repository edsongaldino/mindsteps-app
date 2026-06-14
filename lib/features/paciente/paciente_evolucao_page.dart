import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import 'paciente_home_page.dart';
import 'services/paciente_service.dart';

class PacienteEvolucaoPage extends StatefulWidget {
  final bool isActive;
  const PacienteEvolucaoPage({super.key, this.isActive = false});

  @override
  State<PacienteEvolucaoPage> createState() => _PacienteEvolucaoPageState();
}

class _PacienteEvolucaoPageState extends State<PacienteEvolucaoPage> with SingleTickerProviderStateMixin {
  @override
  void didUpdateWidget(covariant PacienteEvolucaoPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _recarregar();
    }
  }
  final service = PacienteService();
  late Future<Map<String, dynamic>> dadosFuture;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    dadosFuture = _carregar();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _carregar() async {
    final me = await service.obterMe();
    final checkins = await service.listarMeusCheckins();
    final registros = await service.listarMeusRegistrosPensamentos();
    final atividades = await service.listarMinhasAtividades();
    Map<String, dynamic> dashboard = {};
    try {
      dashboard = await service.obterDashboardTerapeutico();
    } catch (_) {}

    return {
      'me': me,
      'checkins': checkins,
      'registros': registros,
      'atividades': atividades,
      'dashboard': dashboard,
    };
  }

  Future<void> _recarregar() async {
    setState(() {
      dadosFuture = _carregar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: dadosFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Text(
                'Erro ao carregar evolução: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final dados = snapshot.data ?? {};
        final me = dados['me'] ?? {};
        final checkins = List<dynamic>.from(dados['checkins'] ?? []);
        final registros = List<dynamic>.from(dados['registros'] ?? []);
        final atividades = List<dynamic>.from(dados['atividades'] ?? []);
        final dashboard = Map<String, dynamic>.from(dados['dashboard'] ?? {});

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Meus progressos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(LucideIcons.arrowLeft),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  final state = context.findAncestorStateOfType<PacienteHomePageState>();
                  state?.mudarPagina(0);
                }
              },
            ),
          ),
          body: RefreshIndicator(
            onRefresh: _recarregar,
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.muted,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  tabs: const [
                    Tab(text: 'Clínico'),
                    Tab(text: 'Humor'),
                    Tab(text: 'XP & Conquistas'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _AbaDashboardClinico(dashboard: dashboard),
                      _AbaHumor(checkins: checkins),
                      _AbaAtividades(
                        atividades: atividades,
                        checkins: checkins,
                        registros: registros,
                        me: me,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AbaHumor extends StatelessWidget {
  final List<dynamic> checkins;

  const _AbaHumor({required this.checkins});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Variação de humor',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              Row(
                children: const [
                  Text(
                    'Últimos 7 dias',
                    style: TextStyle(color: AppColors.muted, fontSize: 13),
                  ),
                  SizedBox(width: 4),
                  Icon(LucideIcons.chevronDown, color: AppColors.muted, size: 16),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          const _GraficoHumorMock(),
          const SizedBox(height: 48),
          const Text(
            'Principais emoções',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 24),
          _BarraProgressoEmocao(
            nome: 'Ansiedade',
            valor: 0.75,
            cor: const Color(0xFFFF6B6B),
          ),
          const SizedBox(height: 16),
          _BarraProgressoEmocao(
            nome: 'Tristeza',
            valor: 0.45,
            cor: const Color(0xFF6B8EFF),
          ),
        ],
      ),
    );
  }
}

class _GraficoHumorMock extends StatelessWidget {
  const _GraficoHumorMock();

  @override
  Widget build(BuildContext context) {
    final pontos = [0.4, 0.5, 0.45, 0.6, 0.55, 0.65, 0.5];
    final dias = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 160,
          child: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Icon(LucideIcons.smile, color: AppColors.secondary, size: 20),
                  Icon(LucideIcons.meh, color: AppColors.warning, size: 20),
                  Icon(LucideIcons.frown, color: AppColors.danger, size: 20),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(height: 1, color: AppColors.border.withOpacity(0.5)),
                        Container(height: 1, color: AppColors.border.withOpacity(0.5)),
                        Container(height: 1, color: AppColors.border.withOpacity(0.5)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(pontos.length, (index) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              margin: EdgeInsets.only(bottom: 150 * pontos[index]),
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
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(left: 36),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(dias.length, (index) {
              return Text(
                dias[index],
                style: const TextStyle(fontSize: 12, color: AppColors.muted, fontWeight: FontWeight.w600),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _BarraProgressoEmocao extends StatelessWidget {
  final String nome;
  final double valor;
  final Color cor;

  const _BarraProgressoEmocao({
    required this.nome,
    required this.valor,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              nome,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: AppColors.text,
              ),
            ),
            Text(
              '${(valor * 100).toInt()}%',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.text,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 10,
          decoration: BoxDecoration(
            color: cor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.8 * valor,
                decoration: BoxDecoration(
                  color: cor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AbaAtividades extends StatelessWidget {
  final List<dynamic> atividades;
  final List<dynamic> checkins;
  final List<dynamic> registros;
  final Map<String, dynamic> me;

  const _AbaAtividades({
    required this.atividades,
    required this.checkins,
    required this.registros,
    required this.me,
  });

  @override
  Widget build(BuildContext context) {
    final concluidas = atividades.where((x) {
      final status = x['status'];
      return status == 3 ||
          status?.toString() == '3' ||
          status?.toString().toLowerCase() == 'concluida' ||
          status?.toString().toLowerCase() == 'concluído';
    }).toList();

    if (concluidas.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.softGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.clipboardCheck,
                  color: AppColors.primary,
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Nenhuma atividade concluída ainda',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Complete as atividades propostas pela sua psicóloga para ganhar pontos (XP) e subir de nível! Cada esforço te ajuda a avançar no seu processo.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.muted,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: () {
                  final state = context.findAncestorStateOfType<PacienteHomePageState>();
                  state?.mudarPagina(1);
                },
                icon: const Icon(LucideIcons.arrowRight, size: 16),
                label: const Text('Ir para atividades pendentes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final totalPontos = me['pontos'] ?? 0;
    final nivelPaciente = me['nivel'] ?? 1;

    // Calcular pontos detalhados
    final pontosAtividades = concluidas.fold<int>(0, (sum, item) {
      final nivel = item['nivel'] as int? ?? 1;
      return sum + ((nivel > 0 ? nivel : 1) * 10);
    });

    final datasCheckinUnicas = checkins.map((c) {
      final criadoEmStr = c['criadoEm'] ?? c['dataCriacao'] ?? '';
      try {
        final dt = DateTime.parse(criadoEmStr.toString()).toLocal();
        return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      } catch (_) {
        return '';
      }
    }).where((date) => date.isNotEmpty).toSet();

    final pontosCheckins = datasCheckinUnicas.length * 10;

    final registrosAvulsos = registros.where((r) => r['atividadePacienteId'] == null).toList();
    final pontosRegistros = registrosAvulsos.length * 15;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF11998E),
                  Color(0xFF38EF7D),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF11998E).withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.trophy,
                    color: Colors.amber,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nível $nivelPaciente • $totalPontos XP',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Você concluiu ${concluidas.length} atividades até agora. Continue assim!',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Detalhamento do XP',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 16),
                _LinhaDetalhamentoXP(
                  titulo: 'Atividades concluídas',
                  xp: pontosAtividades,
                  detalhe: '${concluidas.length} atividades',
                  icone: LucideIcons.clipboardCheck,
                  corIcone: AppColors.primary,
                ),
                const Divider(height: 24, color: AppColors.border),
                _LinhaDetalhamentoXP(
                  titulo: 'Check-ins diários',
                  xp: pontosCheckins,
                  detalhe: '${datasCheckinUnicas.length} dias ativos',
                  icone: LucideIcons.heartPulse,
                  corIcone: AppColors.secondary,
                ),
                const Divider(height: 24, color: AppColors.border),
                _LinhaDetalhamentoXP(
                  titulo: 'Registros de pensamentos',
                  xp: pontosRegistros,
                  detalhe: '${registrosAvulsos.length} diários avulsos',
                  icone: LucideIcons.brain,
                  corIcone: Colors.amber,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Histórico de conquistas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 16),
          ...concluidas.map((ativ) {
            final titulo = ativ['titulo'] ?? 'Atividade';
            final desc = ativ['descricao'] ?? '';
            final nivel = ativ['nivel'] as int? ?? 1;
            final xpGanhos = (nivel > 0 ? nivel : 1) * 10;
            final dataConclusaoStr = ativ['dataConclusao'];

            String dataFormatada = '';
            if (dataConclusaoStr != null) {
              try {
                final dt = DateTime.parse(dataConclusaoStr.toString()).toLocal();
                dataFormatada = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
              } catch (_) {
                dataFormatada = '';
              }
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.01),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                   Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.softGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      LucideIcons.circleCheck,
                      color: AppColors.secondary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titulo,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),
                        ),
                        if (desc.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            desc,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.muted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (dataFormatada.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Concluída em $dataFormatada',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.muted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF8E2DE2),
                          Color(0xFF4A00E0),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '+$xpGanhos XP',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _LinhaDetalhamentoXP extends StatelessWidget {
  final String titulo;
  final int xp;
  final String detalhe;
  final IconData icone;
  final Color corIcone;

  const _LinhaDetalhamentoXP({
    required this.titulo,
    required this.xp,
    required this.detalhe,
    required this.icone,
    required this.corIcone,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: corIcone.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icone, color: corIcone, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                detalhe,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
        Text(
          '+$xp XP',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _AbaDashboardClinico extends StatelessWidget {
  final Map<String, dynamic> dashboard;

  const _AbaDashboardClinico({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    final ansiedade = dashboard['ansiedade'] ?? {};
    final autoestima = dashboard['autoestima'] ?? {};
    final habSociais = dashboard['habilidadesSociais'] ?? {};
    final exposicao = dashboard['exposicao'] ?? {};
    final gatilhos = dashboard['gatilhos'] ?? {};
    final sabotadores = dashboard['sabotadores'] ?? {};

    final freqCatastrofes = ansiedade['frequenciaPensamentosCatastroficos'] ?? 0;
    final intMedia = ansiedade['intensidadeMedia'] ?? 0.0;
    final crencas = List<dynamic>.from(autoestima['crencasMaisEscolhidas'] ?? []);
    
    final assertivas = habSociais['respostasAssertivas'] ?? 0;
    final passivas = habSociais['respostasPassivas'] ?? 0;
    final agressivas = habSociais['respostasAgressivas'] ?? 0;
    final totalSociais = assertivas + passivas + agressivas;

    final expConcluidos = exposicao['desafiosConcluidos'] ?? 0;
    final expDesistencia = exposicao['taxaDesistencia'] ?? 0.0;

    final sabotadorMaisFreq = sabotadores['sabotadorMaisFrequente'] ?? 'Nenhum';

    final mapaGatilhos = Map<String, dynamic>.from(gatilhos['mapaGatilhos'] ?? {});
    final rankingGatilhos = List<dynamic>.from(gatilhos['rankingGatilhos'] ?? []);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Métricas Terapêuticas',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.text),
          ),
          const SizedBox(height: 4),
          const Text(
            'Acompanhe os dados de evolução gerados a partir dos seus jogos e check-ins.',
            style: TextStyle(color: AppColors.muted, fontSize: 13),
          ),
          const SizedBox(height: 24),

          // 1. CARD ANSIEDADE
          _buildCardMetrica(
            titulo: 'Ansiedade & Preocupação',
            icone: LucideIcons.frown,
            corIcone: Colors.red,
            child: Column(
              children: [
                _buildRowInfo('Pensamentos catastróficos identificados:', '$freqCatastrofes'),
                const SizedBox(height: 8),
                _buildRowInfo('Intensidade média das crises:', '$intMedia / 10'),
              ],
            ),
          ),

          // 2. CARD AUTOESTIMA
          _buildCardMetrica(
            titulo: 'Autoestima & Crenças',
            icone: LucideIcons.heart,
            corIcone: Colors.pink,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Crenças negativas mais frequentes:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textLight)),
                const SizedBox(height: 10),
                if (crencas.isEmpty)
                  const Text('Nenhuma crença registrada nos jogos ainda.', style: TextStyle(fontSize: 12, color: AppColors.muted))
                else
                  ...crencas.map((c) => Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text('• "${c['crenca']}"', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic))),
                            Text('${c['quantidade']}x', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          ],
                        ),
                      )),
              ],
            ),
          ),

          // 3. CARD HABILIDADES SOCIAIS
          _buildCardMetrica(
            titulo: 'Habilidades Sociais',
            icone: LucideIcons.users,
            corIcone: AppColors.secondary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Estilo de respostas no Semáforo:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textLight)),
                const SizedBox(height: 12),
                if (totalSociais == 0)
                  const Text('Nenhuma resposta registrada no Semáforo Emocional ainda.', style: TextStyle(fontSize: 12, color: AppColors.muted))
                else ...[
                  _buildProgressoSocial('Assertivas (Saudáveis)', assertivas, totalSociais, AppColors.success),
                  const SizedBox(height: 8),
                  _buildProgressoSocial('Passivas (Inseguras)', passivas, totalSociais, AppColors.warning),
                  const SizedBox(height: 8),
                  _buildProgressoSocial('Agressivas (Impulsivas)', agressivas, totalSociais, AppColors.danger),
                ],
              ],
            ),
          ),

          // 4. CARD EXPOSIÇÃO
          _buildCardMetrica(
            titulo: 'Exposição Gradual (Coragem)',
            icone: LucideIcons.rocket,
            corIcone: Colors.deepOrange,
            child: Column(
              children: [
                _buildRowInfo('Desafios concluídos:', '$expConcluidos'),
                const SizedBox(height: 8),
                _buildRowInfo('Taxa de desistência:', '$expDesistencia%'),
              ],
            ),
          ),

          // 5. CARD GATILHOS
          _buildCardMetrica(
            titulo: 'Caçador de Gatilhos',
            icone: LucideIcons.radar,
            corIcone: Colors.amber,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Locais/Gatilhos mapeados:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textLight)),
                const SizedBox(height: 10),
                if (mapaGatilhos.isEmpty)
                  const Text('Nenhum gatilho caçado ainda.', style: TextStyle(fontSize: 12, color: AppColors.muted))
                else
                  ...mapaGatilhos.entries.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('• ${e.key}', style: const TextStyle(fontSize: 12)),
                            Text('${e.value} ocorrências', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )),
              ],
            ),
          ),

          // 6. CARD SABOTADORES
          _buildCardMetrica(
            titulo: 'Sabotadores Frequentes',
            icone: LucideIcons.layers,
            corIcone: Colors.purple,
            child: Column(
              children: [
                _buildRowInfo('Sabotador mais ativo:', sabotadorMaisFreq),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardMetrica({
    required String titulo,
    required IconData icone,
    required Color corIcone,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: corIcone.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icone, color: corIcone, size: 20),
              ),
              const SizedBox(width: 12),
              Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.text)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildRowInfo(String label, String valor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textLight)),
        Text(valor, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.text)),
      ],
    );
  }

  Widget _buildProgressoSocial(String label, int valor, int total, Color cor) {
    final pct = total > 0 ? valor / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
            Text('${(pct * 100).toInt()}%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: cor)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 6,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation(cor),
          ),
        ),
      ],
    );
  }
}