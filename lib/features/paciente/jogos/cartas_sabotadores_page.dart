import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../services/paciente_service.dart';

class CartasSabotadoresPage extends StatefulWidget {
  final String? atividadePacienteId;
  const CartasSabotadoresPage({super.key, this.atividadePacienteId});

  @override
  State<CartasSabotadoresPage> createState() => _CartasSabotadoresPageState();
}

class _CartasSabotadoresPageState extends State<CartasSabotadoresPage> {
  final service = PacienteService();
  bool salvando = false;
  late PageController _pageController;
  int _activePage = 0;

  final sabotadores = [
    {
      'nome': 'Crítico Interno',
      'descricao': 'Sempre encontra defeitos e nada é bom o suficiente. Foca no erro em vez de valorizar a evolução.',
      'emoji': '🗣️',
      'cor': const Color(0xFFE57373),
    },
    {
      'nome': 'Perfeccionista',
      'descricao': 'Exige que tudo saia sem falhas, levando à procrastinação pelo medo de errar ou não atingir a perfeição.',
      'emoji': '📐',
      'cor': const Color(0xFF5C6BC0),
    },
    {
      'nome': 'Abandonado',
      'descricao': 'Sente que ninguém vai apoiar ou ficar ao seu lado. Tende a afastar as pessoas preventivamente.',
      'emoji': '🥺',
      'cor': const Color(0xFF26A69A),
    },
    {
      'nome': 'Impulsivo',
      'descricao': 'Age sem pensar nas consequências de curto e longo prazo. Busca alívio imediato para desconfortos.',
      'emoji': '⚡',
      'cor': const Color(0xFFFFA726),
    },
    {
      'nome': 'Exigente',
      'descricao': 'Impõe regras rígidas e inflexíveis sobre como você e os outros deveriam agir o tempo todo.',
      'emoji': '👑',
      'cor': const Color(0xFFAB47BC),
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.75, initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> escolherSabotador(String nome) async {
    setState(() => salvando = true);

    try {
      final resultado = await service.registrarJogo(
        jogoId: 'sabotadores',
        dadosPlay: {
          'sabotador': nome,
        },
        atividadePacienteId: widget.atividadePacienteId,
      );

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [
              Icon(LucideIcons.sparkles, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Sabotador Identificado'),
            ],
          ),
          content: Text(
            'Você identificou a voz do seu sabotador: $nome!\n\nReconhecer é o primeiro passo para neutralizá-lo.\n\nGanhou +${resultado['pontosGanhos'] ?? 15} XP!',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, true);
              },
              child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => salvando = false);
    }
  }

  void _mostrarDetalhesSabotador(Map<String, dynamic> sabotador) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(sabotador['nome'], style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sabotador['descricao'],
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 20),
            const Text(
              'Dica de Enfrentamento:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 6),
            const Text(
              'Quando essa voz falar na sua mente, lembre-se de respirar e questionar: "Isso é um fato ou apenas um pensamento disfuncional?".',
              style: TextStyle(fontSize: 13, color: AppColors.muted, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Voltar', style: TextStyle(color: AppColors.muted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              escolherSabotador(sabotador['nome']);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Selecionar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('MindSteps', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Quem está falando agora?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 6),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Escolha a carta do sabotador que mais combina com o que você está sentindo.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.muted,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(),
            SizedBox(
              height: 380,
              child: ScrollConfiguration(
                behavior: AppScrollBehavior(),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: sabotadores.length,
                  onPageChanged: (page) {
                    setState(() {
                      _activePage = page;
                    });
                  },
                  itemBuilder: (context, index) {
                    final sab = sabotadores[index];
                    final isCurrent = index == _activePage;
                    final double scale = isCurrent ? 1.0 : 0.88;

                    return AnimatedBuilder(
                      animation: _pageController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: scale,
                          child: child,
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: sab['cor'] as Color,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: (sab['cor'] as Color).withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              sab['nome'] as String,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const Spacer(),
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  sab['emoji'] as String,
                                  style: const TextStyle(fontSize: 56),
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              sab['descricao'] as String,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.9),
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: ElevatedButton(
                onPressed: salvando ? null : () => _mostrarDetalhesSabotador(sabotadores[_activePage]),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: salvando
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white))
                    : const Text('Ver mais sobre esta carta'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}
