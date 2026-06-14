import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import 'paciente_home_page.dart';
import 'paciente_responder_atividade_page.dart';
import 'services/paciente_service.dart';
import 'jogos/detetive_pensamentos_page.dart';
import 'jogos/tribunal_pensamentos_page.dart';
import 'jogos/cacador_gatilhos_page.dart';
import 'jogos/missao_coragem_page.dart';
import 'jogos/monstro_ansiedade_page.dart';
import 'jogos/ilha_emocoes_page.dart';
import 'jogos/decisao_pressao_page.dart';
import 'jogos/missao_foco_page.dart';
import 'jogos/memoria_tatica_page.dart';
import 'jogos/investigacao_page.dart';
import 'jogos/modo_piloto_page.dart';
import 'jogos/laboratorio_mental_page.dart';
import 'jogos/mente_flexivel_page.dart';
import 'jogos/shark_mind_page.dart';
import 'jogos/universos_paralelos_page.dart';
import 'jogos/reacao_zero_page.dart';
import 'jogos/cartas_sabotadores_page.dart';
import 'jogos/escape_room_page.dart';
import 'jogos/heroi_interior_page.dart';

class PacienteAtividadesPage extends StatefulWidget {
  final bool isActive;
  const PacienteAtividadesPage({super.key, this.isActive = false});

  @override
  State<PacienteAtividadesPage> createState() => _PacienteAtividadesPageState();
}

