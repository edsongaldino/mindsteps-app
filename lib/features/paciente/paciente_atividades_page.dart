import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import 'paciente_responder_atividade_page.dart';
import 'services/paciente_service.dart';

class PacienteAtividadesPage extends StatefulWidget {
  const PacienteAtividadesPage({super.key});

  @override
  State<PacienteAtividadesPage> createState() => _PacienteAtividadesPageState();
}

class _PacienteAtividadesPageState extends State<PacienteAtividadesPage> {
  final service = PacienteService();

  late Future<List<dynamic>> atividadesFuture;

  @override
  void initState() {
    super.initState();
    atividadesFuture = service.listarMinhasAtividades();
  }

  Future<void> _recarregar() async {
    setState(() {
      atividadesFuture = service.listarMinhasAtividades();
    });
  }

  Future<void> _abrirAtividade(Map<String, dynamic> atividade) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PacienteResponderAtividadePage(
          atividadePacienteId: atividade['id']?.toString() ?? '',
          titulo: atividade['atividade']?['titulo'] ??
              atividade['titulo'] ??
              'Atividade',
          descricao: atividade['atividade']?['descricao'] ??
              atividade['descricao'] ??
              'Sem descrição.',
        ),
      ),
    );

    if (resultado == true) {
      await _recarregar();
    }
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
                  'Minhas atividades',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Exercícios enviados pelo seu psicólogo.',
                  style: TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 20),

                if (atividades.isEmpty)
                  const Text(
                    'Nenhuma atividade encontrada.',
                    style: TextStyle(color: AppColors.muted),
                  ),

                ...atividades.map((item) {
                  final atividade = Map<String, dynamic>.from(item);

                  final titulo = atividade['atividade']?['titulo'] ??
                      atividade['titulo'] ??
                      'Atividade';

                  final descricao = atividade['atividade']?['descricao'] ??
                      atividade['descricao'] ??
                      'Sem descrição.';

                  final status = atividade['status'];

                  return _AtividadePacienteCard(
                    titulo: titulo,
                    descricao: descricao,
                    status: _statusTexto(status),
                    concluida: _estaConcluida(status),
                    onTap: () => _abrirAtividade(atividade),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  static bool _estaConcluida(dynamic status) {
    return status == 2 ||
        status?.toString().toLowerCase() == 'concluida' ||
        status?.toString().toLowerCase() == 'concluído';
  }

  static String _statusTexto(dynamic status) {
    if (_estaConcluida(status)) {
      return 'Concluída';
    }

    if (status == 1 || status?.toString().toLowerCase() == 'pendente') {
      return 'Pendente';
    }

    return 'Em andamento';
  }
}

class _AtividadePacienteCard extends StatelessWidget {
  final String titulo;
  final String descricao;
  final String status;
  final bool concluida;
  final VoidCallback onTap;

  const _AtividadePacienteCard({
    required this.titulo,
    required this.descricao,
    required this.status,
    required this.concluida,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final corStatus = concluida ? AppColors.success : AppColors.warning;

    return GestureDetector(
      onTap: concluida ? null : onTap,
      child: Opacity(
        opacity: concluida ? 0.72 : 1,
        child: Container(
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
                child: Icon(
                  concluida ? LucideIcons.circleCheck : LucideIcons.clipboardList,
                  color: concluida ? AppColors.success : AppColors.primary,
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
                      status,
                      style: TextStyle(
                        color: corStatus,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                concluida ? LucideIcons.check : LucideIcons.chevronRight,
                color: concluida ? AppColors.success : AppColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}