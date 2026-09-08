import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import '../../core/auth/auth_storage.dart';
import 'services/psicologo_service.dart';
import 'criar_atividade_wizard_page.dart';

class AtividadesPage extends StatefulWidget {
  const AtividadesPage({super.key});

  @override
  State<AtividadesPage> createState() => AtividadesPageState();
}

class AtividadesPageState extends State<AtividadesPage> {
  final service = PsicologoService();

  late Future<List<dynamic>> atividadesFuture;
  List<dynamic> todosPacientes = [];
  bool carregandoPacientes = false;
  bool aprovado = true;

  @override
  void initState() {
    super.initState();
    atividadesFuture = service.listarAtividadesDoPsicologo();
    _carregarPacientes();
    _carregarAprovado();
  }

  Future<void> _carregarAprovado() async {
    final status = await AuthStorage.obterAprovado();
    if (mounted) {
      setState(() => aprovado = status);
    }
  }

  Future<void> _carregarPacientes() async {
    try {
      final lista = await service.listarPacientesDoPsicologo();
      setState(() {
        todosPacientes = lista;
      });
    } catch (e) {
      debugPrint('Erro ao carregar pacientes: $e');
    }
  }

  Future<void> _recarregar() async {
    setState(() {
      atividadesFuture = service.listarAtividadesDoPsicologo();
    });
  }

