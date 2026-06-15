import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../services/paciente_service.dart';

class JogoMemoriaPage extends StatefulWidget {
  final String? atividadePacienteId;
  final String modo; // 'Imagens' ou 'Palavras'
  final String tema; // 'Expressões/Emoções', 'Animais', 'Natureza', 'Sentimentos/Emoções'
  final String dificuldade; // 'Fácil', 'Médio', 'Difícil', 'Evolutivo'
  final List<String>? palavrasPersonalizadas;

  const JogoMemoriaPage({
    super.key,
    this.atividadePacienteId,
    this.modo = 'Imagens',
    this.tema = 'Expressões/Emoções',
    this.dificuldade = 'Médio',
    this.palavrasPersonalizadas,
  });

  @override
  State<JogoMemoriaPage> createState() => _JogoMemoriaPageState();
}

class _JogoMemoriaPageState extends State<JogoMemoriaPage>
    with TickerProviderStateMixin {
  final service = PacienteService();

  // Estado das cartas
  List<Map<String, dynamic>> cartas = [];
  int? indexPrimeiraCarta;
  bool bloqueado = false;
  int movimentos = 0;
  int paresEncontrados = 0;
  int totalPares = 0;

  // Cronômetro
  Timer? _timer;
  int segundosJogo = 0;
  bool jogoConcluido = false;
  bool salvando = false;
  String dificuldadeEfetiva = 'Médio';

  int pacienteNivel = 1;
  bool carregandoNivel = true;

  // Animação de flip
  late AnimationController _celebracaoController;

  @override
  void initState() {
    super.initState();
    _celebracaoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _carregarNivelEIniciar();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _celebracaoController.dispose();
    super.dispose();
  }

  Future<void> _carregarNivelEIniciar() async {
    try {
      final me = await service.obterMe();
      pacienteNivel = me['nivel'] ?? 1;
    } catch (_) {}
    if (mounted) {
      setState(() {
        carregandoNivel = false;
        _iniciarJogo(pacienteNivel);
      });
    }
  }

  void _iniciarJogo(int nivel) {
    final String dificuldade = widget.dificuldade;

    int paresCount;
    if (dificuldade == 'Fácil') {
      paresCount = 3;
      dificuldadeEfetiva = 'Fácil (6 cartas)';
    } else if (dificuldade == 'Difícil') {
      paresCount = 8;
      dificuldadeEfetiva = 'Difícil (16 cartas)';
    } else if (dificuldade == 'Evolutivo') {
      if (nivel <= 1) paresCount = 3;
      else if (nivel == 2) paresCount = 4;
      else if (nivel == 3) paresCount = 6;
      else if (nivel == 4) paresCount = 8;
      else paresCount = 10;
      dificuldadeEfetiva = 'Evolutivo – Nível $nivel';
    } else {
      // Médio (padrão)
      paresCount = 6;
      dificuldadeEfetiva = 'Médio (12 cartas)';
    }

    totalPares = paresCount;

    // Pool de itens
    List<String> pool;
    if (widget.modo == 'Palavras') {
      if (widget.tema == 'Animais') {
        pool = ['Cão', 'Gato', 'Leão', 'Tigre', 'Urso', 'Sapo', 'Macaco', 'Peixe', 'Polvo', 'Abelha'];
      } else if (widget.tema == 'Personalizado' &&
          widget.palavrasPersonalizadas != null &&
          widget.palavrasPersonalizadas!.isNotEmpty) {
        pool = List<String>.from(widget.palavrasPersonalizadas!);
      } else {
        // Sentimentos/Emoções
        pool = ['Alegria', 'Tristeza', 'Raiva', 'Medo', 'Nojo', 'Surpresa', 'Calma', 'Ansiedade', 'Orgulho', 'Amor'];
      }
    } else {
      // Imagens (emojis)
      if (widget.tema == 'Natureza') {
        pool = ['🌸', '🌲', '☀️', '🌧️', '🍄', '🍁', '🌊', '🌋', '🍀', '🌻'];
      } else if (widget.tema == 'Animais') {
        pool = ['🐶', '🐱', '🦊', '🦁', '🐯', '🐸', '🐵', '🐔', '🐙', '🐝'];
      } else {
        // Expressões/Emoções
        pool = ['😊', '😢', '😡', '😱', '🤢', '😲', '😎', '😴', '🥳', '😕'];
      }
    }

    while (pool.length < paresCount) {
      pool.add('?${pool.length}');
    }

    final selecionados = pool.take(paresCount).toList();
    final duplicados = [...selecionados, ...selecionados]..shuffle(Random());

    cartas = List.generate(duplicados.length, (i) => {
      'id': i,
      'valor': duplicados[i],
      'revelada': false,
      'combinada': false,
    });

    movimentos = 0;
    paresEncontrados = 0;
    jogoConcluido = false;
    segundosJogo = 0;
    indexPrimeiraCarta = null;
    bloqueado = false;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => segundosJogo++);
    });
  }

  void _reiniciarJogo() {
    setState(() {
      carregandoNivel = false;
      _iniciarJogo(pacienteNivel);
    });
  }

  void _selecionarCarta(int index) {
    if (bloqueado || cartas[index]['revelada'] || cartas[index]['combinada']) return;

    setState(() => cartas[index]['revelada'] = true);

    if (indexPrimeiraCarta == null) {
      indexPrimeiraCarta = index;
    } else {
      movimentos++;
      final idx2 = index;
      final v1 = cartas[indexPrimeiraCarta!]['valor'];
      final v2 = cartas[idx2]['valor'];

      if (v1 == v2) {
        setState(() {
          cartas[indexPrimeiraCarta!]['combinada'] = true;
          cartas[idx2]['combinada'] = true;
          paresEncontrados++;
          indexPrimeiraCarta = null;
        });
        if (paresEncontrados == totalPares) {
          _timer?.cancel();
          setState(() => jogoConcluido = true);
          _celebracaoController.forward(from: 0);
        }
      } else {
        bloqueado = true;
        Timer(const Duration(milliseconds: 900), () {
          if (!mounted) return;
          setState(() {
            cartas[indexPrimeiraCarta!]['revelada'] = false;
            cartas[idx2]['revelada'] = false;
            indexPrimeiraCarta = null;
            bloqueado = false;
          });
        });
      }
    }
  }

  Future<void> _concluir() async {
    if (widget.atividadePacienteId == null || widget.atividadePacienteId!.isEmpty) {
      Navigator.pop(context, true);
      return;
    }
    setState(() => salvando = true);
    final m = (segundosJogo ~/ 60).toString().padLeft(2, '0');
    final s = (segundosJogo % 60).toString().padLeft(2, '0');
    try {
      await service.registrarJogo(
        jogoId: 'jogo_memoria',
        dadosPlay: {
          'movimentos': movimentos,
          'tempo': '$m:$s',
          'tempoSegundos': segundosJogo,
          'dificuldade': dificuldadeEfetiva,
          'pares': totalPares,
        },
        atividadePacienteId: widget.atividadePacienteId,
      );
    } catch (_) {}
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  String get _tempoFormatado {
    final m = (segundosJogo ~/ 60).toString().padLeft(2, '0');
    final s = (segundosJogo % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'JOGO DE MEMÓRIA',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.text,
            letterSpacing: 1.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!jogoConcluido)
            IconButton(
              icon: const Icon(LucideIcons.refreshCw, color: AppColors.muted, size: 20),
              onPressed: _reiniciarJogo,
              tooltip: 'Reiniciar',
            ),
        ],
      ),
      body: carregandoNivel
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  // ── HUD ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _HudItem(
                            icon: LucideIcons.timer,
                            label: _tempoFormatado,
                            color: AppColors.primary,
                          ),
                          _HudItem(
                            icon: LucideIcons.dices,
                            label: '$movimentos jogadas',
                            color: AppColors.secondary,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.softGreen,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$paresEncontrados/$totalPares pares',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Grade de cartas ──
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Column(
                        children: [
                          _buildGrid(),
                          if (jogoConcluido) ...[
                            const SizedBox(height: 24),
                            _buildResultado(),
                          ],
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: jogoConcluido
          ? Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _reiniciarJogo,
                      icon: const Icon(LucideIcons.refreshCw, size: 18),
                      label: const Text('Jogar Novamente'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        side: const BorderSide(color: AppColors.primary),
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: salvando ? null : _concluir,
                      icon: salvando
                          ? const SizedBox(
                              width: 18, height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(LucideIcons.check, size: 18),
                      label: const Text('Concluir'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildGrid() {
    final int crossAxisCount = cartas.length <= 8 ? 2 : (cartas.length <= 12 ? 3 : 4);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.95,
      ),
      itemCount: cartas.length,
      itemBuilder: (context, index) {
        final carta = cartas[index];
        final revelada = carta['revelada'] as bool;
        final combinada = carta['combinada'] as bool;
        final valor = carta['valor'] as String;
        final isEmoji = valor.runes.first > 255;

        return GestureDetector(
          onTap: () => _selecionarCarta(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: combinada
                  ? AppColors.softGreen
                  : revelada
                      ? Colors.white
                      : AppColors.primary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: combinada
                    ? AppColors.secondary
                    : revelada
                        ? AppColors.primary.withOpacity(0.4)
                        : Colors.transparent,
                width: combinada ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: combinada
                      ? AppColors.secondary.withOpacity(0.15)
                      : Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: (revelada || combinada)
                    ? Text(
                        valor,
                        key: ValueKey('v_$index'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isEmoji ? 36 : 14,
                          fontWeight: FontWeight.bold,
                          color: combinada ? AppColors.secondary : AppColors.text,
                        ),
                      )
                    : const Icon(
                        LucideIcons.circleQuestionMark,
                        key: ValueKey('q'),
                        color: Colors.white70,
                        size: 30,
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultado() {
    return ScaleTransition(
      scale: CurvedAnimation(parent: _celebracaoController, curve: Curves.elasticOut),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.softGreen,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.secondary, width: 2),
        ),
        child: Column(
          children: [
            const Icon(LucideIcons.sparkles, color: AppColors.secondary, size: 32),
            const SizedBox(height: 12),
            const Text(
              'Parabéns! 🎉',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Você completou o jogo em $_tempoFormatado\ncom $movimentos jogadas!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.text,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                dificuldadeEfetiva,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HudItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _HudItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: color,
          ),
        ),
      ],
    );
  }
}
