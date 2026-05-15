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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nova atividade', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: atividadesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar atividades: ${snapshot.error}'));
          }

          final atividades = snapshot.data ?? [];

          return Column(
            children: [
              _buildStepper(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Escolha o tipo de atividade',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.text),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Selecione o formato da atividade que deseja criar.',
                        style: TextStyle(fontSize: 14, color: AppColors.muted),
                      ),
                      const SizedBox(height: 24),
                      if (atividades.isEmpty)
                        const Text('Nenhuma atividade cadastrada.', style: TextStyle(color: AppColors.muted)),
                      ...atividades.asMap().entries.map((entry) {
                        int index = entry.key;
                        final atividade = Map<String, dynamic>.from(entry.value);
                        final id = atividade['id']?.toString() ?? '';
                        final titulo = atividade['titulo'] ?? 'Atividade';
                        final descricao = atividade['descricao'] ?? 'Descrição';

                        // Cores alternadas baseadas no índice para simular o mockup
                        final cores = [
                          const Color(0xFFF0ECFF), // Roxo claro
                          const Color(0xFFFFF3E3), // Laranja claro
                          const Color(0xFFFFF9E6), // Amarelo claro
                          const Color(0xFFE6F5F2), // Verde claro
                          const Color(0xFFEAF4F7), // Azul claro
                        ];
                        final icones = [
                          LucideIcons.brain,
                          LucideIcons.messageSquare,
                          LucideIcons.dumbbell,
                          LucideIcons.checkSquare,
                          LucideIcons.headphones,
                        ];

                        return _AtividadeSelecionavelCard(
                          titulo: titulo,
                          descricao: descricao,
                          selecionada: atividadeSelecionadaId == id,
                          corFundoIcone: cores[index % cores.length],
                          icone: icones[index % icones.length],
                          onTap: () => setState(() => atividadeSelecionadaId = id),
                        );
                      }),
                      const SizedBox(height: 100), // Espaço pro botão fixo
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
          ],
        ),
        child: ElevatedButton(
          onPressed: enviando ? null : enviar,
          child: enviando
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white))
              : const Text('Próximo'),
        ),
      ),
    );
  }

  Widget _buildStepper() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _stepItem('Tipo', true, isFirst: true),
          _stepDivider(),
          _stepItem('Conteúdo', false),
          _stepDivider(),
          _stepItem('Agendar', false),
          _stepDivider(),
          _stepItem('Revisar', false, isLast: true),
        ],
      ),
    );
  }

  Widget _stepDivider() {
    return Expanded(
      child: Container(
        height: 2,
        color: AppColors.border,
      ),
    );
  }

  Widget _stepItem(String label, bool active, {bool isFirst = false, bool isLast = false}) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: active ? AppColors.secondary : Colors.white,
            border: Border.all(color: active ? AppColors.secondary : AppColors.border, width: 2),
            shape: BoxShape.circle,
          ),
          child: active ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: active ? FontWeight.bold : FontWeight.w500,
            color: active ? AppColors.primary : AppColors.muted,
          ),
        ),
      ],
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
  final IconData icone;
  final Color corFundoIcone;
  final VoidCallback onTap;

  const _AtividadeSelecionavelCard({
    required this.titulo,
    required this.descricao,
    required this.selecionada,
    required this.icone,
    required this.corFundoIcone,
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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selecionada ? AppColors.primary : AppColors.border,
            width: selecionada ? 2 : 1,
          ),
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
                color: corFundoIcone,
                shape: BoxShape.circle,
              ),
              child: Icon(icone, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
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
            if (selecionada)
              const Icon(LucideIcons.circleCheck, color: AppColors.success),
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