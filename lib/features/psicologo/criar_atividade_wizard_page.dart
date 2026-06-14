import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import 'services/psicologo_service.dart';

class CriarAtividadeWizardPage extends StatefulWidget {
  const CriarAtividadeWizardPage({super.key});

  @override
  State<CriarAtividadeWizardPage> createState() => _CriarAtividadeWizardPageState();
}

class _CriarAtividadeWizardPageState extends State<CriarAtividadeWizardPage> {
  final service = PsicologoService();
  
  // Controladores do Wizard
  int passoAtual = 0; // 0 a 5
  bool salvando = false;

  // Passo 1: Tipo de Atividade
  int tipoSelecionado = 1; // 1: Reflexão, 2: Registro, 3: Exercício, 4: Checklist, 5: Áudio, 6: Leitura, 7: Jogo
  
  // Passo 2: Conteúdo
  final tituloController = TextEditingController(text: 'Reflexão sobre ansiedade social');
  final descricaoController = TextEditingController(
    text: 'Esta atividade tem como objetivo te ajudar a refletir sobre situações sociais que geram ansiedade e identificar pensamentos e emoções envolvidas.',
  );
  List<String> perguntasGuiadas = [
    'O que aconteceu?',
    'O que você sentiu?',
    'O que passou pela sua mente?',
  ];
  List<TextEditingController> perguntasControllers = [];
  final novaPerguntaController = TextEditingController();

  // Passo 2 (Jogo): Conteúdo Jogo
  String jogoSelecionado = 'Caçador de Memórias';
  String modoJogo = 'Imagens'; // 'Imagens' ou 'Palavras'
  String temaJogo = 'Expressões/Emoções'; // Expressões/Emoções, Animais, Natureza
  String dificuldadeJogo = 'Evolutivo'; // Fácil, Médio, Difícil, Evolutivo
  final customPalavrasController = TextEditingController(text: 'Alegria, Tristeza, Raiva, Medo, Nojo, Surpresa');

  // Passo 3: Configurações
  String tipoResposta = 'Texto (resposta livre)';
  bool atividadeObrigatoria = true;
  bool permitirAnexos = true;
  final feedbackController = TextEditingController(text: 'Parabéns por concluir sua atividade! Continue se cuidando.');
  bool permitirEdicaoAposEnvio = false;
  String categoriaEmocional = 'Ansiedade';
  String nivelSugerido = 'Moderado'; // Leve, Moderado, Intenso
  int nivelAtividade = 1;

  // Passo 4: Agendamento
  String frequencia = 'Semanal';
  List<String> diasSemana = ['Seg', 'Qui']; // Dias selecionados
  final List<String> todosDias = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
  DateTime dataInicio = DateTime.now();
  TimeOfDay horarioSugerido = const TimeOfDay(hour: 20, minute: 0);
  String prazoConclusao = '7 dias após o envio';
  bool notificarPush = true;
  bool notificarEmail = true;
  bool lembreteSuave = true;

  // Passo 5: Revisão & Destinatários
  String tipoDestino = 'todos'; // 'nenhum', 'especifico', 'todos'
  List<dynamic> pacientes = [];
  String? pacienteSelecionadoId;
  bool carregandoPacientes = false;

  @override
  void initState() {
    super.initState();
    _sincronizarControllersPerguntas();
    _carregarPacientes();
  }

  @override
  void dispose() {
    tituloController.dispose();
    descricaoController.dispose();
    novaPerguntaController.dispose();
    feedbackController.dispose();
    customPalavrasController.dispose();
    super.dispose();
  }

  Future<void> _carregarPacientes() async {
    setState(() => carregandoPacientes = true);
    try {
      final lista = await service.listarPacientesDoPsicologo();
      setState(() {
        pacientes = lista;
        if (lista.isNotEmpty) {
          pacienteSelecionadoId = lista.first['id']?.toString();
        }
      });
    } catch (e) {
      debugPrint('Erro ao carregar pacientes: $e');
    } finally {
      setState(() => carregandoPacientes = false);
    }
  }

