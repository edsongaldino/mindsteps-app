import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import 'services/paciente_service.dart';

class PacienteEvolucaoPage extends StatefulWidget {
  const PacienteEvolucaoPage({super.key});

  @override
  State<PacienteEvolucaoPage> createState() => _PacienteEvolucaoPageState();
}

class _PacienteEvolucaoPageState extends State<PacienteEvolucaoPage> {
  final service = PacienteService();

  late Future<Map<String, dynamic>> dadosFuture;

  @override
  void initState() {
    super.initState();
    dadosFuture = _carregar();
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

        return RefreshIndicator(
          onRefresh: _recarregar,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Minha evolução',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Acompanhe seus pequenos avanços.',
                  style: TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 22),
                _CardGraficoEvolucao(checkins: checkins),
                const SizedBox(height: 18),
                _ResumoItem(
                  titulo: 'Atividades recebidas',
                  valor: '${atividades.length}',
                  icone: LucideIcons.clipboardList,
                ),
                _ResumoItem(
                  titulo: 'Check-ins realizados',
                  valor: '${checkins.length}',
                  icone: LucideIcons.heartPulse,
                ),
                _ResumoItem(
                  titulo: 'Registros cognitivos',
                  valor: '${registros.length}',
                  icone: LucideIcons.brain,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CardGraficoEvolucao extends StatelessWidget {
  final List<dynamic> checkins;

  const _CardGraficoEvolucao({
    required this.checkins,
  });

  @override
  Widget build(BuildContext context) {
    final ultimos = checkins.take(7).toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Humor recente',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 22),
          if (ultimos.isEmpty)
            const Text(
              'Nenhum check-in encontrado.',
              style: TextStyle(color: AppColors.muted),
            )
          else
            SizedBox(
              height: 170,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(ultimos.length, (index) {
                  final item = ultimos[index];
                  final humor = item['humor'] ?? 1;
                  final valor = ((humor as num) / 5).clamp(0.15, 1.0).toDouble();

                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 18,
                          height: 110 * valor,
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}

class _ResumoItem extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icone;

  const _ResumoItem({
    required this.titulo,
    required this.valor,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
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