class _PacienteAtividadesPageState extends State<PacienteAtividadesPage> {
  @override
  void didUpdateWidget(covariant PacienteAtividadesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _recarregar();
    }
  }
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
    final tipo = atividade['atividade']?['tipo'] ?? atividade['tipo'] ?? 1;
    final conteudo = atividade['atividade']?['conteudo'] ?? atividade['conteudo'] ?? '';

    if (tipo == 7) {
      String nomeJogo = 'Memória Tática';
      try {
        if (conteudo.isNotEmpty) {
          final decoded = jsonDecode(conteudo);
          nomeJogo = decoded['tipoJogo'] ?? 'Memória Tática';
        }
      } catch (_) {}

      Widget gamePage;
      final atividadeId = atividade['id']?.toString() ?? '';

      switch (nomeJogo) {
        case 'Decisão Sob Pressão':
        case 'Semáforo das Emoções':
        case 'Semáforo Emocional':
          gamePage = DecisaoSobPressaoPage(atividadePacienteId: atividadeId);
          break;
        case 'Missão Foco':
          gamePage = MissaoFocoPage(atividadePacienteId: atividadeId);
          break;
        case 'Memória Tática':
        case 'Caçador de Memórias':
        case 'Jogo de Memória':
          gamePage = MemoriaTaticaPage(atividadePacienteId: atividadeId);
          break;
        case 'Investigação':
          gamePage = InvestigacaoPage(atividadePacienteId: atividadeId);
          break;
        case 'Modo Piloto':
          gamePage = ModoPilotoPage(atividadePacienteId: atividadeId);
          break;
        case 'Laboratório Mental':
          gamePage = LaboratorioMentalPage(atividadePacienteId: atividadeId);
          break;
        case 'Mente Flexível':
        case 'Mudança de Planos':
          gamePage = MenteFlexivelPage(atividadePacienteId: atividadeId);
          break;
        case 'Shark Mind':
          gamePage = SharkMindPage(atividadePacienteId: atividadeId);
          break;
        case 'Universos Paralelos':
          gamePage = UniversosParalelosPage(atividadePacienteId: atividadeId);
          break;
        case 'Reação Zero':
          gamePage = ReacaoZeroPage(atividadePacienteId: atividadeId);
          break;
        case 'Detetive dos Pensamentos':
          gamePage = DetetivePensamentosPage(atividadePacienteId: atividadeId);
          break;
        case 'Tribunal dos Pensamentos':
          gamePage = TribunalPensamentosPage(atividadePacienteId: atividadeId);
          break;
        case 'Caçador de Gatilhos':
          gamePage = CacadorGatilhosPage(atividadePacienteId: atividadeId);
          break;
        case 'Missão Coragem':
          gamePage = MissaoCoragemPage(atividadePacienteId: atividadeId);
          break;
        case 'O Monstro da Ansiedade':
          gamePage = MonstroAnsiedadePage(atividadePacienteId: atividadeId);
          break;
        case 'Ilha das Emoções':
          gamePage = IlhaEmocoesPage(atividadePacienteId: atividadeId);
          break;
        case 'Cartas dos Sabotadores':
          gamePage = CartasSabotadoresPage(atividadePacienteId: atividadeId);
          break;
        case 'Escape Room Terapêutico':
          gamePage = EscapeRoomPage(atividadePacienteId: atividadeId);
          break;
        case 'Jornada do Herói Interior':
          gamePage = HeroiInteriorPage(atividadePacienteId: atividadeId);
          break;
        default:
          gamePage = PacienteResponderAtividadePage(
            atividadePacienteId: atividadeId,
            titulo: atividade['atividade']?['titulo'] ?? atividade['titulo'] ?? 'Jogo de Memória',
            descricao: atividade['atividade']?['descricao'] ?? atividade['descricao'] ?? 'Realize a atividade do jogo de memória.',
            tipo: 7,
            conteudoJson: conteudo,
          );
          break;
      }

      final resultado = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => gamePage),
      );

      if (resultado == true) {
        await _recarregar();
      }
      return;
    }

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
          tipo: tipo,
          conteudoJson: conteudo,
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
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  final state = context.findAncestorStateOfType<PacienteHomePageState>();
                  state?.mudarPagina(0);
                }
              },
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
                  Builder(
                    builder: (context) {
                      final total = atividades.length;
                      final concluidasCount = atividades.where((x) => _estaConcluida(x['status'])).length;
                      final pendentesCount = total - concluidasCount;
                      
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _FiltroChip('Todas ($total)', true),
                          _FiltroChip('Pendentes ($pendentesCount)', false),
                          _FiltroChip('Concluídas ($concluidasCount)', false),
                        ],
                      );
                    }
                  ),
                  const SizedBox(height: 24),
                  if (atividades.isEmpty)
                    const Text('Nenhuma atividade encontrada.', style: TextStyle(color: AppColors.muted)),

                  ...atividades.asMap().entries.map((entry) {
                    final int index = entry.key;
                    final atividade = Map<String, dynamic>.from(entry.value);

                    final titulo = atividade['atividade']?['titulo'] ?? atividade['titulo'] ?? 'Atividade';
                    final status = atividade['status'];
                    final tipo = atividade['atividade']?['tipo'] ?? atividade['tipo'] ?? 1;
                    
                    final cardIcon = tipo == 7
                        ? LucideIcons.gamepad2
                        : [
                            LucideIcons.brain,
                            LucideIcons.footprints,
                            LucideIcons.heartPulse,
                            LucideIcons.sun,
                            LucideIcons.calendarClock,
                          ][index % 5];

                    return _AtividadePacienteCard(
                      titulo: titulo,
                      descricao: 'Segunda • 12/05', // Mock data from layout
                      status: _statusTexto(status),
                      concluida: _estaConcluida(status),
                      icone: cardIcon,
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
    return status == 3 ||
        status?.toString() == '3' ||
        status?.toString().toLowerCase() == 'concluida' ||
        status?.toString().toLowerCase() == 'concluído';
  }

  static String _statusTexto(dynamic status) {
    if (_estaConcluida(status)) return 'Concluída';
    if (status == 1 || status?.toString() == '1' || status?.toString().toLowerCase() == 'pendente') return 'Pendente';
    if (status == 4 || status?.toString() == '4' || status?.toString().toLowerCase() == 'atrasada') return 'Atrasada';
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