  void _aplicarTemplateAtividade(int tipo) {
    switch (tipo) {
      case 1: // Reflexão
        tituloController.text = 'Reflexão sobre emoções';
        descricaoController.text = 'Esta atividade tem como objetivo te ajudar a refletir sobre situações recentes e identificar pensamentos e emoções envolvidas.';
        perguntasGuiadas = [
          'O que aconteceu?',
          'O que você sentiu?',
          'O que passou pela sua mente?',
        ];
        tipoResposta = 'Texto (resposta livre)';
        break;
      case 2: // Registro de Pensamentos
        tituloController.text = 'Registro de Pensamentos (RPD)';
        descricaoController.text = 'O Registro de Pensamentos Disfuncionais ajuda a identificar e reestruturar pensamentos negativos automáticos.';
        perguntasGuiadas = [
          'Qual foi a situação?',
          'Quais foram as emoções e a intensidade (0-100)?',
          'Quais foram os pensamentos automáticos?',
          'Qual é uma resposta alternativa realista?',
        ];
        tipoResposta = 'Texto (resposta livre)';
        break;
      case 3: // Exercício Prático
        tituloController.text = 'Respiração Diafragmática';
        descricaoController.text = 'Exercício prático para controle de sintomas físicos de ansiedade através do controle da respiração profunda.';
        perguntasGuiadas = [
          'Como você se sentia antes do exercício?',
          'Como se sente agora?',
        ];
        tipoResposta = 'Escolha única';
        break;
      case 4: // Check-list
        tituloController.text = 'Check-list de Autocuidado Diário';
        descricaoController.text = 'Marque os itens que você conseguiu realizar no dia de hoje em prol do seu bem-estar.';
        perguntasGuiadas = [
          'Bebi água o suficiente?',
          'Fiz alguma atividade física?',
          'Tirei um momento para relaxar?',
        ];
        tipoResposta = 'Texto (resposta livre)';
        break;
      case 5: // Áudio
        tituloController.text = 'Meditação Guiada para Sono';
        descricaoController.text = 'Ouça o áudio anexado antes de dormir para auxiliar no relaxamento e indução do sono.';
        perguntasGuiadas = [
          'O áudio ajudou no seu relaxamento?',
        ];
        tipoResposta = 'Escolha única';
        break;
      case 6: // Leitura
        tituloController.text = 'O que é a Ansiedade?';
        descricaoController.text = 'Leia o texto explicativo sobre o funcionamento da ansiedade no corpo e na mente.';
        perguntasGuiadas = [
          'Qual parte do texto mais chamou sua atenção?',
          'Você se identificou com os sintomas descritos?',
        ];
        tipoResposta = 'Texto (resposta livre)';
        break;
      case 7: // Jogo
        tituloController.text = 'Caçador de Memórias';
        descricaoController.text = 'Pratique a memória de trabalho com sequências ordenadas e desafios de cálculo mental.';
        perguntasGuiadas = [];
        tipoResposta = 'Jogo';
        break;
    }
    _sincronizarControllersPerguntas();
  }

  Future<void> escolherDataInicio() async {
    final hoje = DateTime.now();
    final data = await showDatePicker(
      context: context,
      initialDate: dataInicio,
      firstDate: hoje,
      lastDate: hoje.add(const Duration(days: 365)),
    );
    if (data != null) {
      setState(() => dataInicio = data);
    }
  }

