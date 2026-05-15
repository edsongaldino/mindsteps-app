import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import 'services/psicologo_service.dart';

class PacienteDetalhePage extends StatefulWidget {
  final String pacienteId;
  final String nome;

  const PacienteDetalhePage({
    super.key,
    required this.pacienteId,
    required this.nome,
  });

  @override
  State<PacienteDetalhePage> createState() => _PacienteDetalhePageState();
}

class _PacienteDetalhePageState extends State<PacienteDetalhePage> with SingleTickerProviderStateMixin {
  final service = PsicologoService();
  late Future<Map<String, dynamic>> dadosFuture;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    dadosFuture = _carregarDados();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _carregarDados() async {
    final paciente = await service.obterPacientePorId(widget.pacienteId);
    final checkins = await service.listarCheckinsPaciente(widget.pacienteId);
    final registros = await service.listarRegistrosPensamentosPaciente(widget.pacienteId);

    return {
      'paciente': paciente,
      'checkins': checkins,
      'registros': registros,
    };
  }

  Future<void> _recarregar() async {
    setState(() {
      dadosFuture = _carregarDados();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.text),
            onPressed: () {},
          ),
        ],
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: dadosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final dados = snapshot.data!;
          final checkins = List<dynamic>.from(dados['checkins'] ?? []);
          final registros = List<dynamic>.from(dados['registros'] ?? []);

          return RefreshIndicator(
            onRefresh: _recarregar,
            child: Column(
              children: [
                _CabecalhoPaciente(nome: widget.nome),
                const SizedBox(height: 24),
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.muted,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  tabs: const [
                    Tab(text: 'Resumo'),
                    Tab(text: 'Atividades'),
                    Tab(text: 'Evolução'),
                    Tab(text: 'Anotações'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _AbaResumo(checkins: checkins, registros: registros),
                      const Center(child: Text('Atividades', style: TextStyle(color: AppColors.muted))),
                      const Center(child: Text('Evolução', style: TextStyle(color: AppColors.muted))),
                      const Center(child: Text('Anotações', style: TextStyle(color: AppColors.muted))),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CabecalhoPaciente extends StatelessWidget {
  final String nome;

  const _CabecalhoPaciente({required this.nome});

  @override
  Widget build(BuildContext context) {
    final inicial = nome.isNotEmpty ? nome.substring(0, 1) : '?';

    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: AppColors.softGreen,
          child: Text(
            inicial,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          nome,
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          '28 anos • Atendimento semanal',
          style: TextStyle(
            color: AppColors.muted,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.softGreen,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Ativa',
            style: TextStyle(
              color: AppColors.secondary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _AbaResumo extends StatelessWidget {
  final List<dynamic> checkins;
  final List<dynamic> registros;

  const _AbaResumo({required this.checkins, required this.registros});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumo geral',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ItemEstatistica('Adesão média', '85%'),
              _ItemEstatistica('Atividades concluídas', '24 / 26'),
              _ItemEstatistica('Check-ins', '18 / 20'),
            ],
          ),
          const SizedBox(height: 32),
          const _GraficoHumorMock(),
          const SizedBox(height: 32),
          const Text(
            'Últimas atividades',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text),
          ),
          const SizedBox(height: 16),
          _ItemAtividade(
            titulo: 'Registro de pensamentos',
            subtitulo: 'Concluída em 12/05',
            icone: Icons.check_circle,
            corIcone: AppColors.secondary,
            iconeAcao: 'Ver',
          ),
          _ItemAtividade(
            titulo: 'Check-in Emocional',
            subtitulo: 'Concluída em 10/05',
            icone: Icons.check_circle,
            corIcone: AppColors.secondary,
            iconeAcao: 'Ver',
          ),
        ],
      ),
    );
  }
}

class _ItemEstatistica extends StatelessWidget {
  final String label;
  final String valor;

  const _ItemEstatistica(this.label, this.valor);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          valor,
          style: const TextStyle(fontSize: 18, color: AppColors.text, fontWeight: FontWeight.w800),
        ),
      ],
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
        const Text(
          'Humor médio',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 140,
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
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(left: 36),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(dias.length, (index) {
              return Text(
                dias[index],
                style: const TextStyle(fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w500),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _ItemAtividade extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final IconData icone;
  final Color corIcone;
  final String iconeAcao;

  const _ItemAtividade({
    required this.titulo,
    required this.subtitulo,
    required this.icone,
    required this.corIcone,
    required this.iconeAcao,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: corIcone.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icone, color: corIcone, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.text),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitulo,
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              iconeAcao,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}