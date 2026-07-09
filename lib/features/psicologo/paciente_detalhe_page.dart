import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import '../../core/auth/auth_storage.dart';
import 'services/psicologo_service.dart';
import 'enviar_atividade_page.dart';
import '../../core/api/api_client.dart';

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
  bool aprovado = true;
  int pacienteNivel = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() => setState(() {}));
    dadosFuture = _carregarDados();
    _carregarAprovado();
  }

  Future<void> _carregarAprovado() async {
    final status = await AuthStorage.obterAprovado();
    if (mounted) {
      setState(() => aprovado = status);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _carregarDados() async {
    final paciente = await service.obterPacientePorId(widget.pacienteId);
    if (mounted) {
      setState(() {
        pacienteNivel = paciente['nivel'] as int? ?? 1;
      });
    }
    final checkins = await service.listarCheckinsPaciente(widget.pacienteId);
    final registros = await service.listarRegistrosPensamentosPaciente(widget.pacienteId);
    final atividades = await service.listarAtividadesPaciente(widget.pacienteId);
    final mensagens = await service.listarMensagensPaciente(widget.pacienteId);
    
    // Dados de plano e bloqueio de IA
    final me = await service.obterMe();
    final planoRaw = me['plano']?.toString();
    final plano = (planoRaw == null || planoRaw.isEmpty) ? 'Starter' : planoRaw;
    final isIaLocked = plano.toString().toLowerCase() != 'profissional' && plano.toString().toLowerCase() != 'clinica';

    List<dynamic> iaInsights = [];
    String? iaError;

    if (!isIaLocked) {
      try {
        final res = await ApiClient.dio.get('/Pacientes/${widget.pacienteId}/ia-insights');
        if (res.data is List) {
          iaInsights = res.data;
        }
      } catch (e) {
        iaError = 'Não foi possível carregar insights de IA.';
      }
    }

    return {
      'paciente': paciente,
      'checkins': checkins,
      'registros': registros,
      'atividades': atividades,
      'mensagens': mensagens,
      'isIaLocked': isIaLocked,
      'plano': plano,
      'iaInsights': iaInsights,
      'iaError': iaError,
    };
  }

  Future<void> _recarregar() async {
    setState(() {
      dadosFuture = _carregarDados();
    });
  }

  void _exibirDialogMensagem(BuildContext context) {
    final textController = TextEditingController();

    _exibirPainelLateral(
      context: context,
      titulo: 'Enviar Motivação',
      textoConfirmar: 'Enviar',
      campos: [
        const Text(
          'Envie uma mensagem especial para motivar o paciente esta semana:',
          style: TextStyle(fontSize: 13, color: AppColors.muted),
        ),
        const SizedBox(height: 20),
        _buildTextAreaField(
          controller: textController,
          label: 'Mensagem',
          hintText: 'Ex: Muito orgulhosa de ver sua dedicação esta semana! Continue firme...',
        ),
      ],
      onConfirmar: () async {
        final conteudo = textController.text.trim();
        if (conteudo.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor, escreva uma mensagem.')),
          );
          throw Exception('Mensagem vazia');
        }
        try {
          await service.enviarMensagemMotivacional(
            pacienteId: widget.pacienteId,
            conteudo: conteudo,
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Mensagem motivacional enviada com sucesso!'),
                backgroundColor: AppColors.secondary,
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erro ao enviar mensagem: $e')),
            );
          }
          rethrow;
        }
      },
    );
  }

  Widget _buildTextAreaField({
    required TextEditingController controller,
    required String label,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.text),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: 6,
          style: const TextStyle(fontSize: 14, color: AppColors.text),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            hintText: hintText,
            hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
          ),
        ),
      ],
    );
  }

  void _exibirPainelLateral({
    required BuildContext context,
    required String titulo,
    required List<Widget> campos,
    required Future<void> Function() onConfirmar,
    required String textoConfirmar,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (ctx, anim1, anim2) {
        bool salvando = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Align(
              alignment: Alignment.centerRight,
              child: Material(
                color: AppColors.background,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    border: Border(left: BorderSide(color: AppColors.border, width: 1)),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                titulo,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.text,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(LucideIcons.x, color: AppColors.muted),
                                onPressed: () => Navigator.pop(ctx),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: campos,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: salvando ? null : () => Navigator.pop(ctx),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Text('Cancelar'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: salvando
                                      ? null
                                      : () async {
                                          setDialogState(() => salvando = true);
                                          try {
                                            await onConfirmar();
                                            if (ctx.mounted) {
                                              Navigator.pop(ctx);
                                            }
                                          } catch (_) {
                                            // Error is handled inside onConfirmar
                                          } finally {
                                            setDialogState(() => salvando = false);
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: salvando
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : Text(textoConfirmar),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOut)),
          child: child,
        );
      },
    );
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
          final atividades = List<dynamic>.from(dados['atividades'] ?? []);

          return RefreshIndicator(
            onRefresh: _recarregar,
            child: Column(
              children: [
                _CabecalhoPaciente(
                  nome: widget.nome,
                  nivel: dados['paciente']?['nivel'] ?? 1,
                  pontos: dados['paciente']?['pontos'] ?? 0,
                  aprovado: aprovado,
                  onEnviarMensagem: () => _exibirDialogMensagem(context),
                ),
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
                      _AbaResumo(
                        checkins: checkins,
                        registros: registros,
                        atividades: atividades,
                      ),
                      _AbaAtividades(atividades: atividades),
                      _AbaEvolucao(
                        paciente: dados['paciente'] ?? {},
                        atividades: atividades,
                        checkins: checkins,
                        registros: registros,
                        isIaLocked: dados['isIaLocked'] ?? true,
                        plano: dados['plano'] ?? 'Starter',
                        iaInsights: dados['iaInsights'] ?? [],
                        iaError: dados['iaError'],
                      ),
                      _AbaAnotacoes(
                        pacienteId: widget.pacienteId,
                        mensagens: List<dynamic>.from(dados['mensagens'] ?? []),
                        anotacoesIniciais: dados['paciente']?['anotacoes'] ?? '',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: _tabController.index == 1 && aprovado
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EnviarAtividadePage(
                      pacienteId: widget.pacienteId,
                      pacienteNome: widget.nome,
                      pacienteNivel: pacienteNivel,
                    ),
                  ),
                );
                if (result == true) {
                  _recarregar();
                }
              },
              icon: const Icon(LucideIcons.plus),
              label: const Text('Prescrever Atividade/Jogo'),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }
}

class _CabecalhoPaciente extends StatelessWidget {
  final String nome;
  final int nivel;
  final int pontos;
  final bool aprovado;
  final VoidCallback onEnviarMensagem;

  const _CabecalhoPaciente({
    required this.nome,
    required this.nivel,
    required this.pontos,
    required this.aprovado,
    required this.onEnviarMensagem,
  });

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
        Text(
          'Nível $nivel • $pontos XP',
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: aprovado ? onEnviarMensagem : null,
              icon: const Icon(LucideIcons.messageSquareHeart, size: 14),
              label: const Text('Enviar Motivação'),
              style: ElevatedButton.styleFrom(
                backgroundColor: aprovado ? AppColors.softPurple : Colors.grey.shade200,
                foregroundColor: aprovado ? AppColors.primary : Colors.grey.shade500,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 0,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AbaResumo extends StatelessWidget {
  final List<dynamic> checkins;
  final List<dynamic> registros;
  final List<dynamic> atividades;

  const _AbaResumo({
    required this.checkins,
    required this.registros,
    required this.atividades,
  });

  @override
  Widget build(BuildContext context) {
    final concluidas = atividades.where((x) {
      final status = x['status'];
      return status == 3 ||
          status?.toString() == '3' ||
          status?.toString().toLowerCase() == 'concluida' ||
          status?.toString().toLowerCase() == 'concluído';
    }).toList();

    final totalAtiv = atividades.length;
    final totalConcluidas = concluidas.length;
    final adesao = totalAtiv > 0 ? (totalConcluidas / totalAtiv * 100).round() : 0;

    final List<Map<String, dynamic>> itensResumo = [];

    // Adicionar atividades concluídas
    for (var a in atividades) {
      final isConcluida = a['status'] == 3 ||
          a['status']?.toString() == '3' ||
          a['status']?.toString().toLowerCase() == 'concluida' ||
          a['status']?.toString().toLowerCase() == 'concluído';
      if (isConcluida) {
        final dataConStr = a['dataConclusao'];
        itensResumo.add({
          'tipo': 'atividade',
          'titulo': a['atividade']?['titulo'] ?? a['titulo'] ?? 'Atividade',
          'subtitulo': 'Atividade concluída',
          'data': DateTime.tryParse(dataConStr?.toString() ?? '')?.toLocal() ?? DateTime.fromMillisecondsSinceEpoch(0),
          'dados': a,
        });
      }
    }

    // Adicionar check-ins
    for (var c in checkins) {
      final criadoEmStr = c['criadoEm'];
      itensResumo.add({
        'tipo': 'checkin',
        'titulo': 'Check-in Emocional',
        'subtitulo': 'Humor: ${_humorTexto(c['humor'])} (Intensidade: ${c['intensidade']}/10)',
        'data': DateTime.tryParse(criadoEmStr?.toString() ?? '')?.toLocal() ?? DateTime.fromMillisecondsSinceEpoch(0),
        'dados': c,
      });
    }

    // Adicionar registros de pensamentos
    for (var r in registros) {
      final criadoEmStr = r['criadoEm'];
      itensResumo.add({
        'tipo': 'registro',
        'titulo': 'Registro de Pensamentos',
        'subtitulo': 'Situação: ${r['situacao']}',
        'data': DateTime.tryParse(criadoEmStr?.toString() ?? '')?.toLocal() ?? DateTime.fromMillisecondsSinceEpoch(0),
        'dados': r,
      });
    }

    // Ordenar por data decrescente
    itensResumo.sort((a, b) => b['data'].compareTo(a['data']));

    // Pegar os 3 mais recentes
    final recentes = itensResumo.take(3).toList();

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
              _ItemEstatistica('Adesão média', '$adesao%'),
              _ItemEstatistica('Atividades concluídas', '$totalConcluidas / $totalAtiv'),
              _ItemEstatistica('Check-ins', '${checkins.length}'),
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
          if (recentes.isEmpty)
            const Text(
              'Nenhum registro recente encontrado.',
              style: TextStyle(color: AppColors.muted),
            )
          else
            ...recentes.map((item) {
              IconData icone = Icons.check_circle;
              Color corIcone = AppColors.secondary;

              if (item['tipo'] == 'checkin') {
                final humorVal = item['dados']['humor'];
                icone = _humorIcone(humorVal);
                corIcone = _humorCor(humorVal);
              } else if (item['tipo'] == 'registro') {
                icone = LucideIcons.brain;
                corIcone = Colors.amber;
              }

              // format date
              final dt = item['data'] as DateTime;
              final dataFormatada = dt.millisecondsSinceEpoch == 0
                  ? ''
                  : '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';

              return _ItemAtividade(
                titulo: item['titulo'],
                subtitulo: '${item['subtitulo']} • $dataFormatada',
                icone: icone,
                corIcone: corIcone,
                iconeAcao: 'Ver',
                onTap: () {
                  if (item['tipo'] == 'atividade') {
                    _verDetalhesAtividade(context, item['dados']);
                  } else if (item['tipo'] == 'checkin') {
                    _verDetalhesCheckin(context, item['dados']);
                  } else if (item['tipo'] == 'registro') {
                    _verDetalhesRegistro(context, item['dados']);
                  }
                },
              );
            }).toList(),
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
  final VoidCallback? onTap;

  const _ItemAtividade({
    required this.titulo,
    required this.subtitulo,
    required this.icone,
    required this.corIcone,
    required this.iconeAcao,
    this.onTap,
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
            if (onTap != null)
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
      ),
    );
  }
}

class _AbaAtividades extends StatelessWidget {
  final List<dynamic> atividades;

  const _AbaAtividades({required this.atividades});

  @override
  Widget build(BuildContext context) {
    if (atividades.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(22),
          child: Text(
            'Nenhuma atividade enviada para este paciente.',
            style: TextStyle(color: AppColors.muted),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: atividades.length,
      itemBuilder: (context, index) {
        final ativ = Map<String, dynamic>.from(atividades[index]);
        final titulo = ativ['atividade']?['titulo'] ?? ativ['titulo'] ?? 'Atividade';
        final status = ativ['status'];
        final dataEnvioStr = ativ['dataEnvio'];

        String subtitulo = 'Enviada';
        if (dataEnvioStr != null) {
          try {
            final dt = DateTime.parse(dataEnvioStr.toString()).toLocal();
            subtitulo = 'Enviada em ${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
          } catch (_) {}
        }

        IconData iconeStatus = Icons.pending_actions;
        Color corIcone = AppColors.warning;
        String descStatus = 'Pendente';

        final isConcluida = status == 3 ||
            status?.toString() == '3' ||
            status?.toString().toLowerCase() == 'concluida' ||
            status?.toString().toLowerCase() == 'concluído';

        if (isConcluida) {
          iconeStatus = Icons.check_circle;
          corIcone = AppColors.secondary;
          descStatus = 'Concluída';
        } else if (status == 4 || status?.toString() == '4' || status?.toString().toLowerCase() == 'atrasada') {
          iconeStatus = Icons.error_outline;
          corIcone = AppColors.danger;
          descStatus = 'Atrasada';
        }

        return _ItemAtividade(
          titulo: titulo,
          subtitulo: '$subtitulo • $descStatus',
          icone: iconeStatus,
          corIcone: corIcone,
          iconeAcao: 'Ver Resposta',
          onTap: () => _verDetalhesAtividade(context, ativ),
        );
      },
    );
  }
}

String _humorTexto(dynamic humor) {
  final h = int.tryParse(humor?.toString() ?? '') ?? 3;
  switch (h) {
    case 1:
      return 'Triste/Ruim';
    case 2:
      return 'Regular';
    case 3:
      return 'Bom';
    case 4:
      return 'Muito Bom';
    case 5:
      return 'Excelente';
    default:
      return 'Bom';
  }
}

IconData _humorIcone(dynamic humor) {
  final h = int.tryParse(humor?.toString() ?? '') ?? 3;
  switch (h) {
    case 1:
      return LucideIcons.frown;
    case 2:
      return LucideIcons.meh;
    case 3:
      return LucideIcons.smile;
    case 4:
      return LucideIcons.laugh;
    case 5:
      return LucideIcons.heart;
    default:
      return LucideIcons.smile;
  }
}

Color _humorCor(dynamic humor) {
  final h = int.tryParse(humor?.toString() ?? '') ?? 3;
  switch (h) {
    case 1:
      return AppColors.danger;
    case 2:
      return AppColors.warning;
    case 3:
      return Colors.blue;
    case 4:
      return AppColors.success;
    case 5:
      return Colors.pink;
    default:
      return Colors.blue;
  }
}

void _verDetalhesAtividade(BuildContext context, Map<String, dynamic> ativ) {
  final status = ativ['status'];
  final isConcluida = status == 3 ||
      status?.toString() == '3' ||
      status?.toString().toLowerCase() == 'concluida' ||
      status?.toString().toLowerCase() == 'concluído';
  final dataEnvioStr = ativ['dataEnvio'];
  final dataConStr = ativ['dataConclusao'];
  final dataLimiteStr = ativ['dataLimite'];
  final resposta = ativ['respostaTexto'];
  final notaHumorVal = ativ['notaHumor'];

  String dataEnvio = '';
  if (dataEnvioStr != null) {
    try {
      final dt = DateTime.parse(dataEnvioStr.toString()).toLocal();
      dataEnvio = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {}
  }

  String dataCon = '';
  if (dataConStr != null) {
    try {
      final dt = DateTime.parse(dataConStr.toString()).toLocal();
      dataCon = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {}
  }

  String dataLimite = '';
  if (dataLimiteStr != null) {
    try {
      final dt = DateTime.parse(dataLimiteStr.toString()).toLocal();
      dataLimite = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {}
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    backgroundColor: AppColors.background,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(
                  isConcluida ? LucideIcons.circleCheck : LucideIcons.circleAlert,
                  color: isConcluida ? AppColors.secondary : AppColors.warning,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    ativ['atividade']?['titulo'] ?? ativ['titulo'] ?? 'Atividade',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (ativ['atividade']?['descricao'] != null && ativ['atividade']?['descricao'].toString().isNotEmpty == true) ...[
              Text(
                ativ['atividade']?['descricao'],
                style: const TextStyle(fontSize: 14, color: AppColors.muted),
              ),
              const SizedBox(height: 16),
            ],
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _LinhaInfoDetalhe('Data de envio', dataEnvio),
                  if (dataLimite.isNotEmpty) ...[
                    const Divider(height: 16),
                    _LinhaInfoDetalhe('Data limite', dataLimite),
                  ],
                  if (isConcluida && dataCon.isNotEmpty) ...[
                    const Divider(height: 16),
                    _LinhaInfoDetalhe('Concluída em', dataCon),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (isConcluida) ...[
              const Text(
                'Resposta do Paciente',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.softGreen.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.softGreen.withOpacity(0.5)),
                ),
                child: Text(
                  resposta ?? 'Sem resposta por texto.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.text,
                    height: 1.4,
                  ),
                ),
              ),
              if (notaHumorVal != null) ...[
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Humor reportado na conclusão',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    Text(
                      '$notaHumorVal/10',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (int.tryParse(notaHumorVal.toString()) ?? 5) / 10.0,
                    minHeight: 8,
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ],
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: const Text(
                  'Esta atividade ainda não foi concluída pelo paciente.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Fechar',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

void _verDetalhesCheckin(BuildContext context, Map<String, dynamic> checkin) {
  final humorVal = checkin['humor'];
  final intensidade = checkin['intensidade'];
  final emocao = checkin['emocaoPrincipal'] ?? 'Não informada';
  final obs = checkin['observacao'];
  final criadoEmStr = checkin['criadoEm'];

  String dataCheckin = '';
  if (criadoEmStr != null) {
    try {
      final dt = DateTime.parse(criadoEmStr.toString()).toLocal();
      dataCheckin = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} às ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {}
  }

  final String txtHumor = _humorTexto(humorVal);
  final IconData iconHumor = _humorIcone(humorVal);
  final Color corHumor = _humorCor(humorVal);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    backgroundColor: AppColors.background,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: corHumor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconHumor, color: corHumor, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Check-in Emocional',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dataCheckin,
                        style: const TextStyle(fontSize: 12, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _LinhaInfoDetalhe('Humor geral', txtHumor),
                  const Divider(height: 16),
                  _LinhaInfoDetalhe('Intensidade do humor', '$intensidade/10'),
                  const Divider(height: 16),
                  _LinhaInfoDetalhe('Emoção principal', emocao),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Relato / Observação',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.softGreen.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.softGreen.withOpacity(0.5)),
              ),
              child: Text(
                (obs != null && obs.toString().trim().isNotEmpty) ? obs : 'Paciente não deixou observações adicionais para este check-in.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.text,
                  fontStyle: (obs != null && obs.toString().trim().isNotEmpty) ? FontStyle.normal : FontStyle.italic,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Fechar',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

void _verDetalhesRegistro(BuildContext context, Map<String, dynamic> registro) {
  final sit = registro['situacao'] ?? '';
  final pAutomatico = registro['pensamentoAutomatico'] ?? '';
  final emo = registro['emocao'] ?? '';
  final intEmocao = registro['intensidadeEmocao'] ?? 0;
  final evAFavor = registro['evidenciasAFavor'];
  final evContra = registro['evidenciasContra'];
  final pAlternativo = registro['pensamentoAlternativo'];
  final intFinal = registro['intensidadeFinal'];
  final criadoEmStr = registro['criadoEm'];

  String dataRegistro = '';
  if (criadoEmStr != null) {
    try {
      final dt = DateTime.parse(criadoEmStr.toString()).toLocal();
      dataRegistro = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} às ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {}
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    backgroundColor: AppColors.background,
    builder: (ctx) {
      return DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.brain, color: Colors.amber, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Registro de Pensamentos',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dataRegistro,
                            style: const TextStyle(fontSize: 12, color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _SecaoBlocoDetalhe('Situação / Gatilho', sit),
                _SecaoBlocoDetalhe('Pensamento Automático', pAutomatico),
                _SecaoBlocoDetalhe('Emoção & Intensidade Inicial', '$emo (Intensidade: $intEmocao/10)'),
                
                if (evAFavor != null && evAFavor.toString().trim().isNotEmpty)
                  _SecaoBlocoDetalhe('Evidências a favor do pensamento', evAFavor),
                
                if (evContra != null && evContra.toString().trim().isNotEmpty)
                  _SecaoBlocoDetalhe('Evidências contra o pensamento', evContra),

                if (pAlternativo != null && pAlternativo.toString().trim().isNotEmpty)
                  _SecaoBlocoDetalhe('Pensamento Alternativo / Reestruturado', pAlternativo),

                if (intFinal != null)
                  _SecaoBlocoDetalhe('Intensidade da Emoção Final', '$intFinal/10'),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Fechar',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

class _SecaoBlocoDetalhe extends StatelessWidget {
  final String titulo;
  final String conteudo;

  const _SecaoBlocoDetalhe(this.titulo, this.conteudo);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              conteudo,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.text,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinhaInfoDetalhe extends StatelessWidget {
  final String label;
  final String valor;

  const _LinhaInfoDetalhe(this.label, this.valor);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.muted, fontWeight: FontWeight.w500),
        ),
        Text(
          valor,
          style: const TextStyle(fontSize: 13, color: AppColors.text, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _AbaEvolucao extends StatelessWidget {
  final Map<String, dynamic> paciente;
  final List<dynamic> atividades;
  final List<dynamic> checkins;
  final List<dynamic> registros;
  final bool isIaLocked;
  final String plano;
  final List<dynamic> iaInsights;
  final String? iaError;

  const _AbaEvolucao({
    required this.paciente,
    required this.atividades,
    required this.checkins,
    required this.registros,
    required this.isIaLocked,
    required this.plano,
    required this.iaInsights,
    this.iaError,
  });

  @override
  Widget build(BuildContext context) {
    final concluidas = atividades.where((x) {
      final status = x['status'];
      return status == 3 ||
          status?.toString() == '3' ||
          status?.toString().toLowerCase() == 'concluida' ||
          status?.toString().toLowerCase() == 'concluído';
    }).toList();

    final totalPontos = paciente['pontos'] ?? 0;
    final nivelPaciente = paciente['nivel'] ?? 1;

    // Calcular pontos detalhados
    final pontosAtividades = concluidas.fold<int>(0, (sum, item) {
      final nivel = item['nivel'] as int? ?? 1;
      return sum + ((nivel > 0 ? nivel : 1) * 10);
    });

    final datasCheckinUnicas = checkins.map((c) {
      final criadoEmStr = c['criadoEm'] ?? c['dataCriacao'] ?? '';
      try {
        final dt = DateTime.parse(criadoEmStr.toString()).toLocal();
        return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      } catch (_) {
        return '';
      }
    }).where((date) => date.isNotEmpty).toSet();

    final pontosCheckins = datasCheckinUnicas.length * 10;

    final registrosAvulsos = registros.where((r) => r['atividadePacienteId'] == null).toList();
    final pontosRegistros = registrosAvulsos.length * 15;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF11998E),
                  Color(0xFF38EF7D),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF11998E).withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.trophy,
                    color: Colors.amber,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nível $nivelPaciente • $totalPontos XP',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'O paciente concluiu ${concluidas.length} atividades até agora.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Detalhamento do XP',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 16),
                _LinhaDetalhamentoXP(
                  titulo: 'Atividades concluídas',
                  xp: pontosAtividades,
                  detalhe: '${concluidas.length} atividades',
                  icone: LucideIcons.clipboardCheck,
                  corIcone: AppColors.primary,
                ),
                const Divider(height: 24, color: AppColors.border),
                _LinhaDetalhamentoXP(
                  titulo: 'Check-ins diários',
                  xp: pontosCheckins,
                  detalhe: '${datasCheckinUnicas.length} dias ativos',
                  icone: LucideIcons.heartPulse,
                  corIcone: AppColors.secondary,
                ),
                const Divider(height: 24, color: AppColors.border),
                _LinhaDetalhamentoXP(
                  titulo: 'Registros de pensamentos',
                  xp: pontosRegistros,
                  detalhe: '${registrosAvulsos.length} diários avulsos',
                  icone: LucideIcons.brain,
                  corIcone: Colors.amber,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Histórico de conquistas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 16),
          if (concluidas.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: const Center(
                child: Text(
                  'Nenhuma conquista registrada ainda.',
                  style: TextStyle(color: AppColors.muted, fontSize: 13),
                ),
              ),
            )
          else
            ...concluidas.map((ativ) {
              final titulo = ativ['titulo'] ?? ativ['atividade']?['titulo'] ?? 'Atividade';
              final desc = ativ['descricao'] ?? ativ['atividade']?['descricao'] ?? '';
              final nivel = ativ['nivel'] as int? ?? 1;
              final xpGanhos = (nivel > 0 ? nivel : 1) * 10;
              final dataConclusaoStr = ativ['dataConclusao'];

              String dataFormatada = '';
              if (dataConclusaoStr != null) {
                try {
                  final dt = DateTime.parse(dataConclusaoStr.toString()).toLocal();
                  dataFormatada = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
                } catch (_) {
                  dataFormatada = '';
                }
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.01),
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
                        color: AppColors.softGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        LucideIcons.circleCheck,
                        color: AppColors.secondary,
                        size: 24,
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
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                          if (desc.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              desc,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.muted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (dataFormatada.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Concluída em $dataFormatada',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.muted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF8E2DE2),
                            Color(0xFF4A00E0),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '+$xpGanhos XP',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          const SizedBox(height: 24),
          const Text(
            'Análise de Evolução por IA',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 16),
          if (isIaLocked)
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF8E2DE2),
                    Color(0xFF4A00E0),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4A00E0).withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          LucideIcons.sparkles,
                          color: Colors.amber,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Insights Clínicos por IA',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Análises automáticas sobre humor, engajamento e flexibilidade cognitiva com recomendações clínicas de TCC.\n\nDisponível no plano Profissional.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: const Center(
                      child: Text(
                        'Faça upgrade no Painel Web',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (iaError != null)
            Container(
              padding: const EdgeInsets.all(18),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Center(
                child: Text(
                  iaError!,
                  style: const TextStyle(color: AppColors.danger, fontSize: 13),
                ),
              ),
            )
          else if (iaInsights.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: const Center(
                child: Text(
                  'Nenhum insight disponível ainda para este paciente.',
                  style: TextStyle(color: AppColors.muted, fontSize: 13),
                ),
              ),
            )
          else
            ...iaInsights.map((insight) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.softGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.sparkles,
                        color: AppColors.secondary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        insight.toString(),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.text,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
}

class _LinhaDetalhamentoXP extends StatelessWidget {
  final String titulo;
  final int xp;
  final String detalhe;
  final IconData icone;
  final Color corIcone;

  const _LinhaDetalhamentoXP({
    required this.titulo,
    required this.xp,
    required this.detalhe,
    required this.icone,
    required this.corIcone,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: corIcone.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icone, color: corIcone, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                detalhe,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
        Text(
          '+$xp XP',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _AbaAnotacoes extends StatefulWidget {
  final String pacienteId;
  final List<dynamic> mensagens;
  final String anotacoesIniciais;

  const _AbaAnotacoes({
    required this.pacienteId,
    required this.mensagens,
    required this.anotacoesIniciais,
  });

  @override
  State<_AbaAnotacoes> createState() => _AbaAnotacoesState();
}

class _AbaAnotacoesState extends State<_AbaAnotacoes> {
  late TextEditingController _anotacoesController;
  final service = PsicologoService();
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _anotacoesController = TextEditingController(text: widget.anotacoesIniciais);
  }

  @override
  void dispose() {
    _anotacoesController.dispose();
    super.dispose();
  }

  Future<void> _salvarAnotacoes() async {
    setState(() => _salvando = true);
    try {
      await service.atualizarAnotacoesPaciente(widget.pacienteId, _anotacoesController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anotações salvas com sucesso!'),
            backgroundColor: AppColors.secondary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar anotações: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _salvando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sort messages from newest to oldest
    final msgs = List<dynamic>.from(widget.mensagens);
    msgs.sort((a, b) {
      final da = DateTime.tryParse(a['criadoEm']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      final db = DateTime.tryParse(b['criadoEm']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      return db.compareTo(da);
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Anotações Particulares',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Estas anotações são confidenciais e visíveis apenas para você, psicólogo(a).',
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.01),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _anotacoesController,
              maxLines: 8,
              style: const TextStyle(fontSize: 14, color: AppColors.text),
              decoration: const InputDecoration(
                hintText: 'Escreva aqui suas observações sobre a evolução, sessões e comportamento do paciente...',
                hintStyle: TextStyle(color: AppColors.muted, fontSize: 13),
                contentPadding: EdgeInsets.all(16),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _salvando ? null : _salvarAnotacoes,
              icon: _salvando
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(LucideIcons.save, size: 16),
              label: Text(_salvando ? 'Salvando...' : 'Salvar Anotações'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Mensagens Motivacionais Enviadas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 16),
          if (msgs.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: const Center(
                child: Text(
                  'Nenhuma mensagem motivacional enviada para este paciente.',
                  style: TextStyle(color: AppColors.muted, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: msgs.length,
              itemBuilder: (ctx, idx) {
                final msg = msgs[idx];
                final dataStr = msg['criadoEm'];
                String dataFormatada = '';
                if (dataStr != null) {
                  try {
                    final dt = DateTime.parse(dataStr.toString()).toLocal();
                    dataFormatada = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} às ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                  } catch (_) {}
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(LucideIcons.messageSquareHeart, color: AppColors.primary, size: 16),
                              SizedBox(width: 6),
                              Text(
                                'Mensagem Motivacional',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ],
                          ),
                          Text(
                            dataFormatada,
                            style: const TextStyle(fontSize: 11, color: AppColors.muted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        msg['conteudo'] ?? '',
                        style: const TextStyle(fontSize: 13, color: AppColors.text, height: 1.4),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            msg['lida'] == true ? LucideIcons.checkCheck : LucideIcons.check,
                            color: msg['lida'] == true ? AppColors.secondary : AppColors.muted,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            msg['lida'] == true ? 'Lida pelo paciente' : 'Enviada',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: msg['lida'] == true ? AppColors.secondary : AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}