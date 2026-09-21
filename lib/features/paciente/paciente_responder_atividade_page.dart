import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import 'services/paciente_service.dart';

class PacienteResponderAtividadePage extends StatefulWidget {
  final String atividadePacienteId;
  final String titulo;
  final String descricao;
  final int tipo;
  final String conteudoJson;

  const PacienteResponderAtividadePage({
    super.key,
    required this.atividadePacienteId,
    required this.titulo,
    required this.descricao,
    required this.tipo,
    required this.conteudoJson,
  });

  @override
  State<PacienteResponderAtividadePage> createState() =>
      _PacienteResponderAtividadePageState();
}

class _PacienteResponderAtividadePageState
    extends State<PacienteResponderAtividadePage> {
  final respostaController = TextEditingController();
  final service = PacienteService();

  bool salvando = false;
  int notaHumor = 5;

  List<String> perguntas = [];
  List<bool> checklistStatus = [];

  // --- Estados para Leitura (Tipo 6) ---
  String? leituraTextoCorpo;
  int leituraTempoMinutos = 3;
  List<String> leituraPerguntas = [];
  Map<int, TextEditingController> leituraPerguntasControllers = {};

  // --- Estados para Exercício Prático (Tipo 3) ---
  List<String> exercicioPassos = [];
  List<bool> exercicioPassosConcluidos = [];
  int exercicioDuracaoMinutos = 5;
  bool exercicioMedirPrePos = true;
  int nivelTensaoPre = 5;
  int nivelTensaoPos = 3;

  // --- Estados para RPD (Tipo 2) ---
  List<String> rpdColunas = [];
  Map<String, TextEditingController> rpdControllers = {};
  int rpdIntensidadeEmo = 70;
  int rpdIntensidadeReval = 30;

  // --- Estados do Jogo de Memória (Tipo 7) ---
  List<Map<String, dynamic>> cartas = [];
  int? indexPrimeiraCarta;
  bool bloqueado = false;
  int movimentos = 0;
  int paresEncontrados = 0;
  int totalPares = 0;
  Timer? _timerJogo;
  int segundosJogo = 0;
  bool jogoConcluido = false;
  String? dificuldadeEfetiva;
  int pacienteNivel = 1;
  bool carregandoInfoPaciente = false;

  // Tipo 8: Atividade Personalizada
  List<Map<String, dynamic>> formPerguntas = [];
  Map<String, dynamic> formRespostas = {};
  Map<String, TextEditingController> formControllers = {};

  @override
  void initState() {
    super.initState();
    _parseConteudo();
    if (widget.tipo == 7) {
      _carregarNivelPaciente();
    }
  }

  Future<void> _carregarNivelPaciente() async {
    setState(() => carregandoInfoPaciente = true);
    try {
      final me = await service.obterMe();
      pacienteNivel = me['nivel'] ?? 1;
    } catch (_) {
      // Fallback para nível 1
    } finally {
      if (mounted) {
        setState(() {
          carregandoInfoPaciente = false;
          _iniciarJogoDeMemoria(pacienteNivel);
        });
      }
    }
  }

  void _iniciarJogoDeMemoria(int nivelDoPaciente) {
    // 1. Obter config do JSON
    String modo = 'Imagens';
    String tema = 'Expressões/Emoções';
    String dificuldade = 'Evolutivo';
    List<dynamic>? palavrasPersonalizadas;

    try {
      if (widget.conteudoJson.isNotEmpty) {
        final decoded = jsonDecode(widget.conteudoJson);
        modo = decoded['modo'] ?? 'Imagens';
        tema = decoded['tema'] ?? 'Expressões/Emoções';
        dificuldade = decoded['dificuldade'] ?? 'Evolutivo';
        if (decoded['palavrasPersonalizadas'] is List) {
          palavrasPersonalizadas = decoded['palavrasPersonalizadas'];
        }
      }
    } catch (_) {}

    // 2. Determinar dificuldade e número de pares
    int paresCount = 4; // Padrão médio
    if (dificuldade == 'Fácil') {
      paresCount = 3; // 6 cartas
      dificuldadeEfetiva = 'Fácil';
    } else if (dificuldade == 'Médio') {
      paresCount = 6; // 12 cartas
      dificuldadeEfetiva = 'Médio';
    } else if (dificuldade == 'Difícil') {
      paresCount = 8; // 16 cartas
      dificuldadeEfetiva = 'Difícil';
    } else {
      // Evolutivo: depende do nível do paciente
      dificuldadeEfetiva = 'Evolutivo (Nível $nivelDoPaciente)';
      if (nivelDoPaciente <= 1) {
        paresCount = 3;
      } else if (nivelDoPaciente == 2) {
        paresCount = 4;
      } else if (nivelDoPaciente == 3) {
        paresCount = 6;
      } else if (nivelDoPaciente == 4) {
        paresCount = 8;
      } else {
        paresCount = 10;
      }
    }

    totalPares = paresCount;

    // 3. Escolher o pool de itens
    List<String> pool = [];
    if (modo == 'Imagens') {
      if (tema == 'Natureza') {
        pool = ['🌸', '🌲', '☀️', '🌧️', '🍄', '🍁', '🌊', '🌋', '🍀', '🌻'];
      } else if (tema == 'Animais') {
        pool = ['🐶', '🐱', '🦊', '🦁', '🐯', '🐸', '🐵', '🐔', '🐙', '🐝'];
      } else {
        // Expressões/Emoções
        pool = ['😊', '😢', '😡', '😱', '🤢', '😲', '😎', '😴', '🥳', '😕'];
      }
    } else {
      // Palavras
      if (tema == 'Animais') {
        pool = ['Cão', 'Gato', 'Leão', 'Tigre', 'Urso', 'Sapo', 'Macaco', 'Peixe', 'Polvo', 'Abelha'];
      } else if (tema == 'Personalizado' && palavrasPersonalizadas != null && palavrasPersonalizadas.isNotEmpty) {
        pool = List<String>.from(palavrasPersonalizadas);
      } else {
        // Sentimentos/Emoções
        pool = ['Alegria', 'Tristeza', 'Raiva', 'Medo', 'Nojo', 'Surpresa', 'Calma', 'Ansiedade', 'Orgulho', 'Amor'];
      }
    }

    // Garantir que temos elementos suficientes no pool
    while (pool.length < paresCount) {
      pool.add('Item ${pool.length + 1}');
    }

    // Selecionar os primeiros N elementos e duplicá-los
    List<String> selecionados = pool.take(paresCount).toList();
    List<String> itensDuplicados = [...selecionados, ...selecionados];

    // Embaralhar
    itensDuplicados.shuffle();

    // Criar as cartas
    cartas = List.generate(itensDuplicados.length, (index) {
      return {
        'id': index,
        'valor': itensDuplicados[index],
        'revelada': false,
        'combinada': false,
      };
    });

    // Reset de variáveis de jogo
    movimentos = 0;
    paresEncontrados = 0;
    jogoConcluido = false;
    segundosJogo = 0;
    indexPrimeiraCarta = null;
    bloqueado = false;

    // Iniciar cronômetro
    _timerJogo?.cancel();
    _timerJogo = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        segundosJogo++;
      });
    });
  }

  void _parseConteudo() {
    try {
      if (widget.conteudoJson.isNotEmpty) {
        final decoded = jsonDecode(widget.conteudoJson);
        if (decoded is Map) {
          // Perguntas genéricas
          if (decoded.containsKey('perguntas') && decoded['perguntas'] is List) {
            perguntas = List<String>.from(decoded['perguntas']);
          }

          // Checklist (Tipo 4)
          if (widget.tipo == 4) {
            if (decoded.containsKey('itens') && decoded['itens'] is List) {
              perguntas = List<String>.from(decoded['itens']);
            }
            checklistStatus = List.generate(perguntas.length, (_) => false);
          }

          // Leitura (Tipo 6)
          if (widget.tipo == 6) {
            leituraTextoCorpo = decoded['textoCorpo']?.toString();
            leituraTempoMinutos = decoded['tempoEstimadoMinutos'] as int? ?? 3;
            if (decoded.containsKey('perguntasFixacao') && decoded['perguntasFixacao'] is List) {
              leituraPerguntas = List<String>.from(decoded['perguntasFixacao']);
            } else if (perguntas.isNotEmpty) {
              leituraPerguntas = List<String>.from(perguntas);
            }
            for (int i = 0; i < leituraPerguntas.length; i++) {
              leituraPerguntasControllers[i] = TextEditingController();
            }
          }

          // Exercício Prático (Tipo 3)
          if (widget.tipo == 3) {
            if (decoded.containsKey('passos') && decoded['passos'] is List) {
              exercicioPassos = List<String>.from(decoded['passos']);
            } else if (perguntas.isNotEmpty) {
              exercicioPassos = List<String>.from(perguntas);
            } else {
              exercicioPassos = [
                'Sente-se confortavelmente e relaxe os ombros.',
                'Inspire suavemente pelo nariz contando até 4.',
                'Segure o ar nos pulmões por 2 segundos.',
                'Expire devagar pela boca contando até 6.',
              ];
            }
            exercicioPassosConcluidos = List.generate(exercicioPassos.length, (_) => false);
            exercicioDuracaoMinutos = decoded['duracaoMinutos'] as int? ?? 5;
            exercicioMedirPrePos = decoded['medirPrePos'] as bool? ?? true;
          }

          // RPD (Tipo 2)
          if (widget.tipo == 2) {
            if (decoded.containsKey('colunas') && decoded['colunas'] is List) {
              rpdColunas = List<String>.from(decoded['colunas']);
            } else {
              rpdColunas = [
                'Situação (Onde/Quando)',
                'Emoções & Intensidade (0-100)',
                'Pensamento Automático Disfuncional',
                'Resposta Alternativa / Racional',
                'Reavaliação Emocional (0-100)',
              ];
            }
            for (var col in rpdColunas) {
              rpdControllers[col] = TextEditingController();
            }
          }

          // Atividade Personalizada (Tipo 8)
          if (widget.tipo == 8) {
            if (decoded.containsKey('perguntas') && decoded['perguntas'] is List) {
              formPerguntas = List<Map<String, dynamic>>.from(decoded['perguntas']);
              for (var p in formPerguntas) {
                final id = p['id'] as String;
                if (p['tipo'] == 'resposta_curta' || p['tipo'] == 'resposta_longa' || p['tipo'] == 'data') {
                  formControllers[id] = TextEditingController();
                } else if (p['tipo'] == 'multipla_escolha') {
                  formRespostas[id] = <String>[];
                }
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Erro ao parsear conteúdo JSON: $e');
    }
  }

  @override
  void dispose() {
    respostaController.dispose();
    _timerJogo?.cancel();
    for (var c in leituraPerguntasControllers.values) {
      c.dispose();
    }
    for (var c in rpdControllers.values) {
      c.dispose();
    }
    for (var c in formControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> salvar() async {
    String respostaFinal = '';

    if (widget.tipo == 7) {
      if (!jogoConcluido) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, encontre todos os pares antes de salvar.')),
        );
        return;
      }
      final minutos = (segundosJogo ~/ 60).toString().padLeft(2, '0');
      final segundos = (segundosJogo % 60).toString().padLeft(2, '0');
      respostaFinal = jsonEncode({
        'jogo': 'Jogo de Memória',
        'movimentos': movimentos,
        'tempoSegundos': segundosJogo,
        'tempo': '$minutos:$segundos',
        'dificuldade': dificuldadeEfetiva,
      });
    } else if (widget.tipo == 4) {
      // Checklist
      final mapResultado = {};
      for (int i = 0; i < perguntas.length; i++) {
        mapResultado[perguntas[i]] = checklistStatus[i];
      }
      respostaFinal = jsonEncode(mapResultado);
    } else if (widget.tipo == 2) {
      // RPD
      final mapRpd = <String, dynamic>{};
      for (var col in rpdColunas) {
        mapRpd[col] = rpdControllers[col]?.text.trim() ?? '';
      }
      mapRpd['intensidadeEmocionalInicial'] = rpdIntensidadeEmo;
      mapRpd['intensidadeEmocionalFinal'] = rpdIntensidadeReval;
      respostaFinal = jsonEncode(mapRpd);
    } else if (widget.tipo == 3) {
      // Exercício Prático
      final mapExercicio = <String, dynamic>{
        'duracaoMinutos': exercicioDuracaoMinutos,
        'passosConcluidos': exercicioPassosConcluidos,
        'tensaoAntes': nivelTensaoPre,
        'tensaoDepois': nivelTensaoPos,
        'comentario': respostaController.text.trim(),
      };
      respostaFinal = jsonEncode(mapExercicio);
    } else if (widget.tipo == 6) {
      // Leitura Psicoeducativa
      final mapLeitura = <String, dynamic>{
        'leituraConcluida': true,
        'respostasFixacao': leituraPerguntas.asMap().map((i, p) => MapEntry(p, leituraPerguntasControllers[i]?.text.trim() ?? '')),
        'comentario': respostaController.text.trim(),
      };
      respostaFinal = jsonEncode(mapLeitura);
    } else if (widget.tipo == 8) {
      // Validar obrigatórias
      for (var p in formPerguntas) {
        if (p['obrigatoria'] == true) {
          final id = p['id'] as String;
          final tipo = p['tipo'] as String;
          bool hasValue = false;
          
          if (['resposta_curta', 'resposta_longa', 'data'].contains(tipo)) {
            hasValue = formControllers[id]?.text.trim().isNotEmpty ?? false;
          } else if (tipo == 'multipla_escolha') {
            final list = formRespostas[id] as List<String>?;
            hasValue = list != null && list.isNotEmpty;
          } else {
            hasValue = formRespostas.containsKey(id) && formRespostas[id] != null;
          }
          
          if (!hasValue) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Preencha todas as perguntas obrigatórias.')),
            );
            return;
          }
        }
      }
      
      // Coletar respostas
      final mapRespostas = formPerguntas.map((p) {
        final id = p['id'] as String;
        final tipo = p['tipo'] as String;
        dynamic valor;
        
        if (['resposta_curta', 'resposta_longa', 'data'].contains(tipo)) {
          valor = formControllers[id]?.text.trim();
        } else {
          valor = formRespostas[id];
        }
        
        return {
          'perguntaId': id,
          'enunciado': p['enunciado'],
          'tipo': tipo,
          'resposta': valor,
        };
      }).toList();
      
      respostaFinal = jsonEncode({
        'tipoAtividade': 'personalizada',
        'respostas': mapRespostas,
      });
    } else {
      respostaFinal = respostaController.text.trim();
      if (respostaFinal.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Escreva sua resposta antes de enviar.')),
        );
        return;
      }
    }

    try {
      setState(() => salvando = true);

      await service.responderAtividade(
        atividadePacienteId: widget.atividadePacienteId,
        respostaTexto: respostaFinal,
        notaHumor: notaHumor,
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
      if (mounted) {
        setState(() => salvando = false);
      }
    }
  }

  Widget _buildChecklist() {
    if (perguntas.isEmpty) {
      return const Text('Esta atividade não possui itens.', style: TextStyle(color: AppColors.muted));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Marque os itens realizados',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(perguntas.length, (index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: checklistStatus[index] ? AppColors.secondary : AppColors.border),
            ),
            child: CheckboxListTile(
              title: Text(
                perguntas[index],
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  decoration: checklistStatus[index] ? TextDecoration.lineThrough : null,
                  color: checklistStatus[index] ? AppColors.muted : AppColors.text,
                ),
              ),
              value: checklistStatus[index],
              activeColor: AppColors.secondary,
              checkColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    checklistStatus[index] = val;
                  });
                }
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRespostaLivre() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descreva a situação',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Conte sobre o que aconteceu.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: respostaController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Ex: Tive uma reunião importante e fiquei muito ansioso...',
            hintStyle: const TextStyle(color: AppColors.muted),
            alignLabelWithHint: true,
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
      ],
    );
  }

  void _selecionarCarta(int index) {
    if (bloqueado || cartas[index]['revelada'] || cartas[index]['combinada']) {
      return;
    }

    setState(() {
      cartas[index]['revelada'] = true;
    });

    if (indexPrimeiraCarta == null) {
      indexPrimeiraCarta = index;
    } else {
      movimentos++;
      final indexSegundaCarta = index;
      final val1 = cartas[indexPrimeiraCarta!]['valor'];
      final val2 = cartas[indexSegundaCarta]['valor'];

      if (val1 == val2) {
        // Combinado!
        setState(() {
          cartas[indexPrimeiraCarta!]['combinada'] = true;
          cartas[indexSegundaCarta]['combinada'] = true;
          paresEncontrados++;
          indexPrimeiraCarta = null;
        });

        if (paresEncontrados == totalPares) {
          _timerJogo?.cancel();
          setState(() {
            jogoConcluido = true;
          });
        }
      } else {
        // Não combina
        bloqueado = true;
        Timer(const Duration(milliseconds: 1000), () {
          if (!mounted) return;
          setState(() {
            cartas[indexPrimeiraCarta!]['revelada'] = false;
            cartas[indexSegundaCarta]['revelada'] = false;
            indexPrimeiraCarta = null;
            bloqueado = false;
          });
        });
      }
    }
  }

  Widget _buildMemoryGame() {
    if (carregandoInfoPaciente) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (cartas.isEmpty) {
      return const Center(child: Text('Erro ao carregar o jogo.', style: TextStyle(color: AppColors.danger)));
    }

    final minutos = (segundosJogo ~/ 60).toString().padLeft(2, '0');
    final segundos = (segundosJogo % 60).toString().padLeft(2, '0');

    // Determinar o grid de acordo com o número de cartas
    // 6 cartas: 2x3 ou 3x2. 8 cartas: 2x4. 12 cartas: 3x4. 16 cartas: 4x4. 20 cartas: 4x5.
    int crossAxisCount = 3;
    if (cartas.length <= 8) {
      crossAxisCount = 2;
    } else if (cartas.length <= 12) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 4;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Painel de Status (Cronômetro e Movimentos)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.timer, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '$minutos:$segundos',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.text),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(LucideIcons.dices, color: AppColors.secondary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Jogadas: $movimentos',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.text),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.softGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  dificuldadeEfetiva ?? 'Normal',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Grid de Cartas
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.0,
          ),
          itemCount: cartas.length,
          itemBuilder: (context, index) {
            final carta = cartas[index];
            final revelada = carta['revelada'] as bool;
            final combinada = carta['combinada'] as bool;
            final valor = carta['valor'] as String;

            final isEmoji = valor.runes.length == 1 || (valor.length == 2 && valor.runes.first > 255);

            return GestureDetector(
              onTap: () => _selecionarCarta(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: combinada 
                      ? AppColors.softGreen 
                      : (revelada ? Colors.white : AppColors.primary),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: combinada 
                        ? AppColors.secondary 
                        : (revelada ? AppColors.primary : Colors.transparent),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: (revelada || combinada)
                        ? Text(
                            valor,
                            key: ValueKey('value_$index'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isEmoji ? 36 : 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          )
                        : Icon(
                            LucideIcons.circleQuestionMark,
                            key: ValueKey('question_$index'),
                            color: Colors.white,
                            size: 28,
                          ),
                  ),
                ),
              ),
            );
          },
        ),

        if (jogoConcluido) ...[
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.softGreen,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.secondary),
            ),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.sparkles, color: AppColors.secondary, size: 24),
                    SizedBox(width: 10),
                    Text(
                      'Excelente Trabalho!',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Você concluiu o jogo de memória em $minutos:$segundos com apenas $movimentos jogadas!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: AppColors.text, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFormularioRPD() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Registro de Pensamentos (RPD)',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.text),
        ),
        const SizedBox(height: 4),
        const Text(
          'Preencha cada etapa para identificar e reestruturar seus pensamentos.',
          style: TextStyle(fontSize: 14, color: AppColors.muted),
        ),
        const SizedBox(height: 20),
        ...rpdColunas.map((coluna) {
          final isEmo = coluna.toLowerCase().contains('emoçã') || coluna.toLowerCase().contains('intensidade');
          final isReval = coluna.toLowerCase().contains('reavaliaçã');
          final controller = rpdControllers[coluna] ?? TextEditingController();

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coluna,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
                ),
                const SizedBox(height: 10),
                if (isEmo) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Intensidade Inicial:', style: TextStyle(fontSize: 12, color: AppColors.muted)),
                      Text('$rpdIntensidadeEmo%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                    ],
                  ),
                  Slider(
                    value: rpdIntensidadeEmo.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 20,
                    activeColor: AppColors.secondary,
                    onChanged: (val) => setState(() => rpdIntensidadeEmo = val.round()),
                  ),
                ] else if (isReval) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Intensidade após Reavaliação:', style: TextStyle(fontSize: 12, color: AppColors.muted)),
                      Text('$rpdIntensidadeReval%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                    ],
                  ),
                  Slider(
                    value: rpdIntensidadeReval.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 20,
                    activeColor: AppColors.secondary,
                    onChanged: (val) => setState(() => rpdIntensidadeReval = val.round()),
                  ),
                ],
                TextField(
                  controller: controller,
                  maxLines: isEmo || isReval ? 2 : 3,
                  decoration: InputDecoration(
                    hintText: 'Digite aqui...',
                    hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
                    fillColor: const Color(0xFFF4F6F9),
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildExercicioPratico() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Instruções do Exercício',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.text),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppColors.softGreen, borderRadius: BorderRadius.circular(8)),
              child: Text(
                '⏱️ $exercicioDuracaoMinutos min',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (exercicioMedirPrePos) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Como você se sente ANTES de iniciar? (0 a 10)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.text)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('0 (Calmo)', style: TextStyle(fontSize: 11, color: AppColors.muted)),
                    Text('$nivelTensaoPre / 10', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary)),
                    const Text('10 (Muito Ansioso)', style: TextStyle(fontSize: 11, color: AppColors.muted)),
                  ],
                ),
                Slider(
                  value: nivelTensaoPre.toDouble(),
                  min: 0,
                  max: 10,
                  divisions: 10,
                  activeColor: AppColors.primary,
                  onChanged: (val) => setState(() => nivelTensaoPre = val.round()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        ...List.generate(exercicioPassos.length, (index) {
          final concluido = index < exercicioPassosConcluidos.length ? exercicioPassosConcluidos[index] : false;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: concluido ? AppColors.secondary : AppColors.border),
            ),
            child: CheckboxListTile(
              title: Text(
                '${index + 1}. ${exercicioPassos[index]}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: concluido ? AppColors.muted : AppColors.text,
                  decoration: concluido ? TextDecoration.lineThrough : null,
                ),
              ),
              value: concluido,
              activeColor: AppColors.secondary,
              checkColor: Colors.white,
              onChanged: (val) {
                if (val != null) {
                  setState(() => exercicioPassosConcluidos[index] = val);
                }
              },
            ),
          );
        }),

        if (exercicioMedirPrePos) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.secondary.withOpacity(0.4))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Como você se sente DEPOIS de concluir? (0 a 10)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.text)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('0 (Relaxado)', style: TextStyle(fontSize: 11, color: AppColors.muted)),
                    Text('$nivelTensaoPos / 10', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.secondary)),
                    const Text('10 (Ansioso)', style: TextStyle(fontSize: 11, color: AppColors.muted)),
                  ],
                ),
                Slider(
                  value: nivelTensaoPos.toDouble(),
                  min: 0,
                  max: 10,
                  divisions: 10,
                  activeColor: AppColors.secondary,
                  onChanged: (val) => setState(() => nivelTensaoPos = val.round()),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLeituraPsicoeducativa() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: const Color(0xFFFFF0F0), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(LucideIcons.bookOpen, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Text('Leitura Informativa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.text)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.softGreen, borderRadius: BorderRadius.circular(8)),
                    child: Text('Leitura de $leituraTempoMinutos min', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                leituraTextoCorpo ?? widget.descricao,
                style: const TextStyle(fontSize: 14, color: AppColors.text, height: 1.6),
              ),
            ],
          ),
        ),
        if (leituraPerguntas.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Text(
            'Perguntas de Fixação',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text),
          ),
          const SizedBox(height: 4),
          const Text('Responda às questões com base no texto lido:', style: TextStyle(fontSize: 13, color: AppColors.muted)),
          const SizedBox(height: 14),
          ...List.generate(leituraPerguntas.length, (index) {
            final controller = leituraPerguntasControllers[index] ?? TextEditingController();
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${index + 1}. ${leituraPerguntas[index]}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.text)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: controller,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Sua resposta...',
                      filled: true,
                      fillColor: const Color(0xFFF4F6F9),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  // --- ATIVIDADE PERSONALIZADA (TIPO 8) ---
  Widget _buildAtividadePersonalizada() {
    if (formPerguntas.isEmpty) {
      return const Text('Esta atividade não possui perguntas configuradas.', style: TextStyle(color: AppColors.muted));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...formPerguntas.map((p) {
          final id = p['id'] as String;
          final tipo = p['tipo'] as String;
          final obrigatoria = p['obrigatoria'] == true;
          final enunciado = p['enunciado'] as String;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: enunciado,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.text, height: 1.4),
                    children: [
                      if (obrigatoria)
                        const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _buildCampoFormularioPersonalizado(id, tipo, p),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildCampoFormularioPersonalizado(String id, String tipo, Map<String, dynamic> config) {
    switch (tipo) {
      case 'resposta_curta':
        return TextField(
          controller: formControllers[id],
          decoration: InputDecoration(
            hintText: 'Sua resposta...',
            filled: true,
            fillColor: const Color(0xFFF4F6F9),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        );
      case 'resposta_longa':
        return TextField(
          controller: formControllers[id],
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Sua resposta detalhada...',
            filled: true,
            fillColor: const Color(0xFFF4F6F9),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        );
      case 'sim_nao':
        final valor = formRespostas[id] as String?;
        return Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Center(child: Text('Sim')),
                selected: valor == 'Sim',
                onSelected: (s) => setState(() => formRespostas[id] = s ? 'Sim' : null),
                selectedColor: AppColors.primary.withOpacity(0.1),
                labelStyle: TextStyle(
                  color: valor == 'Sim' ? AppColors.primary : AppColors.muted,
                  fontWeight: valor == 'Sim' ? FontWeight.bold : FontWeight.normal,
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ChoiceChip(
                label: const Center(child: Text('Não')),
                selected: valor == 'Não',
                onSelected: (s) => setState(() => formRespostas[id] = s ? 'Não' : null),
                selectedColor: AppColors.primary.withOpacity(0.1),
                labelStyle: TextStyle(
                  color: valor == 'Não' ? AppColors.primary : AppColors.muted,
                  fontWeight: valor == 'Não' ? FontWeight.bold : FontWeight.normal,
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        );
      case 'escolha_unica':
        final opcoes = List<String>.from(config['opcoes'] ?? []);
        return Column(
          children: opcoes.map((op) {
            return RadioListTile<String>(
              title: Text(op),
              value: op,
              groupValue: formRespostas[id] as String?,
              onChanged: (val) => setState(() => formRespostas[id] = val),
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.primary,
            );
          }).toList(),
        );
      case 'multipla_escolha':
        final opcoes = List<String>.from(config['opcoes'] ?? []);
        final selecionadas = formRespostas[id] as List<String>? ?? <String>[];
        return Column(
          children: opcoes.map((op) {
            final isSelected = selecionadas.contains(op);
            return CheckboxListTile(
              title: Text(op),
              value: isSelected,
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    selecionadas.add(op);
                  } else {
                    selecionadas.remove(op);
                  }
                  formRespostas[id] = selecionadas;
                });
              },
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.primary,
            );
          }).toList(),
        );
      case 'lista_suspensa':
        final opcoes = List<String>.from(config['opcoes'] ?? []);
        return DropdownButtonFormField<String>(
          value: formRespostas[id] as String?,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF4F6F9),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          hint: const Text('Selecione uma opção'),
          items: opcoes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (val) => setState(() => formRespostas[id] = val),
        );
      case 'escala':
        final min = (config['escalaMin'] as int?) ?? 0;
        final max = (config['escalaMax'] as int?) ?? 10;
        final minLabel = (config['escalaMinLabel'] as String?) ?? 'Nada';
        final maxLabel = (config['escalaMaxLabel'] as String?) ?? 'Muito';
        final valor = (formRespostas[id] as double?) ?? min.toDouble();
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(minLabel, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                Text(maxLabel, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
              ],
            ),
            Slider(
              value: valor,
              min: min.toDouble(),
              max: max.toDouble(),
              divisions: (max - min) > 0 ? (max - min) : 1,
              label: valor.round().toString(),
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => formRespostas[id] = v),
            ),
          ],
        );
      case 'data':
        final ctrl = formControllers[id]!;
        return TextField(
          controller: ctrl,
          readOnly: true,
          decoration: InputDecoration(
            hintText: 'Selecione uma data',
            filled: true,
            fillColor: const Color(0xFFF4F6F9),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            suffixIcon: const Icon(LucideIcons.calendar),
          ),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
            );
            if (date != null) {
              setState(() {
                ctrl.text = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
              });
            }
          },
        );
      case 'emocoes':
        final val = formRespostas[id] as String?;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            'Alegria', 'Tristeza', 'Raiva', 'Medo', 'Calma', 'Ansiedade'
          ].map((emo) {
            final isSelected = val == emo;
            return InkWell(
              onTap: () => setState(() => formRespostas[id] = emo),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : const Color(0xFFF4F6F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  emo,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.text,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      default:
        return const Text('Tipo de pergunta não suportado', style: TextStyle(color: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text('1 de 1', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.descricao.isNotEmpty && widget.tipo != 6) ...[
                    Text(
                      widget.descricao,
                      style: const TextStyle(fontSize: 15, color: AppColors.muted, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (widget.tipo == 7)
                    _buildMemoryGame()
                  else if (widget.tipo == 2)
                    _buildFormularioRPD()
                  else if (widget.tipo == 3)
                    _buildExercicioPratico()
                  else if (widget.tipo == 4)
                    _buildChecklist()
                  else if (widget.tipo == 6)
                    _buildLeituraPsicoeducativa()
                  else if (widget.tipo == 8)
                    _buildAtividadePersonalizada()
                  else
                    _buildRespostaLivre(),
                  const SizedBox(height: 32),
                  const Text(
                    'Como você se sentiu?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Intensidade da emoção',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SliderHumor(
                    valor: notaHumor,
                    onChanged: (valor) {
                      setState(() => notaHumor = valor);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
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
          onPressed: salvando ? null : salvar,
          child: salvando
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white))
              : const Text('Salvar e continuar'),
        ),
      ),
    );
  }
}

class _CardAtividade extends StatelessWidget {
  final String titulo;
  final String descricao;

  const _CardAtividade({
    required this.titulo,
    required this.descricao,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            LucideIcons.clipboardList,
            color: AppColors.primary,
            size: 30,
          ),
          const SizedBox(height: 14),
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            descricao,
            style: const TextStyle(
              color: AppColors.muted,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SliderHumor extends StatelessWidget {
  final int valor;
  final ValueChanged<int> onChanged;

  const _SliderHumor({
    required this.valor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons.frown,
                color: AppColors.muted,
              ),
              Expanded(
                child: Slider(
                  value: valor.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: valor.toString(),
                  onChanged: (value) => onChanged(value.round()),
                ),
              ),
              const Icon(
                LucideIcons.smile,
                color: AppColors.primary,
              ),
            ],
          ),
          Text(
            'Nota do humor: $valor/10',
            style: const TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}