  void exibirDialogoCriar(BuildContext context) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CriarAtividadeWizardPage()),
    );
    if (resultado == true) {
      _recarregar();
    }
  }

  void _abrirModalCatalogoJogos(BuildContext context) {
    final List<Map<String, dynamic>> subcategorias = [
      {
        'subcategoria': 'CONTROLE INIBITÓRIO',
        'jogos': ['Modo Piloto', 'Reação Zero'],
        'desc': 'Exercícios de freio de impulsos e inibição motora/cognitiva.',
        'cor': const Color(0xFF3F37C9),
      },
      {
        'subcategoria': 'MEMÓRIA OPERACIONAL',
        'jogos': ['Investigação', 'Memória Tática', 'Jogo de Memória'],
        'desc': 'Retenção verbal, visual e manipulação de informações.',
        'cor': const Color(0xFF0F4C5C),
      },
      {
        'subcategoria': 'ATENÇÃO',
        'jogos': ['Missão Foco'],
        'desc': 'Atenção seletiva e sustentada sob estímulos concorrentes.',
        'cor': const Color(0xFF457B9D),
      },
      {
        'subcategoria': 'REGULAÇÃO EMOCIONAL',
        'jogos': ['Respire', 'Ansiedade Social'],
        'desc': 'Respiração guiada, regulação de estados ansiosos e somatização.',
        'cor': const Color(0xFFE63946),
      },
      {
        'subcategoria': 'PSICOEDUCAÇÃO',
        'jogos': ['Ilha das Emoções'],
        'desc': 'Dilemas socioemocionais e estratégias adaptativas.',
        'cor': const Color(0xFF059669),
      },
      {
        'subcategoria': 'TCC & REESTRUTURAÇÃO COGNITIVA',
        'jogos': ['Ache a Distorção', 'Detetive dos Pensamentos', 'Tribunal dos Pensamentos', 'Cartas dos Sabotadores'],
        'desc': 'Identificação de pensamentos automáticos e distorções cognitivas.',
        'cor': const Color(0xFF4F46E5),
      },
      {
        'subcategoria': 'FLEXIBILIDADE COGNITIVA & LINGUAGEM',
        'jogos': ['Mente Flexível', 'Laboratório Mental', 'Shark Mind', 'Universos Paralelos'],
        'desc': 'Troca de regras, fluência verbal e raciocínio divergente.',
        'cor': const Color(0xFF7209B7),
      },
      {
        'subcategoria': 'HÁBITOS, SAÚDE & EXPOSIÇÃO',
        'jogos': ['Check-List (Saúde)', 'Caçador de Gatilhos', 'Missão Coragem', 'Jornada do Herói Interior'],
        'desc': 'Monitoramento de rotina, exposição gradual e fortalecimento.',
        'cor': const Color(0xFFD97706),
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.softGreen,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(LucideIcons.gamepad2, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Catálogo de Jogos Terapêuticos',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text),
                          ),
                          Text(
                            '21 jogos categorizados por objetivos clínicos',
                            style: TextStyle(fontSize: 12, color: AppColors.muted),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: subcategorias.length,
                      itemBuilder: (context, index) {
                        final cat = subcategorias[index];
                        final subcat = cat['subcategoria'] as String;
                        final jogos = cat['jogos'] as List<String>;
                        final desc = cat['desc'] as String;
                        final cor = cat['cor'] as Color;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: cor,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    subcat,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: cor,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(desc, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: jogos.map((jogo) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppColors.border),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(LucideIcons.gamepad2, size: 14, color: cor),
                                        const SizedBox(width: 6),
                                        Text(
                                          jogo,
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        exibirDialogoCriar(context);
                      },
                      icon: const Icon(LucideIcons.sparkles, size: 18),
                      label: const Text('Prescrever um Jogo Agora'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
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

  void _abrirHistoricoAtividades(BuildContext context, List<dynamic> atividades) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Histórico de Atividades Criadas',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Selecione qualquer atividade do seu acervo para visualizar ou reenviar:',
                    style: TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: atividades.isEmpty
                        ? const Center(
                            child: Text('Nenhuma atividade encontrada no acervo.', style: TextStyle(color: AppColors.muted)),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: atividades.length,
                            itemBuilder: (context, index) {
                              final atividade = atividades[index];
                              return _AtividadeCard(
                                titulo: atividade['titulo'] ?? 'Atividade',
                                descricao: atividade['descricao'] ?? 'Sem descrição',
                                tipo: _getTipoTexto(atividade['tipo']),
                                onTap: () {
                                  Navigator.pop(context);
                                  exibirDetalhesEReenviar(context, atividade);
                                },
                              );
                            },
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

  void exibirDetalhesEReenviar(BuildContext context, Map<String, dynamic> atividade) {
    String? pacienteSelecionadoId = todosPacientes.isNotEmpty ? 'todos' : null;
    DateTime? dataLimite = DateTime.now().add(const Duration(days: 7));
    bool reenviando = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 32),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 5,
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
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.softGreen,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            atividade['tipo']?.toString() == '7'
                                ? LucideIcons.gamepad2
                                : LucideIcons.clipboardList,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                atividade['titulo'] ?? 'Atividade',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tipo: ${_getTipoTexto(atividade['tipo'])}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Descrição da atividade',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.text),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      atividade['descricao'] ?? 'Sem descrição.',
                      style: const TextStyle(fontSize: 13, color: AppColors.muted, height: 1.4),
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: AppColors.border),
                    const SizedBox(height: 14),
                    const Text(
                      '🔄 Reenviar Atividade',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Selecione o paciente e configure para enviar novamente esta atividade.',
                      style: TextStyle(fontSize: 12, color: AppColors.muted),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Enviar para:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.text),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(color: const Color(0xFFF4F6F9), borderRadius: BorderRadius.circular(12)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: pacienteSelecionadoId,
                          isExpanded: true,
                          icon: const Icon(LucideIcons.chevronDown, color: AppColors.muted),
                          items: [
                            const DropdownMenuItem(
                              value: 'todos',
                              child: Text('Todos os pacientes ativos'),
                            ),
                            ...todosPacientes
                                .where((p) => (p['nivel'] as int? ?? 1) >= (atividade['nivel'] as int? ?? 1))
                                .map((p) => DropdownMenuItem(
                                      value: p['id']?.toString(),
                                      child: Text('${p['nome']?.toString() ?? 'Paciente'} (Nível ${p['nivel']})'),
                                    )),
                          ],
                          onChanged: (val) {
                            setModalState(() => pacienteSelecionadoId = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Prazo de entrega (opcional):',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.text),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final data = await showDatePicker(
                          context: context,
                          initialDate: dataLimite ?? DateTime.now().add(const Duration(days: 7)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (data != null) {
                          setModalState(() => dataLimite = data);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(color: const Color(0xFFF4F6F9), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.calendar, color: AppColors.primary, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              dataLimite == null
                                  ? 'Sem data limite'
                                  : '${dataLimite!.day.toString().padLeft(2, '0')}/${dataLimite!.month.toString().padLeft(2, '0')}/${dataLimite!.year}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.text),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: reenviando || pacienteSelecionadoId == null || !aprovado
                            ? null
                            : () async {
                                setModalState(() => reenviando = true);
                                try {
                                  final String atividadeId = atividade['id'].toString();

                                  if (pacienteSelecionadoId == 'todos') {
                                    final atividadeNivel = atividade['nivel'] as int? ?? 1;
                                    for (var pac in todosPacientes) {
                                      final pacNivel = pac['nivel'] as int? ?? 1;
                                      if (pacNivel >= atividadeNivel) {
                                        await service.enviarAtividadeParaPaciente(
                                          atividadeId: atividadeId,
                                          pacienteId: pac['id'].toString(),
                                          dataLimite: dataLimite,
                                        );
                                      }
                                    }
                                  } else {
                                    await service.enviarAtividadeParaPaciente(
                                      atividadeId: atividadeId,
                                      pacienteId: pacienteSelecionadoId!,
                                      dataLimite: dataLimite,
                                    );
                                  }

                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Atividade reenviada com sucesso!')),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Erro ao reenviar: $e')),
                                    );
                                  }
                                } finally {
                                  setModalState(() => reenviando = false);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: aprovado ? AppColors.secondary : Colors.grey.shade400,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: reenviando
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(!aprovado ? 'Aguardando validação da conta' : 'Reenviar Atividade'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _getTipoTexto(dynamic tipoVal) {
    final t = tipoVal?.toString() ?? '1';
    switch (t) {
      case '1':
        return 'Reflexão';
      case '2':
        return 'Registro de pensamentos';
      case '3':
        return 'Exercício prático';
      case '4':
        return 'Check-list';
      case '5':
        return 'Áudio';
      case '6':
        return 'Leitura';
      case '7':
        return 'Jogo';
      default:
        return 'Reflexão';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: atividadesFuture,
      builder: (context, snapshot) {
        final atividades = snapshot.data ?? [];
        final bool carregando = snapshot.connectionState == ConnectionState.waiting;

        return RefreshIndicator(
          onRefresh: _recarregar,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Topo da tela
                const Text(
                  'Central de Atividades & Jogos',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Prescreva tarefas terapêuticas e jogos neuropsicológicos para seus pacientes.',
                  style: TextStyle(color: AppColors.muted, fontSize: 13),
                ),
                const SizedBox(height: 20),

                // Card Principal de Destaque / Banner Hero
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, Color(0xFF254B7C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(LucideIcons.sparkles, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Prescrever Novo Exercício',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Personalize ou envie jogos prontos em poucos passos.',
                                  style: TextStyle(color: Color(0xFFD0E1F9), fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Fortaleça o processo terapêutico entre as sessões atribuindo atividades de TCC ou jogos cognitivos direcionados às necessidades de cada paciente.',
                        style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => exibirDialogoCriar(context),
                          icon: const Icon(LucideIcons.plusCircle, color: AppColors.primary, size: 20),
                          label: const Text(
                            'Criar ou Prescrever Agora',
                            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Seção: O que você pode prescrever
                const Text(
                  'Recursos disponíveis para envio',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 12),

                // Item 1: 21 Jogos Cognitivos
                GestureDetector(
                  onTap: () => _abrirModalCatalogoJogos(context),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.softPurple,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(LucideIcons.gamepad2, color: Color(0xFF7209B7), size: 24),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '🎮 21 Jogos Terapêuticos',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.text),
                                  ),
                                  Spacer(),
                                  Icon(LucideIcons.chevronRight, size: 18, color: AppColors.muted),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Controle Inibitório, Memória Operacional, Atenção Seletiva, Regulação Emocional e TCC.',
                                style: TextStyle(color: AppColors.muted, fontSize: 12, height: 1.3),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Item 2: Exercícios de TCC & Escrita
                GestureDetector(
                  onTap: () => exibirDialogoCriar(context),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.softBlue,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(LucideIcons.fileText, color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '📝 Exercícios & Protocolos TCC',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.text),
                                  ),
                                  Spacer(),
                                  Icon(LucideIcons.chevronRight, size: 18, color: AppColors.muted),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Registros de Pensamentos Automáticos (RPD), questionários guiados, checklists e diários de hábitos.',
                                style: TextStyle(color: AppColors.muted, fontSize: 12, height: 1.3),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Item 3: Acompanhamento & Métricas
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.softGreen,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(LucideIcons.lineChart, color: AppColors.secondary, size: 24),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '📊 Acompanhamento em Tempo Real',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.text),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Todas as respostas enviadas e scores de desempenho dos jogos aparecem na aba "Pacientes".',
                              style: TextStyle(color: AppColors.muted, fontSize: 12, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Passo a Passo Simples
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(LucideIcons.checkCircle2, color: AppColors.secondary, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Como funciona o fluxo de envio',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.text),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _buildPassoItem('1', 'Clique no botão "Criar ou Prescrever Agora"'),
                      _buildPassoItem('2', 'Escolha o tipo de atividade ou o jogo desejado'),
                      _buildPassoItem('3', 'Selecione o paciente e defina um prazo opcional'),
                      _buildPassoItem('4', 'O paciente recebe a notificação instantânea no app!'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Card de Acesso ao Acervo / Histórico de Atividades
                GestureDetector(
                  onTap: () => _abrirHistoricoAtividades(context, atividades),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.secondary.withOpacity(0.4)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.softGreen,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(LucideIcons.history, color: AppColors.secondary, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Seu Acervo de Atividades',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.text),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      carregando ? '...' : '${atividades.length}',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondary),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Clique para ver as atividades salvas no seu acervo e reenviar.',
                                style: TextStyle(fontSize: 12, color: AppColors.muted),
                              ),
                            ],
                          ),
                        ),
                        const Icon(LucideIcons.chevronRight, color: AppColors.secondary, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPassoItem(String numero, String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                numero,
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(fontSize: 12, color: AppColors.text, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _AtividadeCard extends StatelessWidget {
  final String titulo;
  final String descricao;
  final String tipo;
  final VoidCallback onTap;

  const _AtividadeCard({
    required this.titulo,
    required this.descricao,
    required this.tipo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
                tipo.toLowerCase() == 'jogo'
                    ? LucideIcons.gamepad2
                    : LucideIcons.clipboardList,
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
      ),
    );
  }
}