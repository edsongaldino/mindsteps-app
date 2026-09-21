import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
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
  
  // Anexo de Áudio/Vídeo para o Tipo Áudio
  String opcaoMidiaAudio = 'gravar'; // 'gravar' ou 'upload'
  bool gravandoAudio = false;
  int duracaoGravacaoSegundos = 0;
  Timer? timerGravacao;
  bool reproduzindoAudio = false;
  String? arquivoMidiaNome;
  String? arquivoMidiaCaminho;
  String? arquivoMidiaTipo;
  
  // Passo 2: Conteúdo por Tipo
  final tituloController = TextEditingController(text: 'Reflexão sobre ansiedade social');
  final descricaoController = TextEditingController(
    text: 'Esta atividade tem como objetivo te ajudar a refletir sobre situações sociais que geram ansiedade e identificar pensamentos e emoções envolvidas.',
  );

  // Tipo 1: Reflexão & Tipo 5: Áudio (Perguntas Guiadas)
  List<String> perguntasGuiadas = [
    'O que aconteceu na situação?',
    'Quais emoções você sentiu e com qual intensidade?',
    'O que passou pela sua mente naquele momento?',
  ];
  List<TextEditingController> perguntasControllers = [];
  final novaPerguntaController = TextEditingController();

  // Tipo 2: Registro de Pensamentos (RPD)
  String templateRpd = 'TCC Padrão (5 Colunas)';
  List<String> rpdColunas = [
    'Situação (Onde/Quando)',
    'Emoções & Intensidade (0-100)',
    'Pensamento Automático Disfuncional',
    'Resposta Alternativa / Racional',
    'Reavaliação Emocional (0-100)',
  ];
  bool rpdIncluirEvidencias = true;

  // Tipo 3: Exercício Prático
  int exercicioDuracaoMinutos = 5;
  bool exercicioMedirPrePos = true;
  List<String> exercicioPassos = [
    'Sente-se em uma posição confortável com as costas eretas.',
    'Inspire suavemente pelo nariz contando até 4.',
    'Retenha o ar nos pulmões por 2 segundos.',
    'Expire devagar pela boca contando até 6.',
    'Repita o ciclo por 5 minutos mantendo o foco na respiração.',
  ];
  List<TextEditingController> exercicioPassosControllers = [];
  final novoExercicioPassoController = TextEditingController();

  // Tipo 4: Checklist
  List<String> checklistItens = [
    'Tomar água regularmente (mínimo 2 litros)',
    'Praticar ao menos 15 min de atividade física ou caminhada',
    'Pausa de 5 min para descompressão sem telas',
    'Registrar um aspecto positivo ou gratidão do dia',
  ];
  List<TextEditingController> checklistItensControllers = [];
  final novoChecklistItemController = TextEditingController();

  // Tipo 6: Leitura Psicoeducativa
  final leituraTextoController = TextEditingController(
    text: 'A ansiedade é uma resposta fisiológica e emocional natural do ser humano diante da percepção de perigo ou incerteza.\n\nQuando percebemos uma ameaça, nosso cérebro ativa o sistema nervoso simpático, provocando taquicardia, respiração acelerada e tensão muscular. Na TCC, aprendemos que não são as situações em si que causam a ansiedade, mas a forma como as interpretamos.\n\nAo identificar pensamentos catastróficos, podemos questionar sua veracidade e desenvolver uma perspectiva mais coerente e funcional.',
  );
  int leituraTempoEstimadoMinutos = 3;
  List<String> leituraPerguntasFixacao = [
    'Qual a principal diferença entre a situação em si e a interpretação cognitiva?',
    'Como você pode aplicar o questionamento de pensamentos no seu dia a dia?',
  ];
  List<TextEditingController> leituraPerguntasControllers = [];
  final novaLeituraPerguntaController = TextEditingController();

  // Passo 2 (Jogo): Conteúdo Jogo
  String jogoSelecionado = 'Memória Tática';
  String modoJogo = 'Imagens'; // 'Imagens' ou 'Palavras'
  String temaJogo = 'Expressões/Emoções'; // Expressões/Emoções, Animais, Natureza
  String dificuldadeJogo = 'Evolutivo'; // Fácil, Médio, Difícil, Evolutivo
  final customPalavrasController = TextEditingController(text: 'Alegria, Tristeza, Raiva, Medo, Nojo, Surpresa');

  // Tipo 8: Atividade Personalizada
  final tituloPersonalizadaController = TextEditingController();
  final orientacoesPersonalizadaController = TextEditingController();
  List<Map<String, dynamic>> perguntasPersonalizadas = [];

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
    _sincronizarControllers();
    _carregarPacientes();
  }

  @override
  void dispose() {
    timerGravacao?.cancel();
    tituloController.dispose();
    descricaoController.dispose();
    novaPerguntaController.dispose();
    novoExercicioPassoController.dispose();
    novoChecklistItemController.dispose();
    leituraTextoController.dispose();
    novaLeituraPerguntaController.dispose();
    feedbackController.dispose();
    customPalavrasController.dispose();
    tituloPersonalizadaController.dispose();
    orientacoesPersonalizadaController.dispose();
    for (var c in perguntasControllers) {
      c.dispose();
    }
    for (var c in exercicioPassosControllers) {
      c.dispose();
    }
    for (var c in checklistItensControllers) {
      c.dispose();
    }
    for (var c in leituraPerguntasControllers) {
      c.dispose();
    }
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
      _sincronizarPacienteSelecionado();
    } catch (e) {
      debugPrint('Erro ao carregar pacientes: $e');
    } finally {
      setState(() => carregandoPacientes = false);
    }
  }

  void _sincronizarPacienteSelecionado() {
    final elegiveis = pacientes.where((p) => (p['nivel'] as int? ?? 1) >= nivelAtividade).toList();
    if (pacienteSelecionadoId != null && !elegiveis.any((p) => p['id']?.toString() == pacienteSelecionadoId)) {
      setState(() {
        pacienteSelecionadoId = elegiveis.isNotEmpty ? elegiveis.first['id']?.toString() : null;
      });
    }
  }

  void _aplicarTemplateAtividade(int tipo) {
    switch (tipo) {
      case 1: // Reflexão
        tituloController.text = 'Reflexão sobre emoções';
        descricaoController.text = 'Esta atividade tem como objetivo te ajudar a refletir sobre situações recentes e identificar pensamentos e emoções envolvidas.';
        perguntasGuiadas = [
          'O que aconteceu na situação?',
          'Quais emoções você sentiu e com qual intensidade?',
          'O que passou pela sua mente naquele momento?',
          'Como você reagiu ou se comportou?',
        ];
        tipoResposta = 'Texto (resposta livre)';
        break;
      case 2: // Registro de Pensamentos (RPD)
        tituloController.text = 'Registro de Pensamentos Disfuncionais (RPD)';
        descricaoController.text = 'Identifique a situação gatilho, seus pensamentos automáticos e elabore respostas alternativas equilibradas.';
        templateRpd = 'TCC Padrão (5 Colunas)';
        rpdColunas = [
          'Situação (Onde/Quando)',
          'Emoções & Intensidade (0-100)',
          'Pensamento Automático Disfuncional',
          'Resposta Alternativa / Racional',
          'Reavaliação Emocional (0-100)',
        ];
        rpdIncluirEvidencias = true;
        tipoResposta = 'Estrutura RPD (Tabela de Colunas)';
        break;
      case 3: // Exercício Prático
        tituloController.text = 'Respiração Diafragmática 4-2-6';
        descricaoController.text = 'Exercício prático de regulação autonômica para redução imediata de ansiedade e hiper-arousal.';
        exercicioDuracaoMinutos = 5;
        exercicioMedirPrePos = true;
        exercicioPassos = [
          'Sente-se em uma posição confortável com as costas eretas e ombros relaxados.',
          'Inspire suavemente pelo nariz contando mentalmente até 4.',
          'Retenha o ar nos pulmões de forma confortável por 2 segundos.',
          'Expire devagar e completamente pela boca contando até 6.',
          'Repita o ciclo por 5 minutos observando o ritmo do seu corpo.',
        ];
        tipoResposta = 'Confirmação + Avaliação Pré/Pós';
        break;
      case 4: // Check-list
        tituloController.text = 'Check-list de Autocuidado Diário';
        descricaoController.text = 'Marque os hábitos e ações que você conseguiu concluir hoje para manter seu equilíbrio emocional.';
        checklistItens = [
          'Tomar água regularmente (mínimo 2 litros)',
          'Praticar ao menos 15 min de atividade física ou caminhada',
          'Pausa de 5 min para descompressão sem telas',
          'Registrar um aspecto positivo ou gratidão do dia',
        ];
        tipoResposta = 'Marcação de Itens (Checklist)';
        break;
      case 5: // Áudio
        tituloController.text = 'Meditação Guiada para Sono';
        descricaoController.text = 'Ouça o áudio anexado antes de dormir para auxiliar no relaxamento e indução do sono.';
        perguntasGuiadas = [
          'O áudio ajudou no seu relaxamento?',
        ];
        tipoResposta = 'Texto (resposta livre)';
        break;
      case 6: // Leitura Psicoeducativa
        tituloController.text = 'O que é a Ansiedade?';
        descricaoController.text = 'Texto psicoeducativo explicando os mecanismos fisiológicos e cognitivos da ansiedade.';
        leituraTextoController.text = 'A ansiedade é uma resposta fisiológica e emocional natural do ser humano diante da percepção de perigo ou incerteza.\n\nQuando percebemos uma ameaça, nosso cérebro ativa o sistema nervoso simpático, provocando taquicardia, respiração acelerada e tensão muscular. Na TCC, aprendemos que não são as situações em si que causam a ansiedade, mas a forma como as interpretamos.\n\nAo identificar pensamentos catastróficos, podemos questionar sua veracidade e desenvolver uma perspectiva mais coerente e funcional.';
        leituraTempoEstimadoMinutos = 3;
        leituraPerguntasFixacao = [
          'Qual a principal diferença entre a situação em si e a interpretação cognitiva?',
          'Como você pode aplicar o questionamento de pensamentos no seu dia a dia?',
        ];
        tipoResposta = 'Confirmação + Perguntas de Fixação';
        break;
      case 7: // Jogo
        tituloController.text = 'Memória Tática';
        descricaoController.text = 'Observe objetos do cotidiano, identifique qual sumiu e exercite sua atenção e memória visual.';
        perguntasGuiadas = [];
        tipoResposta = 'Jogo Interativo';
        jogoSelecionado = 'Memória Tática';
        break;
      case 8: // Atividade Personalizada
        tituloPersonalizadaController.clear();
        orientacoesPersonalizadaController.clear();
        perguntasPersonalizadas = [];
        tituloController.text = '';
        descricaoController.text = '';
        tipoResposta = 'Formulário Personalizado';
        break;
    }
    _sincronizarControllers();
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

  void _sincronizarControllers() {
    perguntasControllers = perguntasGuiadas.map((p) => TextEditingController(text: p)).toList();
    exercicioPassosControllers = exercicioPassos.map((p) => TextEditingController(text: p)).toList();
    checklistItensControllers = checklistItens.map((p) => TextEditingController(text: p)).toList();
    leituraPerguntasControllers = leituraPerguntasFixacao.map((p) => TextEditingController(text: p)).toList();
  }

  void _sincronizarControllersPerguntas() {
    _sincronizarControllers();
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

  void adicionarExercicioPasso() {
    final texto = novoExercicioPassoController.text.trim();
    if (texto.isNotEmpty) {
      setState(() {
        exercicioPassos.add(texto);
        exercicioPassosControllers.add(TextEditingController(text: texto));
        novoExercicioPassoController.clear();
      });
    }
  }

  void removerExercicioPasso(int index) {
    setState(() {
      exercicioPassos.removeAt(index);
      exercicioPassosControllers.removeAt(index);
    });
  }

  void adicionarChecklistItem() {
    final texto = novoChecklistItemController.text.trim();
    if (texto.isNotEmpty) {
      setState(() {
        checklistItens.add(texto);
        checklistItensControllers.add(TextEditingController(text: texto));
        novoChecklistItemController.clear();
      });
    }
  }

  void removerChecklistItem(int index) {
    setState(() {
      checklistItens.removeAt(index);
      checklistItensControllers.removeAt(index);
    });
  }

  void adicionarLeituraPergunta() {
    final texto = novaLeituraPerguntaController.text.trim();
    if (texto.isNotEmpty) {
      setState(() {
        leituraPerguntasFixacao.add(texto);
        leituraPerguntasControllers.add(TextEditingController(text: texto));
        novaLeituraPerguntaController.clear();
      });
    }
  }

  void removerLeituraPergunta(int index) {
    setState(() {
      leituraPerguntasFixacao.removeAt(index);
      leituraPerguntasControllers.removeAt(index);
    });
  }

  Future<void> concluirWizard() async {
    final tituloEfetivo = tipoSelecionado == 8 ? tituloPersonalizadaController.text : tituloController.text;
    final descricaoEfetiva = tipoSelecionado == 8 ? orientacoesPersonalizadaController.text : descricaoController.text;

    if (tituloEfetivo.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, informe o título da atividade.')),
      );
      return;
    }

    setState(() => salvando = true);

    try {
      String? midiaUrlFinal = arquivoMidiaCaminho;
      if (tipoSelecionado == 5 && arquivoMidiaCaminho != null && !arquivoMidiaCaminho!.startsWith('http') && !arquivoMidiaCaminho!.startsWith('local_recordings')) {
        try {
          final resUpload = await service.uploadMediaAtividade(arquivoMidiaCaminho!);
          midiaUrlFinal = resUpload['url']?.toString() ?? arquivoMidiaCaminho;
        } catch (e) {
          debugPrint('Erro no upload do arquivo de mídia: $e');
        }
      }

      // 1. Criar a atividade no Banco de Dados
      // Conteúdo estruturado salvo em JSON de acordo com o tipo selecionado
      final Map<String, dynamic> conteudoReal;
      switch (tipoSelecionado) {
        case 1: // Reflexão
          conteudoReal = {
            'tipoAtividade': 'reflexao',
            'perguntas': perguntasGuiadas,
          };
          break;
        case 2: // RPD
          conteudoReal = {
            'tipoAtividade': 'rpd',
            'templateRpd': templateRpd,
            'colunas': rpdColunas,
            'incluirEvidencias': rpdIncluirEvidencias,
          };
          break;
        case 3: // Exercício Prático
          conteudoReal = {
            'tipoAtividade': 'exercicio_pratico',
            'duracaoMinutos': exercicioDuracaoMinutos,
            'medirPrePos': exercicioMedirPrePos,
            'passos': exercicioPassos,
          };
          break;
        case 4: // Checklist
          conteudoReal = {
            'tipoAtividade': 'checklist',
            'itens': checklistItens,
            'perguntas': checklistItens,
          };
          break;
        case 5: // Áudio
          conteudoReal = {
            'tipoAtividade': 'audio',
            'perguntas': perguntasGuiadas,
            if (arquivoMidiaNome != null) 'midiaNome': arquivoMidiaNome,
            if (midiaUrlFinal != null) 'midiaCaminho': midiaUrlFinal,
            if (arquivoMidiaTipo != null) 'midiaTipo': arquivoMidiaTipo,
          };
          break;
        case 6: // Leitura Psicoeducativa
          conteudoReal = {
            'tipoAtividade': 'leitura',
            'textoCorpo': leituraTextoController.text,
            'tempoEstimadoMinutos': leituraTempoEstimadoMinutos,
            'perguntasFixacao': leituraPerguntasFixacao,
            'perguntas': leituraPerguntasFixacao,
          };
          break;
        case 7: // Jogo
          conteudoReal = {
            'tipoAtividade': 'jogo',
            'tipoJogo': jogoSelecionado,
            'modo': modoJogo,
            'tema': temaJogo,
            'dificuldade': dificuldadeJogo,
            'palavrasPersonalizadas': modoJogo == 'Palavras' && temaJogo == 'Personalizado'
                ? customPalavrasController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
                : null,
          };
          break;
        case 8: // Atividade Personalizada
        default:
          conteudoReal = {
            'tipoAtividade': 'personalizada',
            'perguntas': perguntasPersonalizadas,
          };
          break;
      }

      final configuracoes = {
        'tipoResposta': tipoResposta,
        'audioUrl': (tipoSelecionado == 5 && arquivoMidiaNome != null) ? (midiaUrlFinal ?? arquivoMidiaNome) : null,
        'arquivoUrl': (arquivoMidiaNome != null) ? (midiaUrlFinal ?? arquivoMidiaNome) : null,
        'feedbackAutomatico': feedbackController.text.isNotEmpty ? feedbackController.text : null,
        if (tipoSelecionado == 7) 'nivelSugerido': nivelSugerido,
        if (tipoSelecionado == 7) 'nivel': nivelAtividade,
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
        titulo: tituloEfetivo,
        descricao: descricaoEfetiva,
        tipo: tipoSelecionado,
        conteudo: jsonEncode(conteudoReal),
        configuracoes: configuracoes,
      );

      if (tipoDestino != 'nenhum') {
        final String atividadeId = novaAtividadeId;
        
        // 2. Enviar para os pacientes selecionados
        if (tipoDestino == 'todos') {
          // Envia para todos da lista do psicólogo que possuem o nível necessário
          final pacientesElegiveis = pacientes.where((p) => (p['nivel'] as int? ?? 1) >= nivelAtividade).toList();
          for (var paciente in pacientesElegiveis) {
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
      {'id': 8, 'titulo': 'Atividade personalizada', 'desc': 'Crie uma atividade com perguntas e campos de resposta personalizados.', 'cor': const Color(0xFFEDE9FE), 'icone': LucideIcons.filePlus2},
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

  void _iniciarGravacaoAudio() {
    setState(() {
      gravandoAudio = true;
      duracaoGravacaoSegundos = 0;
      arquivoMidiaNome = null;
      arquivoMidiaCaminho = null;
    });

    timerGravacao?.cancel();
    timerGravacao = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          duracaoGravacaoSegundos++;
        });
      }
    });
  }

  void _pararGravacaoAudio() {
    timerGravacao?.cancel();
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
    setState(() {
      gravandoAudio = false;
      arquivoMidiaNome = 'instrucao_voz_$timestamp.m4a';
      arquivoMidiaCaminho = 'local_recordings/instrucao_voz_$timestamp.m4a';
      arquivoMidiaTipo = 'audio_gravado';
    });
  }

  void _cancelarGravacaoAudio() {
    timerGravacao?.cancel();
    setState(() {
      gravandoAudio = false;
      duracaoGravacaoSegundos = 0;
      arquivoMidiaNome = null;
      arquivoMidiaCaminho = null;
      arquivoMidiaTipo = null;
    });
  }

  String _formatarDuracao(int segundos) {
    final mins = (segundos ~/ 60).toString().padLeft(2, '0');
    final secs = (segundos % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  Future<void> _selecionarVideo() async {
    try {
      final picker = ImagePicker();
      final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        setState(() {
          arquivoMidiaNome = video.name;
          arquivoMidiaCaminho = video.path;
          arquivoMidiaTipo = 'video';
        });
      }
    } catch (e) {
      _exibirDialogoUrlMidia('vídeo');
    }
  }

  Future<void> _selecionarOuGravarAudio() async {
    try {
      final picker = ImagePicker();
      final XFile? media = await picker.pickMedia();
      if (media != null) {
        setState(() {
          arquivoMidiaNome = media.name;
          arquivoMidiaCaminho = media.path;
          arquivoMidiaTipo = 'audio';
        });
      } else {
        _exibirDialogoUrlMidia('áudio');
      }
    } catch (e) {
      _exibirDialogoUrlMidia('áudio');
    }
  }

  void _exibirDialogoUrlMidia(String tipoStr) {
    final controller = TextEditingController(text: arquivoMidiaCaminho ?? '');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Anexar $tipoStr'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Informe o nome ou link do arquivo de $tipoStr gravado:'),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Ex: meditação_guiada.mp3 ou URL',
                  filled: true,
                  fillColor: const Color(0xFFF4F6F9),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  setState(() {
                    arquivoMidiaCaminho = controller.text.trim();
                    arquivoMidiaNome = controller.text.trim().split('/').last.split('\\').last;
                    arquivoMidiaTipo = tipoStr.contains('vídeo') ? 'video' : 'audio';
                  });
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Anexar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSecaoMidiaAudioVideo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.headphones, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Áudio ou Vídeo da Atividade',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.text),
                    ),
                    Text(
                      'Grave uma instrução de voz direta ou envie um arquivo.',
                      style: TextStyle(fontSize: 12, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Seletor de Abas (Gravar vs Upload)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: gravandoAudio ? null : () => setState(() => opcaoMidiaAudio = 'gravar'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: opcaoMidiaAudio == 'gravar' ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.mic,
                            size: 16,
                            color: opcaoMidiaAudio == 'gravar' ? Colors.white : AppColors.muted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Gravar no App',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: opcaoMidiaAudio == 'gravar' ? Colors.white : AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: gravandoAudio ? null : () => setState(() => opcaoMidiaAudio = 'upload'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: opcaoMidiaAudio == 'upload' ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.upload,
                            size: 16,
                            color: opcaoMidiaAudio == 'upload' ? Colors.white : AppColors.muted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Upload / Arquivo',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: opcaoMidiaAudio == 'upload' ? Colors.white : AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Opção 1: Gravar no App
          if (opcaoMidiaAudio == 'gravar') ...[
            if (gravandoAudio) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F0),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.danger.withOpacity(0.4)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: AppColors.danger,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Gravando áudio...',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.danger, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _formatarDuracao(duracaoGravacaoSegundos),
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.text),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton(
                          onPressed: _cancelarGravacaoAudio,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.muted,
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Cancelar'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _pararGravacaoAudio,
                          icon: const Icon(LucideIcons.square, size: 16, color: Colors.white),
                          label: const Text('Finalizar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.danger,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else if (arquivoMidiaTipo == 'audio_gravado' && arquivoMidiaNome != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.secondary),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.softGreen,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(LucideIcons.mic, color: AppColors.secondary, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                arquivoMidiaNome!,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.text),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Duração: ${_formatarDuracao(duracaoGravacaoSegundos > 0 ? duracaoGravacaoSegundos : 15)}',
                                style: const TextStyle(fontSize: 11, color: AppColors.secondary, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            reproduzindoAudio ? LucideIcons.pauseCircle : LucideIcons.playCircle,
                            color: AppColors.primary,
                            size: 28,
                          ),
                          onPressed: () {
                            setState(() {
                              reproduzindoAudio = !reproduzindoAudio;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: _iniciarGravacaoAudio,
                          icon: const Icon(LucideIcons.rotateCcw, size: 16, color: AppColors.muted),
                          label: const Text('Gravar Novamente', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else ...[
              GestureDetector(
                onTap: _iniciarGravacaoAudio,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.mic, color: AppColors.primary, size: 28),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Pressione para iniciar a gravação de voz',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.text),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Grave uma mensagem direta, meditação ou áudio de apoio.',
                        style: TextStyle(fontSize: 12, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ] else ...[
            // Opção 2: Upload de Arquivo/Vídeo
            if (arquivoMidiaNome != null && arquivoMidiaTipo != 'audio_gravado') ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.secondary),
                ),
                child: Row(
                  children: [
                    Icon(
                      arquivoMidiaTipo == 'video' ? LucideIcons.video : LucideIcons.music,
                      color: AppColors.secondary,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            arquivoMidiaNome!,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.text),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Mídia anexada e pronta para envio',
                            style: TextStyle(fontSize: 11, color: AppColors.secondary, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.trash2, color: AppColors.danger, size: 18),
                      onPressed: () {
                        setState(() {
                          arquivoMidiaNome = null;
                          arquivoMidiaCaminho = null;
                          arquivoMidiaTipo = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selecionarVideo,
                    icon: const Icon(LucideIcons.video, size: 18),
                    label: const Text('Anexar Vídeo'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _selecionarOuGravarAudio,
                    icon: const Icon(LucideIcons.fileAudio, size: 18),
                    label: const Text('Anexar Áudio'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // --- SUB-BUILDERS DE CONTEÚDO POR TIPO ---

  Widget _buildConteudoReflexao() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Perguntas guiadas de reflexão',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.text),
        ),
        const SizedBox(height: 4),
        const Text(
          'Adicione perguntas para guiar a autoanálise do paciente.',
          style: TextStyle(fontSize: 12, color: AppColors.muted),
        ),
        const SizedBox(height: 12),
        Column(
          children: List.generate(perguntasControllers.length, (index) {
            final controller = perguntasControllers[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextField(
                controller: controller,
                onChanged: (val) => perguntasGuiadas[index] = val,
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
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
            hintText: 'Escreva uma nova pergunta reflexiva...',
            filled: true,
            fillColor: const Color(0xFFF4F6F9),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: Container(
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
              child: IconButton(
                icon: const Icon(Icons.add, color: Colors.white, size: 20),
                onPressed: adicionarPergunta,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConteudoRPD() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Modelo de RPD (TCC)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.text),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: const Color(0xFFF4F6F9), borderRadius: BorderRadius.circular(12)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: templateRpd,
              isExpanded: true,
              icon: const Icon(LucideIcons.chevronDown, color: AppColors.muted),
              items: ['TCC Padrão (5 Colunas)', 'Ansiedade & Fobia', 'Reestruturação Curta (3 Colunas)']
                  .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    templateRpd = val;
                    if (val.contains('3 Colunas')) {
                      rpdColunas = ['Situação', 'Pensamento Automático', 'Resposta Alternativa'];
                    } else if (val.contains('Ansiedade')) {
                      rpdColunas = ['Gatilho / Situação', 'Sinais Físicos & Medo (0-100)', 'Pensamento Catastrófico', 'Evidências Reais', 'Pensamento Seguro / Coping'];
                    } else {
                      rpdColunas = ['Situação (Onde/Quando)', 'Emoções & Intensidade (0-100)', 'Pensamento Automático Disfuncional', 'Resposta Alternativa / Racional', 'Reavaliação Emocional (0-100)'];
                    }
                  });
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.secondary.withOpacity(0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.softGreen, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(LucideIcons.columns, color: AppColors.secondary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Estrutura da Tabela RPD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.text)),
                        Text('Colunas apresentadas ao paciente no preenchimento:', style: TextStyle(fontSize: 11, color: AppColors.muted)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...rpdColunas.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                        child: Center(
                          child: Text('${entry.key + 1}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(entry.value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text)),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConteudoExercicioPratico() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Duração estimada', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.text)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(color: const Color(0xFFF4F6F9), borderRadius: BorderRadius.circular(12)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: exercicioDuracaoMinutos,
                        isExpanded: true,
                        icon: const Icon(LucideIcons.chevronDown, color: AppColors.muted),
                        items: [2, 3, 5, 10, 15, 20]
                            .map((min) => DropdownMenuItem<int>(value: min, child: Text('$min minutos')))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => exercicioDuracaoMinutos = val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Medir Tensão Pré/Pós', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.text)),
                  const SizedBox(height: 6),
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: const Color(0xFFF4F6F9), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Escala 0-10', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text)),
                        Switch(
                          value: exercicioMedirPrePos,
                          activeColor: AppColors.secondary,
                          onChanged: (val) => setState(() => exercicioMedirPrePos = val),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        const Text(
          'Passo a passo do exercício',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.text),
        ),
        const SizedBox(height: 4),
        const Text('Sequência de instruções guiadas.', style: TextStyle(fontSize: 12, color: AppColors.muted)),
        const SizedBox(height: 12),
        Column(
          children: List.generate(exercicioPassosControllers.length, (index) {
            final controller = exercicioPassosControllers[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextField(
                controller: controller,
                onChanged: (val) => exercicioPassos[index] = val,
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 14, top: 14, bottom: 14, right: 6),
                    child: Text(
                      'Passo ${index + 1}: ',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 12),
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 18),
                    onPressed: () => removerExercicioPasso(index),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
                  filled: true,
                  fillColor: Colors.white,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                style: const TextStyle(fontSize: 13, color: AppColors.text),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: novoExercicioPassoController,
          decoration: InputDecoration(
            hintText: 'Adicionar nova instrução sequencial...',
            filled: true,
            fillColor: const Color(0xFFF4F6F9),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: Container(
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
              child: IconButton(
                icon: const Icon(Icons.add, color: Colors.white, size: 20),
                onPressed: adicionarExercicioPasso,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConteudoChecklist() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Itens do Check-list',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.text),
        ),
        const SizedBox(height: 4),
        const Text('Ações simples que o paciente irá marcar como concluídas.', style: TextStyle(fontSize: 12, color: AppColors.muted)),
        const SizedBox(height: 12),
        Column(
          children: List.generate(checklistItensControllers.length, (index) {
            final controller = checklistItensControllers[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextField(
                controller: controller,
                onChanged: (val) => checklistItens[index] = val,
                decoration: InputDecoration(
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 14, right: 8),
                    child: Icon(LucideIcons.checkSquare, color: AppColors.secondary, size: 20),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 18),
                    onPressed: () => removerChecklistItem(index),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
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
          controller: novoChecklistItemController,
          decoration: InputDecoration(
            hintText: 'Adicionar novo item de checklist...',
            filled: true,
            fillColor: const Color(0xFFF4F6F9),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: Container(
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
              child: IconButton(
                icon: const Icon(Icons.add, color: Colors.white, size: 20),
                onPressed: adicionarChecklistItem,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConteudoLeitura() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Texto Psicoeducativo',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.text),
            ),
            Row(
              children: [
                const Icon(LucideIcons.clock, size: 14, color: AppColors.muted),
                const SizedBox(width: 4),
                Text(
                  'Tempo est.: $leituraTempoEstimadoMinutos min',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: leituraTextoController,
          maxLines: 8,
          decoration: InputDecoration(
            hintText: 'Escreva ou cole o artigo/texto informativo para o paciente ler...',
            filled: true,
            fillColor: const Color(0xFFF4F6F9),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(16),
          ),
          style: const TextStyle(fontSize: 13, color: AppColors.text, height: 1.4),
        ),
        const SizedBox(height: 20),

        const Text(
          'Perguntas de Compreensão / Fixação',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.text),
        ),
        const SizedBox(height: 4),
        const Text('Questões para verificar o entendimento após a leitura.', style: TextStyle(fontSize: 12, color: AppColors.muted)),
        const SizedBox(height: 12),
        Column(
          children: List.generate(leituraPerguntasControllers.length, (index) {
            final controller = leituraPerguntasControllers[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextField(
                controller: controller,
                onChanged: (val) => leituraPerguntasFixacao[index] = val,
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
                    onPressed: () => removerLeituraPergunta(index),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
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
          controller: novaLeituraPerguntaController,
          decoration: InputDecoration(
            hintText: 'Adicionar pergunta de reflexão pós-leitura...',
            filled: true,
            fillColor: const Color(0xFFF4F6F9),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: Container(
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
              child: IconButton(
                icon: const Icon(Icons.add, color: Colors.white, size: 20),
                onPressed: adicionarLeituraPergunta,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ),
          ),
        ),
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
        
        if (tipoSelecionado != 8) ...[
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
        ],

        if (tipoSelecionado == 1) _buildConteudoReflexao(),
        if (tipoSelecionado == 2) _buildConteudoRPD(),
        if (tipoSelecionado == 3) _buildConteudoExercicioPratico(),
        if (tipoSelecionado == 4) _buildConteudoChecklist(),
        if (tipoSelecionado == 5) ...[
          _buildSecaoMidiaAudioVideo(),
          _buildConteudoReflexao(),
        ],
        if (tipoSelecionado == 6) _buildConteudoLeitura(),
        if (tipoSelecionado == 7) _buildConfiguracaoJogo(),
        if (tipoSelecionado == 8) _buildConteudoPersonalizada(),
      ],
    );
  }

  // --- MÉTODOS PARA ATIVIDADE PERSONALIZADA ---
  Widget _buildConteudoPersonalizada() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'INFORMAÇÕES DA ATIVIDADE',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.muted, letterSpacing: 1),
        ),
        const SizedBox(height: 16),
        const Text(
          'Título da atividade *',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.text),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: tituloPersonalizadaController,
          maxLength: 100,
          decoration: InputDecoration(
            hintText: 'Ex: Como foi minha semana?',
            filled: true,
            fillColor: const Color(0xFFF4F6F9),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            counterText: '',
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 20),
        const Text(
          'Orientações ao paciente',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.text),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: orientacoesPersonalizadaController,
          maxLines: 4,
          maxLength: 500,
          decoration: InputDecoration(
            hintText: 'Ex: Responda pensando nos últimos 7 dias.',
            filled: true,
            fillColor: const Color(0xFFF4F6F9),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 32),
        const Text(
          'PERGUNTAS DA ATIVIDADE',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.muted, letterSpacing: 1),
        ),
        const SizedBox(height: 16),
        if (perguntasPersonalizadas.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0), style: BorderStyle.solid),
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(LucideIcons.listPlus, size: 32, color: AppColors.muted),
                  SizedBox(height: 12),
                  Text('Nenhuma pergunta adicionada', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.text)),
                  SizedBox(height: 4),
                  Text('Adicione perguntas para criar seu formulário.', style: TextStyle(fontSize: 13, color: AppColors.muted), textAlign: TextAlign.center),
                ],
              ),
            ),
          )
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: perguntasPersonalizadas.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final item = perguntasPersonalizadas.removeAt(oldIndex);
                perguntasPersonalizadas.insert(newIndex, item);
              });
            },
            itemBuilder: (context, index) {
              final p = perguntasPersonalizadas[index];
              return Container(
                key: ValueKey(p['id']),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          p['enunciado'],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (p['obrigatoria'])
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('Obrigatória', style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        Icon(_obterIconeTipoPergunta(p['tipo']), size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(_obterLabelTipoPergunta(p['tipo']), style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(LucideIcons.edit2, size: 18, color: AppColors.muted),
                        onPressed: () => _mostrarDialogoEditarPergunta(index),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.trash2, size: 18, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            perguntasPersonalizadas.removeAt(index);
                          });
                        },
                      ),
                      const Icon(LucideIcons.gripVertical, size: 20, color: AppColors.muted),
                    ],
                  ),
                ),
              );
            },
          ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _mostrarBottomSheetTipoPergunta,
            icon: const Icon(LucideIcons.plusCircle, size: 18),
            label: const Text('Adicionar pergunta'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  IconData _obterIconeTipoPergunta(String tipo) {
    switch (tipo) {
      case 'resposta_curta': return LucideIcons.type;
      case 'resposta_longa': return LucideIcons.alignLeft;
      case 'sim_nao': return LucideIcons.checkSquare;
      case 'escolha_unica': return LucideIcons.listFilter;
      case 'multipla_escolha': return LucideIcons.listChecks;
      case 'lista_suspensa': return LucideIcons.chevronDownSquare;
      case 'escala': return LucideIcons.slidersHorizontal;
      case 'data': return LucideIcons.calendarDays;
      case 'emocoes': return LucideIcons.smilePlus;
      default: return LucideIcons.helpCircle;
    }
  }

  String _obterLabelTipoPergunta(String tipo) {
    switch (tipo) {
      case 'resposta_curta': return 'Resposta curta';
      case 'resposta_longa': return 'Resposta longa (parágrafo)';
      case 'sim_nao': return 'Sim / Não';
      case 'escolha_unica': return 'Escolha única';
      case 'multipla_escolha': return 'Múltipla escolha';
      case 'lista_suspensa': return 'Lista suspensa';
      case 'escala': return 'Escala de intensidade';
      case 'data': return 'Data';
      case 'emocoes': return 'Seleção de emoções';
      default: return 'Desconhecido';
    }
  }

  void _mostrarBottomSheetTipoPergunta() {
    final tipos = [
      {'tipo': 'resposta_curta', 'desc': 'Texto em uma linha'},
      {'tipo': 'resposta_longa', 'desc': 'Texto em várias linhas'},
      {'tipo': 'sim_nao', 'desc': 'Opções Sim e Não'},
      {'tipo': 'escolha_unica', 'desc': 'Apenas uma opção pode ser selecionada'},
      {'tipo': 'multipla_escolha', 'desc': 'Mais de uma opção pode ser selecionada'},
      {'tipo': 'lista_suspensa', 'desc': 'Menu com várias opções'},
      {'tipo': 'escala', 'desc': 'Seletor de valores de 0 a 10'},
      {'tipo': 'data', 'desc': 'Seleção de data no calendário'},
      {'tipo': 'emocoes', 'desc': 'Seleção visual de emoções'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Adicionar pergunta', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(LucideIcons.x),
                    onPressed: () => Navigator.pop(ctx),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: tipos.length,
                itemBuilder: (ctx, i) {
                  final t = tipos[i];
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(_obterIconeTipoPergunta(t['tipo'] as String), color: AppColors.primary),
                    ),
                    title: Text(_obterLabelTipoPergunta(t['tipo'] as String), style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(t['desc'] as String, style: const TextStyle(fontSize: 12)),
                    onTap: () {
                      Navigator.pop(ctx);
                      _adicionarNovaPergunta(t['tipo'] as String);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _adicionarNovaPergunta(String tipo) {
    setState(() {
      perguntasPersonalizadas.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'tipo': tipo,
        'enunciado': 'Nova pergunta',
        'obrigatoria': true,
        if (['escolha_unica', 'multipla_escolha', 'lista_suspensa'].contains(tipo))
          'opcoes': ['Opção 1', 'Opção 2'],
        if (tipo == 'escala') ...{
          'escalaMin': 0,
          'escalaMax': 10,
          'escalaMinLabel': 'Nada',
          'escalaMaxLabel': 'Muito',
        },
      });
    });
    _mostrarDialogoEditarPergunta(perguntasPersonalizadas.length - 1);
  }

  void _mostrarDialogoEditarPergunta(int index) {
    final pergunta = Map<String, dynamic>.from(perguntasPersonalizadas[index]);
    final enunciadoController = TextEditingController(text: pergunta['enunciado']);
    bool obrigatoria = pergunta['obrigatoria'] ?? true;
    List<String> opcoes = List<String>.from(pergunta['opcoes'] ?? []);
    
    // Configurações para escala
    int escalaMin = pergunta['escalaMin'] ?? 0;
    int escalaMax = pergunta['escalaMax'] ?? 10;
    final escalaMinLabelController = TextEditingController(text: pergunta['escalaMinLabel'] ?? 'Nada');
    final escalaMaxLabelController = TextEditingController(text: pergunta['escalaMaxLabel'] ?? 'Muito');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              insetPadding: const EdgeInsets.all(16),
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Editar Pergunta', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(LucideIcons.x),
                            onPressed: () => Navigator.pop(ctx),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_obterIconeTipoPergunta(pergunta['tipo']), size: 16, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(_obterLabelTipoPergunta(pergunta['tipo']), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text('Enunciado', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: enunciadoController,
                        maxLines: 3,
                        minLines: 1,
                        decoration: InputDecoration(
                          hintText: 'Digite a pergunta...',
                          filled: true,
                          fillColor: const Color(0xFFF4F6F9),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Pergunta obrigatória', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: const Text('O paciente deverá preencher para enviar', style: TextStyle(fontSize: 12)),
                        value: obrigatoria,
                        activeColor: AppColors.primary,
                        onChanged: (val) => setStateDialog(() => obrigatoria = val),
                      ),
                      
                      if (['escolha_unica', 'multipla_escolha', 'lista_suspensa'].contains(pergunta['tipo'])) ...[
                        const Divider(height: 32),
                        const Text('Opções de Resposta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 12),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: opcoes.length,
                          itemBuilder: (context, i) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                children: [
                                  Icon(
                                    pergunta['tipo'] == 'multipla_escolha' ? LucideIcons.square : 
                                    pergunta['tipo'] == 'escolha_unica' ? LucideIcons.circle : 
                                    LucideIcons.minus,
                                    size: 16, color: AppColors.muted,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextFormField(
                                      initialValue: opcoes[i],
                                      onChanged: (val) => opcoes[i] = val,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        filled: true,
                                        fillColor: const Color(0xFFF4F6F9),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(LucideIcons.trash2, size: 18, color: Colors.red),
                                    onPressed: () => setStateDialog(() => opcoes.removeAt(i)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        TextButton.icon(
                          onPressed: () => setStateDialog(() => opcoes.add('Nova Opção')),
                          icon: const Icon(LucideIcons.plus, size: 18),
                          label: const Text('Adicionar Opção'),
                        ),
                      ],

                      if (pergunta['tipo'] == 'escala') ...[
                        const Divider(height: 32),
                        const Text('Configuração da Escala', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Mínimo', style: TextStyle(fontSize: 12, color: AppColors.muted)),
                                  DropdownButtonFormField<int>(
                                    value: escalaMin,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      filled: true,
                                      fillColor: const Color(0xFFF4F6F9),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                    ),
                                    items: [0, 1].map((e) => DropdownMenuItem(value: e, child: Text(e.toString()))).toList(),
                                    onChanged: (v) => setStateDialog(() => escalaMin = v!),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Máximo', style: TextStyle(fontSize: 12, color: AppColors.muted)),
                                  DropdownButtonFormField<int>(
                                    value: escalaMax,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      filled: true,
                                      fillColor: const Color(0xFFF4F6F9),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                    ),
                                    items: [3, 4, 5, 7, 10].map((e) => DropdownMenuItem(value: e, child: Text(e.toString()))).toList(),
                                    onChanged: (v) => setStateDialog(() => escalaMax = v!),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Rótulo Mínimo', style: TextStyle(fontSize: 12, color: AppColors.muted)),
                                  TextField(
                                    controller: escalaMinLabelController,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      hintText: 'Ex: Nada',
                                      filled: true,
                                      fillColor: const Color(0xFFF4F6F9),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
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
                                  const Text('Rótulo Máximo', style: TextStyle(fontSize: 12, color: AppColors.muted)),
                                  TextField(
                                    controller: escalaMaxLabelController,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      hintText: 'Ex: Muito',
                                      filled: true,
                                      fillColor: const Color(0xFFF4F6F9),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            if (enunciadoController.text.trim().isEmpty) return;
                            
                            setState(() {
                              pergunta['enunciado'] = enunciadoController.text.trim();
                              pergunta['obrigatoria'] = obrigatoria;
                              
                              if (['escolha_unica', 'multipla_escolha', 'lista_suspensa'].contains(pergunta['tipo'])) {
                                pergunta['opcoes'] = opcoes.where((e) => e.trim().isNotEmpty).toList();
                              } else if (pergunta['tipo'] == 'escala') {
                                pergunta['escalaMin'] = escalaMin;
                                pergunta['escalaMax'] = escalaMax;
                                pergunta['escalaMinLabel'] = escalaMinLabelController.text.trim();
                                pergunta['escalaMaxLabel'] = escalaMaxLabelController.text.trim();
                              }

                              perguntasPersonalizadas[index] = pergunta;
                            });
                            Navigator.pop(ctx);
                          },
                          child: const Text('Salvar Pergunta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
  // --- FIM DOS MÉTODOS PARA ATIVIDADE PERSONALIZADA ---

  List<String> _obterOpcoesTipoResposta() {
    switch (tipoSelecionado) {
      case 1:
        return ['Texto (resposta livre)', 'Áudio gravado pelo paciente'];
      case 2:
        return ['Estrutura RPD (Tabela de Colunas)'];
      case 3:
        return ['Confirmação + Avaliação Pré/Pós', 'Texto (resposta livre)'];
      case 4:
        return ['Marcação de Itens (Checklist)'];
      case 5:
        return ['Texto (resposta livre)', 'Áudio gravado pelo paciente', 'Escolha única'];
      case 6:
        return ['Confirmação + Perguntas de Fixação', 'Apenas confirmação de leitura'];
      case 7:
        return ['Jogo Interativo'];
      case 8:
        return ['Formulário Personalizado'];
      default:
        return ['Texto (resposta livre)'];
    }
  }

  // --- PASSO 3: CONFIGURAÇÕES DA ATIVIDADE ---
  Widget _buildPassoConfiguracoes() {
    final opcoesResposta = _obterOpcoesTipoResposta();
    final valorRespostaValido = opcoesResposta.contains(tipoResposta) ? tipoResposta : opcoesResposta.first;

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
                value: valorRespostaValido,
                isExpanded: true,
                icon: const Icon(LucideIcons.chevronDown, color: AppColors.muted),
                items: opcoesResposta
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

        if (tipoSelecionado == 7) ...[
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
                  onTap: () => setState(() {
                    nivelAtividade = nivel;
                    _sincronizarPacienteSelecionado();
                  }),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(color: const Color(0xFFF0F4FF), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(LucideIcons.fileText, color: AppColors.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      tipoSelecionado == 8 
                          ? (tituloPersonalizadaController.text.isEmpty ? 'Sem título' : tituloPersonalizadaController.text)
                          : tituloController.text,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text),
                    ),
                  ),
                  if (tipoSelecionado == 7)
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
                tipoSelecionado == 8 
                    ? (orientacoesPersonalizadaController.text.isEmpty ? 'Sem orientações' : orientacoesPersonalizadaController.text)
                    : descricaoController.text,
                style: const TextStyle(fontSize: 13, color: AppColors.muted, height: 1.4),
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.border),
              const SizedBox(height: 10),
              _buildRevisaoItem('Frequência:', frequencia),
              _buildRevisaoItem('Início:', '${dataInicio.day.toString().padLeft(2, '0')}/${dataInicio.month.toString().padLeft(2, '0')}/${dataInicio.year} às ${horarioSugerido.hour.toString().padLeft(2, '0')}:${horarioSugerido.minute.toString().padLeft(2, '0')}'),
              _buildRevisaoItem('Prazo de Conclusão:', prazoConclusao),
              if (tipoSelecionado == 7) ...[
                _buildRevisaoItem('Jogo:', '$jogoSelecionado ($modoJogo)'),
                _buildRevisaoItem('Tema:', temaJogo),
                _buildRevisaoItem('Dificuldade:', dificuldadeJogo),
              ] else if (tipoSelecionado == 8) ...[
                _buildRevisaoItem('Perguntas do Formulário:', '${perguntasPersonalizadas.length} perguntas'),
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
              : pacientes.where((p) => (p['nivel'] as int? ?? 1) >= nivelAtividade).isEmpty
                  ? const Text('Nenhum paciente possui o nível necessário.', style: TextStyle(color: AppColors.danger, fontSize: 13, fontWeight: FontWeight.bold))
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(color: const Color(0xFFF4F6F9), borderRadius: BorderRadius.circular(12)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: pacienteSelecionadoId,
                          isExpanded: true,
                          icon: const Icon(LucideIcons.chevronDown, color: AppColors.muted),
                          items: pacientes
                              .where((p) => (p['nivel'] as int? ?? 1) >= nivelAtividade)
                              .map((p) => DropdownMenuItem(
                                    value: p['id']?.toString(),
                                    child: Text('${p['nome']?.toString() ?? 'Paciente'} (Nível ${p['nivel']})'),
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

  final List<Map<String, dynamic>> jogosPorSubcategoria = const [
    {
      'subcategoria': 'CONTROLE INIBITÓRIO',
      'jogos': [
        'Modo Piloto',
        'Reação Zero',
      ],
    },
    {
      'subcategoria': 'MEMÓRIA OPERACIONAL',
      'jogos': [
        'Investigação',
        'Memória Tática',
        'Jogo de Memória',
      ],
    },
    {
      'subcategoria': 'ATENÇÃO',
      'jogos': [
        'Missão Foco',
      ],
    },
    {
      'subcategoria': 'REGULAÇÃO EMOCIONAL',
      'jogos': [
        'Controle de Reações',
        'Ansiedade Social',
      ],
    },
    {
      'subcategoria': 'PSICOEDUCAÇÃO',
      'jogos': [
        'Ilha das Emoções',
      ],
    },
    {
      'subcategoria': 'TCC & REESTRUTURAÇÃO COGNITIVA',
      'jogos': [
        'Ache a Distorção',
        'Detetive dos Pensamentos',
        'Tribunal dos Pensamentos',
        'Cartas dos Sabotadores',
      ],
    },
    {
      'subcategoria': 'FLEXIBILIDADE COGNITIVA & LINGUAGEM',
      'jogos': [
        'Mente Flexível',
        'Laboratório Mental',
        'Shark Mind',
      ],
    },
    {
      'subcategoria': 'HÁBITOS, SAÚDE & EXPOSIÇÃO',
      'jogos': [
        'Check-List (Saúde)',
        'Caçador de Gatilhos',
        'Missão Coragem',
        'Jornada do Herói Interior',
      ],
    },
  ];

  String _obterSubcategoriaDoJogo(String jogo) {
    for (final grupo in jogosPorSubcategoria) {
      final List<String> jogos = grupo['jogos'] as List<String>;
      if (jogos.contains(jogo)) {
        return grupo['subcategoria'] as String;
      }
    }
    return 'GERAL';
  }

  void _abrirModalSelecaoJogo() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.9,
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
                    'Selecione o Jogo por Subcategoria',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Escolha a atividade baseada na área clínica ou neuropsicológica:',
                    style: TextStyle(fontSize: 13, color: AppColors.textLight),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: jogosPorSubcategoria.length,
                      itemBuilder: (context, index) {
                        final grupo = jogosPorSubcategoria[index];
                        final subcat = grupo['subcategoria'] as String;
                        final jogos = grupo['jogos'] as List<String>;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    subcat,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...jogos.map((jogo) {
                              final selecionado = jogoSelecionado == jogo;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    jogoSelecionado = jogo;
                                    tituloController.text = jogo;
                                    descricaoController.text = _getDescricaoDetalhadaJogo(jogo);
                                  });
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: selecionado ? AppColors.primary.withOpacity(0.1) : const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: selecionado ? AppColors.primary : AppColors.border),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        selecionado ? LucideIcons.checkCircle2 : LucideIcons.gamepad2,
                                        size: 20,
                                        color: selecionado ? AppColors.primary : AppColors.muted,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          jogo,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: selecionado ? FontWeight.bold : FontWeight.normal,
                                            color: selecionado ? AppColors.primary : AppColors.text,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 8),
                          ],
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

  String _getDescricaoDetalhadaJogo(String jogo) {
    switch (jogo) {
      case 'Controle de Reações':
      case 'Respire':
      case 'Controle das Emoções - Respire':
      case 'Decisão Sob Pressão':
        return '[REGULAÇÃO EMOCIONAL] Treinamento de controle inibitório e regulação de emoções sob pressão. O paciente visualiza a situação, faz respiração guiada e escolhe a atitude consciente.';
      case 'Atenção - Missão Foco':
      case 'Missão Foco':
        return '[ATENÇÃO] Treina controle inibitório e atenção seletiva sob distração rápida. Responde ao EXECUTE e inibe no IGNORE.';
      case 'Memória Tática':
        return '[MEMÓRIA OPERACIONAL] Treino de retenção visual e atenção. O paciente observa grades progressivas de objetos e descobre qual sumiu.';
      case 'Memória Operacional - Investigação':
      case 'Investigação':
        return '[MEMÓRIA OPERACIONAL] Treino de memória de trabalho verbal. Leitura de depoimentos e retenção de detalhes com opção de repetição livre.';
      case 'Controle Inibitório - Modo Piloto':
      case 'Modo Piloto':
        return '[CONTROLE INIBITÓRIO] Treinamento de desaceleração de impulsos em 4 situações críticas usando checklists conscientes.';
      case 'Laboratório Mental':
        return '[FLEXIBILIDADE COGNITIVA] Alteração de letras encadeando palavras corretas.';
      case 'Mente Flexível':
        return '[FLEXIBILIDADE COGNITIVA] Classificação dinâmica de objetos de acordo com regras imprevisíveis (cor, tamanho, lados, quantidade).';
      case 'Shark Mind':
        return '[FLUÊNCIA VERBAL] Pitch de vendas criativo de 30 segundos.';
      case 'Reação Zero':
        return '[INIBIÇÃO MOTORA] Resposta rápida ao sinal TOQUE e contenção ao sinal CONGELAR.';
      case 'Detetive dos Pensamentos':
        return '[TCC] Identificação e reestruturação cognitiva de pensamentos automáticos em 3 situações.';
      case 'Tribunal dos Pensamentos':
        return '[TCC] Julgamento de pensamentos disfuncionais com análise de evidências a favor e contra.';
      case 'Caçador de Gatilhos':
        return '[AUTOMONITORAMENTO] Mapeamento de gatilhos emocionais e intensidade semanal.';
      case 'Missão Coragem':
        return '[EXPOSIÇÃO GRADUAL] Enfrentamento gradual de medos com avaliação pré/pós ansiedade.';
      case 'Ansiedade Social':
      case 'Regulação - Ansiedade Social':
      case 'O Monstro da Ansiedade':
        return '[SOMATIZAÇÃO & TCC] Mapeamento corporal de sintomas físicos e pensamentos automáticos da ansiedade social.';
      case 'Psicoeducação - Ilha das Emoções':
      case 'Ilha das Emoções':
        return '[PSICOEDUCAÇÃO] Jornada de aprendizado de estratégias de regulação para 4 problemas emocionais cotidianos.';
      case 'Cartas dos Sabotadores':
        return '[TCC / AUTOCONHECIMENTO] Identificação de sabotadores internos e criação de respostas saudáveis.';
      case 'Ache a Distorção':
      case 'Escape Room Terapêutico':
        return '[REESTRUTURAÇÃO COGNITIVA] Enigmas de identificação de distorções cognitivas para desbloquear salas.';
      case 'Jornada do Herói Interior':
        return '[RESSIGNIFICAÇÃO] Metáfora da Jornada do Herói para autoestima e autocompaixão.';
      default:
        return 'Realize a atividade terapêutica do jogo selecionado.';
    }
  }

  String _getMetricasJogo(String jogo) {
    switch (jogo) {
      case 'Controle de Reações':
      case 'Respire':
      case 'Controle das Emoções - Respire':
      case 'Decisão Sob Pressão':
        return '• Assertividade nas ações tomadas\n• Conclusão de ciclos respiratórios de controle';
      case 'Missão Foco':
      case 'Atenção - Missão Foco':
        return '• Precisão de foco (% acertos)\n• Tempo de reação e impulsividade';
      case 'Memória Tática':
        return '• Acurácia na identificação do objeto sumido\n• Capacidade de memorização e retenção visual';
      case 'Investigação':
      case 'Memória Operacional - Investigação':
        return '• Taxa de acertos em detalhes do depoimento\n• Retenção e compreensão de informações verbais';
      case 'Modo Piloto':
      case 'Controle Inibitório - Modo Piloto':
        return '• Taxa de sucesso na execução de checklists conscientes\n• Tempo de reflexão antes de agir';
      case 'Laboratório Mental':
        return '• Rapidez em transicionar anagramas de letras\n• Flexibilidade em associações fonéticas/ortográficas';
      case 'Mente Flexível':
        return '• Taxa de acertos na classificação sob mudança de regra\n• Velocidade de adaptação mental';
      case 'Shark Mind':
        return '• Tempo de pitch gravado\n• Criatividade e fluência verbal na persuasão';
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
      case 'Ansiedade Social':
      case 'Regulação - Ansiedade Social':
      case 'O Monstro da Ansiedade':
        return '• Mapeamento corporal de sintomas físicos\n• Eficácia percebida dos exercícios de respiração/relaxamento';
      case 'Ilha das Emoções':
      case 'Psicoeducação - Ilha das Emoções':
        return '• Frequência de emoções exploradas\n• Estratégias de autorregulação preferidas';
      case 'Cartas dos Sabotadores':
        return '• Sabotadores internos mais ativos/selecionados\n• Força das respostas saudáveis criadas';
      case 'Ache a Distorção':
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

        // Seleção do Jogo agrupado por Subcategoria
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Selecione o Jogo',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.muted),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _obterSubcategoriaDoJogo(jogoSelecionado),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _abrirModalSelecaoJogo,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6F9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.gamepad2, color: AppColors.primary, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        jogoSelecionado,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.text),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Subcategoria: ${_obterSubcategoriaDoJogo(jogoSelecionado)}',
                        style: const TextStyle(fontSize: 12, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                const Icon(LucideIcons.chevronDown, color: AppColors.muted, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        if (jogoSelecionado == 'Memória Tática' || jogoSelecionado == 'Jogo de Memória') ...[
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
