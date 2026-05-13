import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import 'services/psicologo_service.dart';

class AtividadesPage extends StatefulWidget {
  const AtividadesPage({super.key});

  @override
  State<AtividadesPage> createState() => _AtividadesPageState();
}

class _AtividadesPageState extends State<AtividadesPage> {
  final service = PsicologoService();

  late Future<List<dynamic>> atividadesFuture;

  @override
  void initState() {
    super.initState();
    atividadesFuture = service.listarAtividadesDoPsicologo();
  }

  Future<void> _recarregar() async {
    setState(() {
      atividadesFuture = service.listarAtividadesDoPsicologo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: atividadesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Text(
                'Erro ao carregar atividades: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final atividades = snapshot.data ?? [];

        return RefreshIndicator(
          onRefresh: _recarregar,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Atividades',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Crie e acompanhe exercícios terapêuticos.',
                  style: TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 20),

                if (atividades.isEmpty)
                  const Text(
                    'Nenhuma atividade encontrada.',
                    style: TextStyle(color: AppColors.muted),
                  ),

                ...atividades.map((atividade) {
                  return _AtividadeCard(
                    titulo: atividade['titulo'] ?? 'Atividade',
                    descricao: atividade['descricao'] ?? 'Sem descrição',
                    tipo: atividade['tipo']?.toString() ?? '-',
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AtividadeCard extends StatelessWidget {
  final String titulo;
  final String descricao;
  final String tipo;

  const _AtividadeCard({
    required this.titulo,
    required this.descricao,
    required this.tipo,
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
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.softGreen,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              LucideIcons.clipboardList,
              color: AppColors.primary,
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
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  descricao,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tipo: $tipo',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
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