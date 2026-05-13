import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import 'services/psicologo_service.dart';

class EnviarAtividadePage extends StatefulWidget {
  final String pacienteId;
  final String pacienteNome;

  const EnviarAtividadePage({
    super.key,
    required this.pacienteId,
    required this.pacienteNome,
  });

  @override
  State<EnviarAtividadePage> createState() => _EnviarAtividadePageState();
}

class _EnviarAtividadePageState extends State<EnviarAtividadePage> {
  final service = PsicologoService();

  late Future<List<dynamic>> atividadesFuture;

  String? atividadeSelecionadaId;
  DateTime? dataLimite;
  bool enviando = false;

  @override
  void initState() {
    super.initState();
    atividadesFuture = service.listarAtividadesDoPsicologo();
  }

  Future<void> enviar() async {
    if (atividadeSelecionadaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma atividade.')),
      );
      return;
    }

    try {
      setState(() => enviando = true);

      await service.enviarAtividadeParaPaciente(
        atividadeId: atividadeSelecionadaId!,
        pacienteId: widget.pacienteId,
        dataLimite: dataLimite,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Atividade enviada com sucesso.')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar atividade: $e')),
      );
    } finally {
      if (mounted) setState(() => enviando = false);
    }
  }

  Future<void> escolherDataLimite() async {
    final hoje = DateTime.now();

    final data = await showDatePicker(
      context: context,
      firstDate: hoje,
      lastDate: hoje.add(const Duration(days: 365)),
      initialDate: hoje.add(const Duration(days: 7)),
    );

    if (data != null) {
      setState(() => dataLimite = data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataLimiteTexto = dataLimite == null
        ? 'Sem data limite'
        : '${dataLimite!.day.toString().padLeft(2, '0')}/${dataLimite!.month.toString().padLeft(2, '0')}/${dataLimite!.year}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Enviar atividade'),
      ),
      body: FutureBuilder<List<dynamic>>(
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

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CardPaciente(nome: widget.pacienteNome),
                const SizedBox(height: 22),
                const Text(
                  'Escolha uma atividade',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 12),

                if (atividades.isEmpty)
                  const Text(
                    'Nenhuma atividade cadastrada.',
                    style: TextStyle(color: AppColors.muted),
                  ),

                ...atividades.map((item) {
                  final atividade = Map<String, dynamic>.from(item);
                  final id = atividade['id']?.toString() ?? '';
                  final titulo = atividade['titulo'] ?? 'Atividade';
                  final descricao = atividade['descricao'] ?? 'Sem descrição.';

                  return _AtividadeSelecionavelCard(
                    titulo: titulo,
                    descricao: descricao,
                    selecionada: atividadeSelecionadaId == id,
                    onTap: () => setState(() => atividadeSelecionadaId = id),
                  );
                }),

                const SizedBox(height: 18),

                _DataLimiteCard(
                  texto: dataLimiteTexto,
                  onTap: escolherDataLimite,
                ),

                const SizedBox(height: 22),

                ElevatedButton.icon(
                  onPressed: enviando ? null : enviar,
                  icon: enviando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(LucideIcons.send),
                  label: Text(enviando ? 'Enviando...' : 'Enviar atividade'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CardPaciente extends StatelessWidget {
  final String nome;

  const _CardPaciente({required this.nome});

  @override
  Widget build(BuildContext context) {
    final inicial = nome.isNotEmpty ? nome.substring(0, 1) : '?';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 27,
            backgroundColor: AppColors.softGreen,
            child: Text(
              inicial,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              nome,
              style: const TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w900,
                fontSize: 17,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AtividadeSelecionavelCard extends StatelessWidget {
  final String titulo;
  final String descricao;
  final bool selecionada;
  final VoidCallback onTap;

  const _AtividadeSelecionavelCard({
    required this.titulo,
    required this.descricao,
    required this.selecionada,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selecionada ? AppColors.primary : AppColors.border,
            width: selecionada ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selecionada ? LucideIcons.circleCheck : LucideIcons.clipboardList,
              color: selecionada ? AppColors.success : AppColors.primary,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w900,
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
          ],
        ),
      ),
    );
  }
}

class _DataLimiteCard extends StatelessWidget {
  final String texto;
  final VoidCallback onTap;

  const _DataLimiteCard({
    required this.texto,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.calendarDays, color: AppColors.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                texto,
                style: const TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const Icon(LucideIcons.chevronRight, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}