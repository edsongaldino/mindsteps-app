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

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Atividades da semana', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(LucideIcons.arrowLeft),
              onPressed: () => Navigator.pop(context),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(24),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text('12 a 18 de maio', style: TextStyle(color: AppColors.muted, fontSize: 13)),
              ),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: _recarregar,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      const _FiltroChip('Todas (5)', true),
                      const _FiltroChip('Pendentes (2)', false),
                      const _FiltroChip('Concluídas (3)', false),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (atividades.isEmpty)
                    const Text('Nenhuma atividade encontrada.', style: TextStyle(color: AppColors.muted)),

                  ...atividades.asMap().entries.map((entry) {
                    final int index = entry.key;
                    final atividade = Map<String, dynamic>.from(entry.value);

                    final titulo = atividade['atividade']?['titulo'] ?? atividade['titulo'] ?? 'Atividade';
                    final descricao = atividade['atividade']?['descricao'] ?? atividade['descricao'] ?? 'Descrição';
                    final status = atividade['status'];
                    
                    final icones = [
                      LucideIcons.brain,
                      LucideIcons.footprints,
                      LucideIcons.heartPulse,
                      LucideIcons.sun,
                      LucideIcons.calendarClock,
                    ];

                    return _AtividadePacienteCard(
                      titulo: titulo,
                      descricao: 'Segunda • 12/05', // Mock data from layout
                      status: _statusTexto(status),
                      concluida: _estaConcluida(status),
                      icone: icones[index % icones.length],
                      onTap: () => _abrirAtividade(atividade),
                    );
                  }),
                ],
              ),
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
    if (_estaConcluida(status)) return 'Concluída';
    if (status == 1 || status?.toString().toLowerCase() == 'pendente') return 'Pendente';
    return 'Em andamento';
  }
}

class _FiltroChip extends StatelessWidget {
  final String label;
  final bool selected;

  const _FiltroChip(this.label, this.selected);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? AppColors.softGreen : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? AppColors.secondary : AppColors.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? AppColors.primary : AppColors.muted,
          fontWeight: selected ? FontWeight.bold : FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _AtividadePacienteCard extends StatelessWidget {
  final String titulo;
  final String descricao;
  final String status;
  final bool concluida;
  final IconData icone;
  final VoidCallback onTap;

  const _AtividadePacienteCard({
    required this.titulo,
    required this.descricao,
    required this.status,
    required this.concluida,
    required this.icone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: concluida ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: concluida ? AppColors.secondary.withOpacity(0.5) : AppColors.border),
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
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: concluida ? AppColors.softGreen : const Color(0xFFF0ECFF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icone,
                color: concluida ? AppColors.secondary : AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
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
                ],
              ),
            ),
            if (concluida)
              const Icon(LucideIcons.check, color: AppColors.secondary, size: 24)
            else
              Text(
                'Pendente',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}