import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../services/paciente_service.dart';

class DecisaoSobPressaoPage extends StatefulWidget {
  final String? atividadePacienteId;
  const DecisaoSobPressaoPage({super.key, this.atividadePacienteId});

  @override
  State<DecisaoSobPressaoPage> createState() => _DecisaoSobPressaoPageState();
}

class _DecisaoSobPressaoPageState extends State<DecisaoSobPressaoPage> {
  final service = PacienteService();
  bool salvando = false;
  int etapa = 0; // 0: Situação Crítica, 1: Respiração, 2: Ação, 3: Sucesso

  int respiracoesConcluidas = 0;
  bool respirando = false;
  int segundosRespiracao = 4;
  String instrucaoRespiracao = "Inspire";
  Timer? timerRespiracao;

  String? acaoSelecionada;

  final situacao = "Você enviou uma mensagem importante. A pessoa visualizou há 4 horas e não respondeu.";

  final acoes = [
    {"texto": "Mandar várias mensagens cobrando retorno", "tipo": "Impulsiva"},
    {"texto": "Fazer um drama ou postar indireta", "tipo": "Impulsiva"},
    {"texto": "Esperar com calma e responder normalmente depois", "tipo": "Assertiva"},
    {"texto": "Desabafar calmamente com alguém de confiança", "tipo": "Assertiva"},
  ];

  @override
  void dispose() {
    timerRespiracao?.cancel();
    super.dispose();
  }

