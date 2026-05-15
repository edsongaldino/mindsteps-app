import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import 'services/paciente_service.dart';

class PacienteEvolucaoPage extends StatefulWidget {
  const PacienteEvolucaoPage({super.key});

  @override
  State<PacienteEvolucaoPage> createState() => _PacienteEvolucaoPageState();
}

class _PacienteEvolucaoPageState extends State<PacienteEvolucaoPage> with SingleTickerProviderStateMixin {
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
    final checkins = await service.listarMeusCheckins();
    final registros = await service.listarMeusRegistrosPensamentos();
    final atividades = await service.listarMinhasAtividades();

    return {
      'checkins': checkins,
      'registros': registros,
      'atividades': atividades,
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
        final checkins = List<dynamic>.from(dados['checkins'] ?? []);
        final registros = List<dynamic>.from(dados['registros'] ?? []);
        final atividades = List<dynamic>.from(dados['atividades'] ?? []);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Meus progressos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(LucideIcons.arrowLeft),
              onPressed: () => Navigator.pop(context),
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
                    Tab(text: 'Humor'),
                    Tab(text: 'Atividades'),
                    Tab(text: 'Sintomas'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _AbaHumor(checkins: checkins),
                      const Center(child: Text('Atividades', style: TextStyle(color: AppColors.muted))),
                      const Center(child: Text('Sintomas', style: TextStyle(color: AppColors.muted))),
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