  Future<void> escolherHorario() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: horarioSugerido,
    );
    if (hora != null) {
      setState(() => horarioSugerido = hora);
    }
  }

  void _sincronizarControllersPerguntas() {
    perguntasControllers = perguntasGuiadas.map((p) => TextEditingController(text: p)).toList();
  }

  void adicionarPergunta() {
    final texto = novaPerguntaController.text.trim();
    if (texto.isNotEmpty) {
      setState(() {
        perguntasGuiadas.add(texto);
        perguntasControllers.add(TextEditingController(text: texto));
        novaPerguntaController.clear();
      });
    }
  }

  void removerPergunta(int index) {
    setState(() {
      perguntasGuiadas.removeAt(index);
      perguntasControllers.removeAt(index);
    });
  }

  Future<void> concluirWizard() async {
    if (tituloController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, informe o título da atividade.')),
      );
      return;
    }

    setState(() => salvando = true);

    try {
      // 1. Criar a atividade no Banco de Dados
      // Perguntas e partes dinâmicas do conteúdo viram JSON
      final Map<String, dynamic> conteudoReal;
      if (tipoSelecionado == 7) {
        conteudoReal = {
          'tipoJogo': jogoSelecionado,
          'modo': modoJogo,
          'tema': temaJogo,
          'dificuldade': dificuldadeJogo,
          'palavrasPersonalizadas': modoJogo == 'Palavras' && temaJogo == 'Personalizado'
              ? customPalavrasController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
              : null,
        };
      } else {
        conteudoReal = {
          'perguntas': perguntasGuiadas,
        };
      }

      final configuracoes = {
        'tipoResposta': tipoResposta,
        'atividadeObrigatoria': atividadeObrigatoria,
        'permitirAnexos': permitirAnexos,
        'feedbackAutomatico': feedbackController.text.isNotEmpty ? feedbackController.text : null,
        'categoriaEmocional': categoriaEmocional,
        'nivelSugerido': nivelSugerido,
        'nivel': nivelAtividade,
        'frequencia': frequencia,
        'diasSemana': diasSemana.join(','),
        'horarioSugerido': '${horarioSugerido.hour.toString().padLeft(2, '0')}:${horarioSugerido.minute.toString().padLeft(2, '0')}',
        'prazoConclusao': prazoConclusao,
        'notificarPush': notificarPush,
        'notificarEmail': notificarEmail,
        'lembreteSuave': lembreteSuave,
      };

      // Chamada da API para persistir a atividade
      final String novaAtividadeId = await service.criarAtividade(
        titulo: tituloController.text,
        descricao: descricaoController.text,
        tipo: tipoSelecionado,
        conteudo: jsonEncode(conteudoReal),
        configuracoes: configuracoes,
      );

      if (tipoDestino != 'nenhum') {
        final String atividadeId = novaAtividadeId;
        
        // 2. Enviar para os pacientes selecionados
        if (tipoDestino == 'todos') {
          // Envia para todos da lista do psicólogo
          for (var paciente in pacientes) {
            final pacienteId = paciente['id'].toString();
            await service.enviarAtividadeParaPaciente(
              atividadeId: atividadeId,
              pacienteId: pacienteId,
              dataLimite: dataInicio.add(const Duration(days: 7)).toUtc(), // 7 dias padrão ou custom
            );
          }
        } else if (tipoDestino == 'especifico' && pacienteSelecionadoId != null) {
          // Envia para o paciente selecionado
          await service.enviarAtividadeParaPaciente(
            atividadeId: atividadeId,
            pacienteId: pacienteSelecionadoId!,
            dataLimite: dataInicio.add(const Duration(days: 7)).toUtc(),
          );
        }
      }

      setState(() {
        passoAtual = 5; // Sucesso
      });

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar atividade: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Nova atividade',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.text),
          onPressed: () {
            if (passoAtual > 0 && passoAtual < 5) {
              setState(() => passoAtual--);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Column(
        children: [
          if (passoAtual < 5) _buildStepperHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: _buildPassoConteudo(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: passoAtual == 5 ? null : _buildBottomNavigation(),
    );
  }

  Widget _buildStepperHeader() {
    final passos = ['Tipo', 'Conteúdo', 'Ajustes', 'Agenda', 'Revisar'];
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(passos.length * 2 - 1, (index) {
          if (index.isOdd) {
            // Linha conectora
            final passoIndex = index ~/ 2;
            final active = passoIndex < passoAtual;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  height: 2,
                  color: active ? AppColors.secondary : AppColors.border,
                ),
              ),
            );
          } else {
            // Item do passo
            final passoIndex = index ~/ 2;
            final active = passoIndex <= passoAtual;
            final current = passoIndex == passoAtual;
            
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: current 
                        ? AppColors.secondary 
                        : (active ? AppColors.secondary.withOpacity(0.2) : Colors.white),
                    border: Border.all(
                      color: active ? AppColors.secondary : AppColors.border,
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${passoIndex + 1}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: current ? Colors.white : (active ? AppColors.primary : AppColors.muted),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  passos[passoIndex],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: active ? FontWeight.bold : FontWeight.w500,
                    color: active ? AppColors.primary : AppColors.muted,
                  ),
                ),
              ],
            );
          }
        }),
      ),
    );
  }

  Widget _buildPassoConteudo() {
    switch (passoAtual) {
      case 0:
        return _buildPassoTipo();
      case 1:
        return _buildPassoConteudoAtividade();
      case 2:
        return _buildPassoConfiguracoes();
      case 3:
        return _buildPassoAgendamento();
      case 4:
        return _buildPassoRevisao();
      case 5:
        return _buildPassoSucesso();
      default:
        return Container();
    }
  }

  // --- PASSO 1: TIPO DE ATIVIDADE ---
  Widget _buildPassoTipo() {
    final tipos = [
      {'id': 1, 'titulo': 'Reflexão', 'desc': 'Perguntas para reflexão emocional.', 'cor': const Color(0xFFF0ECFF), 'icone': LucideIcons.brain},
      {'id': 2, 'titulo': 'Registro de pensamentos', 'desc': 'Identificação de pensamentos automáticos de TCC.', 'cor': const Color(0xFFFFF3E3), 'icone': LucideIcons.messageSquare},
      {'id': 3, 'titulo': 'Exercício prático', 'desc': 'Atividade prática, mindfulness ou tarefa terapêutica.', 'cor': const Color(0xFFFFF9E6), 'icone': LucideIcons.dumbbell},
      {'id': 4, 'titulo': 'Check-list', 'desc': 'Lista de ações simples para o paciente marcar.', 'cor': const Color(0xFFE6F5F2), 'icone': LucideIcons.clipboardList},
      {'id': 5, 'titulo': 'Áudio', 'desc': 'Áudio explicativo ou meditação guiada.', 'cor': const Color(0xFFEAF4F7), 'icone': LucideIcons.headphones},
      {'id': 6, 'titulo': 'Leitura', 'desc': 'Textos psicoeducativos para o paciente ler.', 'cor': const Color(0xFFFFF0F0), 'icone': LucideIcons.bookOpen},
      {'id': 7, 'titulo': 'Jogo', 'desc': 'Jogos interativos de memória e cognitivos.', 'cor': const Color(0xFFE8F5E9), 'icone': LucideIcons.gamepad2},
    ];

    return Column(
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
        ...tipos.map((tipo) {
          final selecionado = tipoSelecionado == tipo['id'];
          return GestureDetector(
            onTap: () {
              setState(() {
                tipoSelecionado = tipo['id'] as int;
                _aplicarTemplateAtividade(tipoSelecionado);
              });
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selecionado ? AppColors.secondary : AppColors.border,
                  width: selecionado ? 2 : 1,
                ),
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
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: tipo['cor'] as Color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(tipo['icone'] as IconData, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tipo['titulo'] as String,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.text),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tipo['desc'] as String,
                          style: const TextStyle(color: AppColors.muted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  if (selecionado)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.check, color: Colors.white, size: 14),
                    )
                  else
                    const Icon(LucideIcons.chevronRight, color: AppColors.muted, size: 20),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // --- PASSO 2: CONTEÚDO DA ATIVIDADE ---
  Widget _buildPassoConteudoAtividade() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Conteúdo da atividade',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.text),
        ),
        const SizedBox(height: 4),
        const Text(
          'Crie o conteúdo que será apresentado ao paciente.',
          style: TextStyle(fontSize: 14, color: AppColors.muted),
        ),
        const SizedBox(height: 24),
        
        const Text(
          'Título da atividade',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.text),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: tituloController,
          decoration: InputDecoration(
            hintText: 'Ex: Diário de gratidão',
            filled: true,
            fillColor: const Color(0xFFF4F6F9),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 20),

        const Text(
          'Descrição para o paciente',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.text),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: descricaoController,
          maxLines: 4,
          maxLength: 500,
          decoration: InputDecoration(
            hintText: 'Explique como realizar o exercício...',
            filled: true,
            fillColor: const Color(0xFFF4F6F9),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 20),

        if (tipoSelecionado != 7) ...[
          Text(
            tipoSelecionado == 4 ? 'Itens do check-list' : (tipoSelecionado == 2 ? 'Campos do registro' : 'Perguntas guiadas'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.text),
          ),
          const SizedBox(height: 8),
          Column(
            children: List.generate(perguntasControllers.length, (index) {
              final controller = perguntasControllers[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TextField(
                  controller: controller,
                  onChanged: (val) {
                    perguntasGuiadas[index] = val;
                  },
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 16, top: 14, bottom: 14, right: 8),
                      child: Text(
                        '${index + 1}. ',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 14),
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 18),
                      onPressed: () => removerPergunta(index),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  style: const TextStyle(fontSize: 14, color: AppColors.text),
                ),
              );
            }),
          ),
          
          const SizedBox(height: 8),
          TextField(
            controller: novaPerguntaController,
            decoration: InputDecoration(
              hintText: tipoSelecionado == 4 ? 'Escreva um novo item...' : 'Escreva uma nova pergunta...',
              filled: true,
              fillColor: const Color(0xFFF4F6F9),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixIcon: Container(
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.white, size: 20),
                  onPressed: adicionarPergunta,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ),
            ),
          ),
        ] else ...[
          _buildConfiguracaoJogo(),
        ],
        const SizedBox(height: 32),

        const Text(
          'Recursos adicionais (opcional)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.text),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildRecursoBotao('Áudio', Icons.headset),
            _buildRecursoBotao('Imagem', Icons.image),
            _buildRecursoBotao('PDF', Icons.description),
            _buildRecursoBotao('Vídeo', Icons.play_circle_outline),
          ],
        ),
      ],
    );
  }

  Widget _buildRecursoBotao(String label, IconData icone) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icone, color: AppColors.primary, size: 22),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.muted)),
        ],
      ),
    );
  }

  // --- PASSO 3: CONFIGURAÇÕES DA ATIVIDADE ---
  Widget _buildPassoConfiguracoes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Configurações da atividade',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.text),
        ),
        const SizedBox(height: 4),
        const Text(
          'Defina como a atividade funcionará para o paciente.',
          style: TextStyle(fontSize: 14, color: AppColors.muted),
        ),
        const SizedBox(height: 24),

        if (tipoSelecionado != 7) ...[
          const Text(
            'Tipo de resposta',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.text),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: const Color(0xFFF4F6F9), borderRadius: BorderRadius.circular(12)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: tipoResposta,
                isExpanded: true,
                icon: const Icon(LucideIcons.chevronDown, color: AppColors.muted),
                items: ['Texto (resposta livre)', 'Escolha única', 'Áudio gravado']
                    .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => tipoResposta = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Atividade obrigatória?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.text),
            ),
            Row(
              children: [
                _buildSelecaoBotao('Sim', atividadeObrigatoria, () => setState(() => atividadeObrigatoria = true)),
                const SizedBox(width: 8),
                _buildSelecaoBotao('Não', !atividadeObrigatoria, () => setState(() => atividadeObrigatoria = false)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Permitir anexos?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.text),
                ),
                Text('Paciente poderá enviar arquivos de suporte.', style: TextStyle(fontSize: 11, color: AppColors.muted)),
              ],
            ),
            Switch(
              value: permitirAnexos,
              activeColor: AppColors.secondary,
              onChanged: (val) => setState(() => permitirAnexos = val),
            ),
          ],
        ),
        const SizedBox(height: 20),

        const Text(
          'Feedback automático (opcional)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.text),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: feedbackController,
          decoration: InputDecoration(
            hintText: 'Mensagem de incentivo após a conclusão...',
            filled: true,
            fillColor: const Color(0xFFF4F6F9),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 20),

        const Text(
          'Categoria emocional',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.text),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: const Color(0xFFF4F6F9), borderRadius: BorderRadius.circular(12)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: categoriaEmocional,
              isExpanded: true,
              icon: const Icon(LucideIcons.chevronDown, color: AppColors.muted),
              items: ['Ansiedade', 'Depressão', 'Estresse', 'Felicidade', 'Raiva', 'Outro']
                  .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => categoriaEmocional = val);
              },
            ),
          ),
        ),
        const SizedBox(height: 20),

        const Text(
          'Nível sugerido',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.text),
        ),
        const SizedBox(height: 10),
        Row(
          children: ['Leve', 'Moderado', 'Intenso'].map((nivel) {
            final ativo = nivelSugerido == nivel;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => nivelSugerido = nivel),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: ativo ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ativo ? AppColors.primary : AppColors.border),
                  ),
                  child: Center(
                    child: Text(
                      nivel,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: ativo ? Colors.white : AppColors.muted,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        const Text(
          'Nível de Desbloqueio (Gamificação)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.text),
        ),
        const SizedBox(height: 10),
        Row(
          children: [1, 2, 3, 4, 5].map((nivel) {
            final ativo = nivelAtividade == nivel;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => nivelAtividade = nivel),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: ativo ? AppColors.secondary : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ativo ? AppColors.secondary : AppColors.border),
                  ),
                  child: Center(
                    child: Text(
                      'Nível $nivel',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: ativo ? Colors.white : AppColors.muted,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSelecaoBotao(String label, bool ativo, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: ativo ? AppColors.secondary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ativo ? AppColors.secondary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: ativo ? Colors.white : AppColors.muted,
          ),
        ),
      ),
    );
  }

  // --- PASSO 4: AGENDAMENTO ---
  Widget _buildPassoAgendamento() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Agendamento da atividade',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.text),
        ),
        const SizedBox(height: 4),
        const Text(
          'Defina quando o paciente deverá realizar o exercício.',
          style: TextStyle(fontSize: 14, color: AppColors.muted),
        ),
        const SizedBox(height: 24),

        const Text(
          'Frequência',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.text),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: const Color(0xFFF4F6F9), borderRadius: BorderRadius.circular(12)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: frequencia,
              isExpanded: true,
              icon: const Icon(LucideIcons.chevronDown, color: AppColors.muted),
              items: ['Diária', 'Semanal', 'Mensal', 'Única vez']
                  .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => frequencia = val);
              },
            ),
          ),
        ),
        const SizedBox(height: 20),

        if (frequencia == 'Semanal') ...[
          const Text(
            'Repetir nos dias',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.text),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: todosDias.map((dia) {
              final ativo = diasSemana.contains(dia);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (ativo) {
                      diasSemana.remove(dia);
                    } else {
                      diasSemana.add(dia);
                    }
                  });
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: ativo ? AppColors.primary : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: ativo ? AppColors.primary : AppColors.border),
                  ),
                  child: Center(
                    child: Text(
                      dia,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: ativo ? Colors.white : AppColors.muted,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Data de início',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.text),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: escolherDataInicio,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(color: const Color(0xFFF4F6F9), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.calendar, color: AppColors.primary, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            '${dataInicio.day.toString().padLeft(2, '0')}/${dataInicio.month.toString().padLeft(2, '0')}/${dataInicio.year}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.text),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Horário sugerido',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.text),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: escolherHorario,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(color: const Color(0xFFF4F6F9), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.clock, color: AppColors.primary, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            '${horarioSugerido.hour.toString().padLeft(2, '0')}:${horarioSugerido.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.text),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        const Text(
          'Prazo para conclusão',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.text),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: const Color(0xFFF4F6F9), borderRadius: BorderRadius.circular(12)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: prazoConclusao,
              isExpanded: true,
              icon: const Icon(LucideIcons.chevronDown, color: AppColors.muted),
              items: ['24 horas após o envio', '3 dias após o envio', '7 dias após o envio', '14 dias após o envio']
                  .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => prazoConclusao = val);
              },
            ),
          ),
        ),
        const SizedBox(height: 24),

        const Text(
          'Notificações de envio',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.text),
        ),
        const SizedBox(height: 10),
        _buildNotifSwitch('Push (notificação direta no app)', notificarPush, (v) => setState(() => notificarPush = v)),
        _buildNotifSwitch('E-mail explicativo', notificarEmail, (v) => setState(() => notificarEmail = v)),
        _buildNotifSwitch('Lembrete suave de 24h', lembreteSuave, (v) => setState(() => lembreteSuave = v)),
      ],
    );
  }

  Widget _buildNotifSwitch(String label, bool valor, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.text, fontWeight: FontWeight.w500)),
        Switch(value: valor, activeColor: AppColors.secondary, onChanged: onChanged),
      ],
    );
  }

  // --- PASSO 5: REVISÃO DA ATIVIDADE ---
  Widget _buildPassoRevisao() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Revisão da atividade',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.text),
        ),
        const SizedBox(height: 4),
        const Text(
          'Revise os detalhes e selecione quem receberá esta atividade.',
          style: TextStyle(fontSize: 14, color: AppColors.muted),
        ),
        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      tituloController.text,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.softGreen, borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      nivelSugerido,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                descricaoController.text,
                style: const TextStyle(fontSize: 13, color: AppColors.muted, height: 1.4),
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.border),
              const SizedBox(height: 10),
              _buildRevisaoItem('Frequência:', frequencia),
              _buildRevisaoItem('Início:', '${dataInicio.day.toString().padLeft(2, '0')}/${dataInicio.month.toString().padLeft(2, '0')}/${dataInicio.year} às ${horarioSugerido.hour.toString().padLeft(2, '0')}:${horarioSugerido.minute.toString().padLeft(2, '0')}'),
              _buildRevisaoItem('Prazo de Conclusão:', prazoConclusao),
              _buildRevisaoItem('Categoria Emocional:', categoriaEmocional),
              _buildRevisaoItem('Obrigatória:', atividadeObrigatoria ? 'Sim' : 'Não'),
              if (tipoSelecionado == 7) ...[
                _buildRevisaoItem('Jogo:', '$jogoSelecionado ($modoJogo)'),
                _buildRevisaoItem('Tema:', temaJogo),
                _buildRevisaoItem('Dificuldade:', dificuldadeJogo),
              ] else ...[
                _buildRevisaoItem('Perguntas Criadas:', '${perguntasGuiadas.length} perguntas'),
              ],
            ],
          ),
        ),
        const SizedBox(height: 28),

        const Text(
          'Destinatário do envio',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.text),
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            _buildRadioDestino('todos', 'Enviar para todos os meus pacientes ativos', 'Todos na sua lista receberão uma notificação.'),
            _buildRadioDestino('especifico', 'Enviar para um paciente em específico', 'Selecione individualmente na caixa abaixo.'),
            _buildRadioDestino('nenhum', 'Apenas salvar no banco (para enviar depois)', 'A atividade estará salva para envio a qualquer momento.'),
          ],
        ),

        if (tipoDestino == 'especifico') ...[
          const SizedBox(height: 16),
          carregandoPacientes
              ? const Center(child: CircularProgressIndicator())
              : pacientes.isEmpty
                  ? const Text('Nenhum paciente cadastrado.', style: TextStyle(color: AppColors.danger))
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(color: const Color(0xFFF4F6F9), borderRadius: BorderRadius.circular(12)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: pacienteSelecionadoId,
                          isExpanded: true,
                          icon: const Icon(LucideIcons.chevronDown, color: AppColors.muted),
                          items: pacientes
                              .map((p) => DropdownMenuItem(
                                    value: p['id']?.toString(),
                                    child: Text(p['nome']?.toString() ?? 'Paciente'),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => pacienteSelecionadoId = val);
                          },
                        ),
                      ),
                    ),
        ],
      ],
    );
  }

  Widget _buildRevisaoItem(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.text)),
          const SizedBox(width: 8),
          Expanded(child: Text(valor, style: const TextStyle(fontSize: 12, color: AppColors.muted))),
        ],
      ),
    );
  }

  Widget _buildRadioDestino(String valor, String titulo, String desc) {
    final selecionado = tipoDestino == valor;
    return GestureDetector(
      onTap: () => setState(() => tipoDestino = valor),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selecionado ? AppColors.secondary : AppColors.border, width: selecionado ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: selecionado ? AppColors.secondary : AppColors.border, width: 2),
                color: selecionado ? AppColors.secondary : Colors.transparent,
              ),
              child: selecionado ? const Icon(LucideIcons.check, color: Colors.white, size: 12) : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.text)),
                  const SizedBox(height: 2),
                  Text(desc, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- PASSO 6: SUCESSO ---
  Widget _buildPassoSucesso() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 60),
        Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.softGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.check, color: AppColors.secondary, size: 56),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Atividade enviada com sucesso!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.text),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            tipoDestino == 'todos'
                ? 'Seus pacientes ativos foram notificados e já podem iniciar a atividade.'
                : tipoDestino == 'especifico'
                    ? 'Seu paciente foi notificado e poderá realizar a atividade a qualquer momento.'
                    : 'A atividade foi cadastrada com sucesso e está pronta para ser enviada posteriormente.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted, fontSize: 14, height: 1.4),
          ),
        ),
        const SizedBox(height: 60),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Ver atividades'),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                passoAtual = 0;
                tituloController.clear();
                descricaoController.clear();
                perguntasGuiadas.clear();
                novaPerguntaController.clear();
                tipoDestino = 'todos';
              });
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Criar outra atividade', style: TextStyle(color: AppColors.primary)),
          ),
        ),
      ],
    );
  }

  String _getDescricaoDetalhadaJogo(String jogo) {
    switch (jogo) {
      case 'Decisão Sob Pressão':
        return 'Treinamento de controle inibitório e regulação de emoções. O paciente visualiza uma situação de alta pressão, faz uma pausa para respiração profunda guiada e seleciona a melhor atitude consciente.';
      case 'Missão Foco':
        return 'Treina o controle inibitório e atenção seletiva. O jogador deve responder rapidamente apenas aos comandos "EXECUTE", ignorando comandos "IGNORE".';
      case 'Memória Tática':
        return 'Treino de memória operacional visual. O paciente memoriza uma grade de pastas e arquivos, descobre qual deles sumiu e o identifica na lista.';
      case 'Investigação':
        return 'Treino de memória operacional verbal. O paciente lê um depoimento textual de um mistério, entende as declarações e responde a uma pergunta surpresa de compreensão de detalhes.';
      case 'Modo Piloto':
        return 'Treinamento de controle inibitório e tempo de reflexão. Em uma situação de estresse ou impulso, o jogador desativa o piloto automático seguindo um checklist de desaceleração.';
      case 'Laboratório Mental':
        return 'Treina a flexibilidade cognitiva e criatividade verbal. O paciente altera uma letra por vez de forma flexível para encadear palavras corretas (ex: GATO -> PATO -> MATO).';
      case 'Mente Flexível':
        return 'Treina a flexibilidade cognitiva e adaptação rápida. O jogador classifica objetos de acordo com regras que mudam de repente no jogo (cores, tamanhos ou lados).';
      case 'Shark Mind':
        return 'Estimula a criatividade e fluência verbal. O paciente deve gravar um pitch criativo de 30 segundos vendendo um item comum para um comprador incomum.';
      case 'Universos Paralelos':
        return 'Estimula o pensamento divergente e originalidade. Diante de um cenário hipotético alternativo ("E se..."), o paciente cria e expressa sua própria versão da história.';
      case 'Reação Zero':
        return 'Treina a inibição motora e tempo de reação. O jogador deve responder tocando rápido nos sinais "TOQUE" e se conter completamente nos sinais "NÃO TOQUE" ou "CONGELAR!".';
      case 'Detetive dos Pensamentos':
        return 'Baseado em TCC. O paciente passa pelo fluxo: Situação ➔ Pensamento ➔ Emoção ➔ Intensidade ➔ Reestruturação Cognitiva. Ideal para identificar e reestruturar pensamentos automáticos.';
      case 'Tribunal dos Pensamentos':
        return 'Coloque os pensamentos disfuncionais em julgamento. O paciente analisa as Evidências a Favor e as Evidências Contra antes de emitir um Veredito equilibrado.';
      case 'Caçador de Gatilhos':
        return 'Ajuda o paciente a mapear os gatilhos emocionais da semana, registrando a situação, emoção e intensidade para gerar gráficos e relatórios na evolução.';
      case 'Missão Coragem':
        return 'Baseado em Exposição Gradual. O paciente escolhe desafios de enfrentamento, avalia o nível de ansiedade esperado/real e acompanha sua taxa de sucesso.';
      case 'O Monstro da Ansiedade':
        return 'Mapeamento corporal da ansiedade. O paciente identifica em quais partes do corpo sente os sintomas físicos e aprende técnicas de regulação direcionadas.';
      case 'Ilha das Emoções':
        return 'Uma jornada lúdica de exploração de sentimentos. Ajuda crianças e adolescentes a nomear emoções e descobrir estratégias de autorregulação.';
      case 'Cartas dos Sabotadores':
        return 'Ajuda a identificar a voz dos sabotadores internos (o Crítico, o Perfeccionista, o Hiper-realizador) e ensina a responder a cada um deles.';
      case 'Escape Room Terapêutico':
        return 'Desafios e enigmas focados em conceitos de TCC. O paciente resolve problemas de reestruturação cognitiva para conseguir "escapar" das salas virtuais.';
      case 'Jornada do Herói Interior':
        return 'Usa a metáfora da Jornada do Herói para ressignificar traumas e desafios pessoais, promovendo a autoestima e a autocompaixão.';
      default:
        return 'Realize a atividade terapêutica do jogo selecionado.';
    }
  }

  String _getMetricasJogo(String jogo) {
    switch (jogo) {
      case 'Decisão Sob Pressão':
        return '• Assertividade nas ações tomadas\n• Conclusão de ciclos respiratórios de controle';
      case 'Missão Foco':
        return '• Precisão de foco (% acertos)\n• Tempo de reação e impulsividade';
      case 'Memória Tática':
        return '• Acurácia na identificação do arquivo sumido\n• Capacidade de memorização e retenção visual';
      case 'Investigação':
        return '• Taxa de acertos em detalhes do depoimento\n• Retenção e compreensão de informações verbais';
      case 'Modo Piloto':
        return '• Taxa de sucesso na execução de checklists conscientes\n• Tempo de reflexão antes de agir';
      case 'Laboratório Mental':
        return '• Rapidez em transicionar anagramas de letras\n• Flexibilidade em associações fonéticas/ortográficas';
      case 'Mente Flexível':
        return '• Taxa de acertos na classificação sob mudança de regra\n• Velocidade de adaptação mental';
      case 'Shark Mind':
        return '• Tempo de pitch gravado\n• Criatividade e fluência verbal na persuasão';
      case 'Universos Paralelos':
        return '• Originalidade na escolha de mídias de resposta\n• Detalhamento e profundidade do pensamento alternativo';
      case 'Reação Zero':
        return '• Acurácia sob sinais contraditórios\n• Nível de inibição motora e tempo de reação';
      case 'Detetive dos Pensamentos':
        return '• Frequência de pensamentos catastróficos\n• Emoções mais sentidas e intensidade média\n• Qualidade da reestruturação cognitiva';
      case 'Tribunal dos Pensamentos':
        return '• Quantidade de evidências a favor e contra listadas\n• Tipo de decisão/veredito final atingido';
      case 'Caçador de Gatilhos':
        return '• Situações-gatilho mais frequentes\n• Nível de intensidade emocional média';
      case 'Missão Coragem':
        return '• Desafios de exposição gradual concluídos\n• Taxa de sucesso e desistência de tarefas';
      case 'O Monstro da Ansiedade':
        return '• Mapeamento corporal de sintomas físicos\n• Eficácia percebida dos exercícios de respiração/relaxamento';
      case 'Ilha das Emoções':
        return '• Frequência de emoções exploradas\n• Estratégias de autorregulação preferidas';
      case 'Cartas dos Sabotadores':
        return '• Sabotadores internos mais ativos/selecionados\n• Força das respostas saudáveis criadas';
      case 'Escape Room Terapêutico':
        return '• Tempo de resolução de enigmas cognitivos\n• Taxa de acerto em conceitos de distorções cognitivas';
      case 'Jornada do Herói Interior':
        return '• Nível de resiliência e autocompaixão expressos\n• Desafios ressignificados';
      default:
        return '• Participação e conclusão da atividade';
    }
  }

  Widget _buildConfiguracaoJogo() {
    final temasImagens = ['Expressões/Emoções', 'Animais', 'Natureza'];
    final temasPalavras = ['Sentimentos/Emoções', 'Animais', 'Personalizado'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Configurações do Jogo',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.text),
        ),
        const SizedBox(height: 12),

        // Tipo de Jogo (Dropdown)
        const Text(
          'Selecione o Jogo',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.muted),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: const Color(0xFFF4F6F9), borderRadius: BorderRadius.circular(12)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: jogoSelecionado,
              isExpanded: true,
              icon: const Icon(LucideIcons.chevronDown, color: AppColors.muted),
              items: [
                'Decisão Sob Pressão',
                'Missão Foco',
                'Memória Tática',
                'Investigação',
                'Modo Piloto',
                'Laboratório Mental',
                'Mente Flexível',
                'Shark Mind',
                'Universos Paralelos',
                'Reação Zero',
                'Detetive dos Pensamentos',
                'Tribunal dos Pensamentos',
                'Caçador de Gatilhos',
                'Missão Coragem',
                'O Monstro da Ansiedade',
                'Ilha das Emoções',
                'Cartas dos Sabotadores',
                'Escape Room Terapêutico',
                'Jornada do Herói Interior'
              ].map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    jogoSelecionado = val;
                    tituloController.text = val;
                    descricaoController.text = 'Realize a atividade terapêutica do jogo: $val';
                  });
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 16),

        if (jogoSelecionado == 'Memória Tática') ...[
          // Modo do Jogo: Imagens ou Palavras
          const Text(
            'Modo do Jogo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      modoJogo = 'Imagens';
                      temaJogo = 'Expressões/Emoções';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: modoJogo == 'Imagens' ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: modoJogo == 'Imagens' ? AppColors.primary : AppColors.border),
                    ),
                    child: Center(
                      child: Text(
                        'Imagens (Emojis)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: modoJogo == 'Imagens' ? Colors.white : AppColors.muted,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      modoJogo = 'Palavras';
                      temaJogo = 'Sentimentos/Emoções';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: modoJogo == 'Palavras' ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: modoJogo == 'Palavras' ? AppColors.primary : AppColors.border),
                    ),
                    child: Center(
                      child: Text(
                        'Palavras',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: modoJogo == 'Palavras' ? Colors.white : AppColors.muted,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tema do Jogo
          const Text(
            'Tema do Jogo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: const Color(0xFFF4F6F9), borderRadius: BorderRadius.circular(12)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: temaJogo,
                isExpanded: true,
                icon: const Icon(LucideIcons.chevronDown, color: AppColors.muted),
                items: (modoJogo == 'Imagens' ? temasImagens : temasPalavras)
                    .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => temaJogo = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Caso seja palavras personalizadas, campo de entrada
          if (modoJogo == 'Palavras' && temaJogo == 'Personalizado') ...[
            const Text(
              'Palavras personalizadas (separadas por vírgula)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.muted),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: customPalavrasController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Ex: Calma, Ansiedade, Foco, Força, Paciência',
                filled: true,
                fillColor: const Color(0xFFF4F6F9),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Dificuldade
          const Text(
            'Dificuldade do Jogo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 8),
          Row(
            children: ['Fácil', 'Médio', 'Difícil', 'Evolutivo'].map((dif) {
              final ativo = dificuldadeJogo == dif;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => dificuldadeJogo = dif),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: ativo ? AppColors.secondary : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: ativo ? AppColors.secondary : AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Text(
                          dif,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: ativo ? Colors.white : AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dif == 'Fácil'
                              ? '6 cartas'
                              : dif == 'Médio'
                                  ? '12 cartas'
                                  : dif == 'Difícil'
                                      ? '16 cartas'
                                      : 'Nível pac.',
                          style: TextStyle(
                            fontSize: 9,
                            color: ativo ? Colors.white.withOpacity(0.8) : AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ] else ...[
          // Informações do Jogo Terapêutico Selecionado
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.05),
                  AppColors.secondary.withOpacity(0.05)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.info, color: AppColors.secondary, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Funcionamento do Jogo',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _getDescricaoDetalhadaJogo(jogoSelecionado),
                  style: const TextStyle(fontSize: 13, color: AppColors.text, height: 1.4),
                ),
                const SizedBox(height: 16),
                const Divider(color: AppColors.border),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(LucideIcons.activity, color: AppColors.secondary, size: 16),
                    const SizedBox(width: 8),
                    const Text(
                      'Métricas que serão coletadas:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.text),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _getMetricasJogo(jogoSelecionado),
                  style: const TextStyle(fontSize: 12, color: AppColors.muted, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, -5)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (passoAtual > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  if (passoAtual > 0) {
                    setState(() => passoAtual--);
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Voltar', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
            )
          else
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Cancelar', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
            ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: salvando ? null : () {
                if (passoAtual < 4) {
                  setState(() => passoAtual++);
                } else {
                  concluirWizard();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: salvando
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(passoAtual == 4 ? 'Publicar' : 'Próximo'),
            ),
          ),
        ],
      ),
    );
  }
}