  void iniciarRespiracao() {
    setState(() {
      etapa = 1;
      respirando = true;
      segundosRespiracao = 4;
      instrucaoRespiracao = "Inspire";
    });

    timerRespiracao = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (segundosRespiracao > 1) {
          segundosRespiracao--;
        } else {
          if (instrucaoRespiracao == "Inspire") {
            instrucaoRespiracao = "Expire";
            segundosRespiracao = 4;
          } else {
            respiracoesConcluidas++;
            if (respiracoesConcluidas >= 3) {
              timer.cancel();
              respirando = false;
              etapa = 2; // Ir para escolhas
            } else {
              instrucaoRespiracao = "Inspire";
              segundosRespiracao = 4;
            }
          }
        }
      });
    });
  }

  Future<void> finalizarJogo() async {
    if (acaoSelecionada == null) return;
    setState(() => salvando = true);
    try {
      final acaoObj = acoes.firstWhere((element) => element['texto'] == acaoSelecionada);
      await service.registrarJogo(
        jogoId: 'decisao_pressao',
        dadosPlay: {
          'situacao': situacao,
          'acao_escolhida': acaoSelecionada!,
          'tipo_acao': acaoObj['tipo']!,
          'respirou': true,
        },
        atividadePacienteId: widget.atividadePacienteId,
      );

      if (!mounted) return;
      setState(() {
        etapa = 3;
      });
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

  @override
  Widget build(BuildContext context) {
    final backgroundColor = AppColors.background;
    final cardColor = Colors.white;
    final accentColor = AppColors.secondary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: const Text(
          'DECISÃO SOB PRESSÃO',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.text,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _buildConteudo(cardColor, accentColor),
              ),
            ),
            _buildBottomButton(accentColor),
          ],
        ),
      ),
    );
  }

  Widget _buildConteudo(Color cardColor, Color accentColor) {
    switch (etapa) {
      case 0:
        return _buildSituacaoCritica(cardColor, accentColor);
      case 1:
        return _buildRespiracao(cardColor, accentColor);
      case 2:
        return _buildEscolhaAcao(cardColor, accentColor);
      case 3:
        return _buildSucesso(cardColor, accentColor);
      default:
        return Container();
    }
  }

  Widget _buildSituacaoCritica(Color cardColor, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.danger.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.danger),
          ),
          child: const Text(
            'CONTROLE INIBITÓRIO',
            style: TextStyle(color: AppColors.danger, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
        ),
        const SizedBox(height: 32),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 16,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Column(
            children: [
              const Icon(LucideIcons.octagonAlert, size: 48, color: AppColors.danger),
              const SizedBox(height: 18),
              const Text(
                'Situação de Alta Pressão:',
                style: TextStyle(color: AppColors.textLight, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                situacao,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.4, color: AppColors.text),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        const Text(
          'Suas emoções estão querendo dominar.',
          style: TextStyle(color: AppColors.muted, fontSize: 14),
        ),
        const SizedBox(height: 8),
        const Text(
          'Não reaja impulsivamente. Respire primeiro.',
          style: TextStyle(color: AppColors.text, fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildRespiracao(Color cardColor, Color accentColor) {
    final progresso = segundosRespiracao / 4.0;
    final isInspiring = instrucaoRespiracao == "Inspire";

    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          'PARE E PENSE',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.text, letterSpacing: 2),
        ),
        const SizedBox(height: 8),
        const Text(
          'Respire. Não aja no impulso.',
          style: TextStyle(color: AppColors.textLight, fontSize: 14),
        ),
        const SizedBox(height: 60),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BreathingLungsAnimation(
                isInspiring: isInspiring,
                isActive: respirando,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isInspiring ? LucideIcons.arrowUp : LucideIcons.arrowDown,
                    color: accentColor,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    instrucaoRespiracao,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: accentColor),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${segundosRespiracao}s',
                style: const TextStyle(fontSize: 28, color: AppColors.text, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 60),
        Text(
          'Ciclo respiratório: $respiracoesConcluidas / 3',
          style: const TextStyle(color: AppColors.text, fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildEscolhaAcao(Color cardColor, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ESCOLHA SUA AÇÃO',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.text, letterSpacing: 1.5),
        ),
        const SizedBox(height: 6),
        const Text(
          'Qual é a melhor atitude agora?',
          style: TextStyle(color: AppColors.textLight, fontSize: 14),
        ),
        const SizedBox(height: 24),
        ...acoes.map((item) {
          final selecionada = acaoSelecionada == item['texto'];
          return GestureDetector(
            onTap: () {
              setState(() {
                acaoSelecionada = item['texto'];
              });
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: selecionada ? accentColor.withOpacity(0.12) : cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selecionada ? accentColor : AppColors.border,
                  width: selecionada ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.015),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item['texto']!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: selecionada ? FontWeight.bold : FontWeight.normal,
                        color: selecionada ? accentColor : AppColors.text,
                      ),
                    ),
                  ),
                  if (selecionada)
                    Icon(LucideIcons.circleCheck, color: accentColor, size: 20),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSucesso(Color cardColor, Color accentColor) {
    final acaoObj = acoes.firstWhere((element) => element['texto'] == acaoSelecionada);
    final isAssertiva = acaoObj['tipo'] == 'Assertiva';

    return Column(
      children: [
        const SizedBox(height: 40),
        Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isAssertiva ? AppColors.success.withOpacity(0.12) : AppColors.warning.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: isAssertiva ? AppColors.success : AppColors.warning, width: 2),
            ),
            child: Icon(
              isAssertiva ? LucideIcons.check : LucideIcons.info,
              color: isAssertiva ? AppColors.success : AppColors.warning,
              size: 56,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          isAssertiva ? 'Excelente Escolha!' : 'Decisão Registrada',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.text),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            isAssertiva
                ? 'Você respirou e agiu com assertividade e controle. Isso reduz a ansiedade e melhora os relacionamentos.'
                : 'Você tomou uma decisão mais impulsiva. Lembre-se de respirar mais e analisar as alternativas em situações reais.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textLight, fontSize: 14, height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton(Color accentColor) {
    if (etapa == 3) {
      return Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('Concluir Atividade', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      );
    }

    if (etapa == 0) {
      return Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: ElevatedButton(
          onPressed: iniciarRespiracao,
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('Iniciar Respiração', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      );
    }

    if (etapa == 1) {
      return Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: OutlinedButton(
          onPressed: null,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(
            respirando ? 'Respirando...' : 'Aguarde',
            style: const TextStyle(color: AppColors.muted),
          ),
        ),
      );
    }

    // Etapa 2: Escolha Ação
    final canSubmit = acaoSelecionada != null;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: ElevatedButton(
        onPressed: (canSubmit && !salvando) ? finalizarJogo : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: salvando
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Enviar Escolha', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class BreathingLungsAnimation extends StatefulWidget {
  final bool isInspiring;
  final bool isActive;

  const BreathingLungsAnimation({
    super.key,
    required this.isInspiring,
    this.isActive = true,
  });

  @override
  State<BreathingLungsAnimation> createState() => _BreathingLungsAnimationState();
}

class _BreathingLungsAnimationState extends State<BreathingLungsAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    // 4 seconds duration to align with segundosRespiracao (4)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _scaleAnimation = Tween<double>(begin: 0.82, end: 1.18).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutQuad,
      ),
    );

    _glowAnimation = Tween<double>(begin: 8.0, end: 24.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutQuad,
      ),
    );

    _colorAnimation = ColorTween(
      begin: const Color(0xFF80CBC4), // Soothing soft teal
      end: AppColors.secondary,       // Brand Sea Green
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutQuad,
    ));

    if (widget.isActive) {
      if (widget.isInspiring) {
        _controller.forward();
      } else {
        _controller.value = 1.0;
        _controller.reverse();
      }
    }
  }

  @override
  void didUpdateWidget(covariant BreathingLungsAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive) {
      if (widget.isInspiring != oldWidget.isInspiring) {
        if (widget.isInspiring) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
      }
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = _scaleAnimation.value;
        final color = _colorAnimation.value ?? AppColors.secondary;
        final glow = _glowAnimation.value;

        return SizedBox(
          width: 240,
          height: 240,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulse ring 2
              Container(
                width: 220 * (scale * 1.05),
                height: 220 * (scale * 1.05),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.02),
                  border: Border.all(
                    color: color.withOpacity(0.06),
                    width: 1.0,
                  ),
                ),
              ),
              // Outer pulse ring 1
              Container(
                width: 190 * scale,
                height: 190 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.04),
                  border: Border.all(
                    color: color.withOpacity(0.12),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.1),
                      blurRadius: glow * 1.2,
                      spreadRadius: glow * 0.1,
                    ),
                  ],
                ),
              ),
              // Inner guide ring
              Container(
                width: 140 * scale,
                height: 140 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.withOpacity(0.18),
                    width: 1.0,
                  ),
                ),
              ),
              // Lungs drawing with scale
              Transform.scale(
                scale: scale,
                child: SizedBox(
                  width: 130,
                  height: 130,
                  child: CustomPaint(
                    painter: LungPainter(
                      animationValue: _controller.value,
                      color: color,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class LungPainter extends CustomPainter {
  final double animationValue; // 0.0 to 1.0
  final Color color;

  LungPainter({required this.animationValue, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final outlinePaint = Paint()
      ..color = color.withOpacity(0.7)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    final tracheaPaint = Paint()
      ..color = color.withOpacity(0.5)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final width = size.width;
    final height = size.height;
    final centerX = width / 2;

    // Draw Trachea (windpipe)
    final tracheaPath = Path();
    tracheaPath.moveTo(centerX, height * 0.12);
    tracheaPath.lineTo(centerX, height * 0.40);
    // Left bronchus
    tracheaPath.moveTo(centerX, height * 0.40);
    tracheaPath.quadraticBezierTo(centerX - width * 0.05, height * 0.45, centerX - width * 0.15, height * 0.48);
    // Right bronchus
    tracheaPath.moveTo(centerX, height * 0.40);
    tracheaPath.quadraticBezierTo(centerX + width * 0.05, height * 0.45, centerX + width * 0.15, height * 0.48);
    
    canvas.drawPath(tracheaPath, tracheaPaint);

    // Left Lung Lobe
    final leftLobePath = Path();
    leftLobePath.moveTo(centerX - width * 0.05, height * 0.40);
    // Curve up to apex of left lung
    leftLobePath.cubicTo(
      centerX - width * 0.15, height * 0.32,
      centerX - width * 0.35, height * 0.32,
      centerX - width * 0.45, height * 0.32,
    );
    // Curve down outer edge
    leftLobePath.cubicTo(
      centerX - width * 0.52, height * 0.48,
      centerX - width * 0.48, height * 0.72,
      centerX - width * 0.32, height * 0.80,
    );
    // Curve along bottom diaphragm edge
    leftLobePath.quadraticBezierTo(
      centerX - width * 0.22, height * 0.83,
      centerX - width * 0.12, height * 0.74,
    );
    // Curve up along inner edge
    leftLobePath.cubicTo(
      centerX - width * 0.10, height * 0.65,
      centerX - width * 0.08, height * 0.50,
      centerX - width * 0.05, height * 0.40,
    );
    leftLobePath.close();

    // Right Lung Lobe (symmetrical to left)
    final rightLobePath = Path();
    rightLobePath.moveTo(centerX + width * 0.05, height * 0.40);
    // Curve up to apex of right lung
    rightLobePath.cubicTo(
      centerX + width * 0.15, height * 0.32,
      centerX + width * 0.35, height * 0.32,
      centerX + width * 0.45, height * 0.32,
    );
    // Curve down outer edge
    rightLobePath.cubicTo(
      centerX + width * 0.52, height * 0.48,
      centerX + width * 0.48, height * 0.72,
      centerX + width * 0.32, height * 0.80,
    );
    // Curve along bottom diaphragm edge
    rightLobePath.quadraticBezierTo(
      centerX + width * 0.22, height * 0.83,
      centerX + width * 0.12, height * 0.74,
    );
    // Curve up along inner edge
    rightLobePath.cubicTo(
      centerX + width * 0.10, height * 0.65,
      centerX + width * 0.08, height * 0.50,
      centerX + width * 0.05, height * 0.40,
    );
    rightLobePath.close();

    // Fill lobes with a radial gradient representing oxygenation
    final gradient = RadialGradient(
      center: Alignment.center,
      radius: 0.85,
      colors: [
        color.withOpacity(0.85),
        color.withOpacity(0.40),
      ],
    );
    
    paint.shader = gradient.createShader(Rect.fromLTWH(0, 0, width, height));

    // Draw lobes
    canvas.drawPath(leftLobePath, paint);
    canvas.drawPath(leftLobePath, outlinePaint);
    canvas.drawPath(rightLobePath, paint);
    canvas.drawPath(rightLobePath, outlinePaint);

    // Inner bronchial tree details (stylized lines)
    final branchPaint = Paint()
      ..color = color.withOpacity(0.25)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final branchesPath = Path();
    // Left lung inner branches
    branchesPath.moveTo(centerX - width * 0.15, height * 0.48);
    branchesPath.quadraticBezierTo(centerX - width * 0.28, height * 0.55, centerX - width * 0.38, height * 0.58);
    branchesPath.moveTo(centerX - width * 0.22, height * 0.51);
    branchesPath.quadraticBezierTo(centerX - width * 0.28, height * 0.43, centerX - width * 0.35, height * 0.39);
    branchesPath.moveTo(centerX - width * 0.28, height * 0.55);
    branchesPath.quadraticBezierTo(centerX - width * 0.32, height * 0.66, centerX - width * 0.34, height * 0.70);

    // Right lung inner branches
    branchesPath.moveTo(centerX + width * 0.15, height * 0.48);
    branchesPath.quadraticBezierTo(centerX + width * 0.28, height * 0.55, centerX + width * 0.38, height * 0.58);
    branchesPath.moveTo(centerX + width * 0.22, height * 0.51);
    branchesPath.quadraticBezierTo(centerX + width * 0.28, height * 0.43, centerX + width * 0.35, height * 0.39);
    branchesPath.moveTo(centerX + width * 0.28, height * 0.55);
    branchesPath.quadraticBezierTo(centerX + width * 0.32, height * 0.66, centerX + width * 0.34, height * 0.70);

    canvas.drawPath(branchesPath, branchPaint);
  }

  @override
  bool shouldRepaint(covariant LungPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || oldDelegate.color != color;
  }
}

