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

  // --- Estados do Jogo de Memória ---
  List<Map<String, dynamic>> cartas = []; // Cada item: {'id': int, 'valor': String, 'revelada': bool, 'combinada': bool}
  int? indexPrimeiraCarta;
  bool bloqueado = false;
  int movimentos = 0;
  int paresEncontrados = 0;
  int totalPares = 0;
  
  // Cronômetro
  Timer? _timerJogo;
  int segundosJogo = 0;
  bool jogoConcluido = false;
  String? dificuldadeEfetiva;

  int pacienteNivel = 1;
  bool carregandoInfoPaciente = false;

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
        if (decoded is Map && decoded.containsKey('perguntas')) {
          perguntas = List<String>.from(decoded['perguntas']);
          if (widget.tipo == 4) {
            checklistStatus = List.generate(perguntas.length, (_) => false);
          }
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    respostaController.dispose();
    _timerJogo?.cancel();
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
      // Checklist: serialize booleans or checked items
      final mapResultado = {};
      for (int i = 0; i < perguntas.length; i++) {
        mapResultado[perguntas[i]] = checklistStatus[i];
      }
      respostaFinal = jsonEncode(mapResultado);

      // Require at least something? Or maybe checklist can be saved empty.
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
                  if (widget.descricao.isNotEmpty) ...[
                    Text(
                      widget.descricao,
                      style: const TextStyle(fontSize: 15, color: AppColors.muted, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (widget.tipo == 7)
                    _buildMemoryGame()
                  else if (widget.tipo == 4)
                    _buildChecklist()
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