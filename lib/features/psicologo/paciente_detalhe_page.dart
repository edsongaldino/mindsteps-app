import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import 'enviar_atividade_page.dart';
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

class _PacienteDetalhePageState extends State<PacienteDetalhePage> {
  final service = PsicologoService();

  late Future<Map<String, dynamic>> dadosFuture;

  @override
  void initState() {
    super.initState();
    dadosFuture = _carregarDados();
  }

  Future<Map<String, dynamic>> _carregarDados() async {
    final paciente = await service.obterPacientePorId(widget.pacienteId);
    final checkins = await service.listarCheckinsPaciente(widget.pacienteId);
    final registros =
        await service.listarRegistrosPensamentosPaciente(widget.pacienteId);

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

  Future<void> _abrirEnviarAtividade() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EnviarAtividadePage(
          pacienteId: widget.pacienteId,
          pacienteNome: widget.nome,
        ),
      ),
    );

    if (resultado == true) {
      await _recarregar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.nome),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
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
                  'Erro ao carregar paciente: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final dados = snapshot.data!;
          final checkins = List<dynamic>.from(dados['checkins'] ?? []);
          final registros = List<dynamic>.from(dados['registros'] ?? []);

          return RefreshIndicator(
            onRefresh: _recarregar,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ResumoPaciente(
                    nome: widget.nome,
                    totalCheckins: checkins.length,
                    totalRegistros: registros.length,
                  ),
                  const SizedBox(height: 14),

                  ElevatedButton.icon(
                    onPressed: _abrirEnviarAtividade,
                    icon: const Icon(LucideIcons.send),
                    label: const Text('Enviar atividade'),
                  ),

                  const SizedBox(height: 22),

                  const _TituloSecao('Check-ins recentes'),
                  const SizedBox(height: 12),

                  if (checkins.isEmpty)
                    const Text(
                      'Nenhum check-in encontrado.',
                      style: TextStyle(color: AppColors.muted),
                    ),

                  ...checkins.take(5).map((item) {
                    return _ItemInfo(
                      icone: LucideIcons.heartPulse,
                      titulo: item['emocaoPrincipal'] ?? 'Check-in emocional',
                      descricao: item['observacao'] ?? 'Sem observação',
                    );
                  }),

                  const SizedBox(height: 22),

                  const _TituloSecao('Registros de pensamentos'),
                  const SizedBox(height: 12),

                  if (registros.isEmpty)
                    const Text(
                      'Nenhum registro encontrado.',
                      style: TextStyle(color: AppColors.muted),
                    ),

                  ...registros.take(5).map((item) {
                    return _ItemInfo(
                      icone: LucideIcons.brain,
                      titulo: item['emocao'] ?? 'Registro de pensamento',
                      descricao:
                          item['pensamentoAutomatico'] ?? 'Sem pensamento registrado',
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ResumoPaciente extends StatelessWidget {
  final String nome;
  final int totalCheckins;
  final int totalRegistros;

  const _ResumoPaciente({
    required this.nome,
    required this.totalCheckins,
    required this.totalRegistros,
  });

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
            radius: 30,
            backgroundColor: AppColors.softGreen,
            child: Text(
              inicial,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
                fontSize: 22,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nome,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$totalCheckins check-ins • $totalRegistros registros cognitivos',
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
    );
  }
}

class _TituloSecao extends StatelessWidget {
  final String titulo;

  const _TituloSecao(this.titulo);

  @override
  Widget build(BuildContext context) {
    return Text(
      titulo,
      style: const TextStyle(
        color: AppColors.text,
        fontWeight: FontWeight.w900,
        fontSize: 18,
      ),
    );
  }
}

class _ItemInfo extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String descricao;

  const _ItemInfo({
    required this.icone,
    required this.titulo,
    required this.descricao,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w800,
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
    );
  }
}