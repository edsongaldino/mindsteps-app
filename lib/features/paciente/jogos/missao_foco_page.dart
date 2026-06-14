import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../services/paciente_service.dart';

class MissaoFocoPage extends StatefulWidget {
  final String? atividadePacienteId;
  const MissaoFocoPage({super.key, this.atividadePacienteId});

  @override
  State<MissaoFocoPage> createState() => _MissaoFocoPageState();
}

class _MissaoFocoPageState extends State<MissaoFocoPage> {
  final service = PacienteService();
  bool salvando = false;
  int etapa = 0; // 0: Intro, 1: Gameplay, 2: Sucesso

  int rodadaAtual = 1;
  final int totalRodadas = 12;

  String comandoAtual = "IGNORE"; // "EXECUTE" ou "IGNORE"
  String corAlvo = "VERDE"; // "AZUL", "VERDE", "AMARELO"
  Color corAlvoHex = Colors.green;

  int acertos = 0;
  int erros = 0;
  bool respondeuRodada = false;
  Timer? gameTimer;
  Timer? rodadaTimer;

  final random = Random();

  final List<Map<String, dynamic>> opcoesCores = [
    {"nome": "AZUL", "cor": Colors.blue},
    {"nome": "VERDE", "cor": Colors.green},
    {"nome": "AMARELO", "cor": Colors.amber},
  ];

  @override
  void dispose() {
    gameTimer?.cancel();
    rodadaTimer?.cancel();
    super.dispose();
  }

  void iniciarJogo() {
    setState(() {
      etapa = 1;
      rodadaAtual = 1;
      acertos = 0;
      erros = 0;
    });
    gerarRodada();
  }

  void gerarRodada() {
    if (rodadaAtual > totalRodadas) {
      gameTimer?.cancel();
      rodadaTimer?.cancel();
      finalizarJogo();
      return;
    }

    setState(() {
      respondeuRodada = false;
      comandoAtual = random.nextBool() ? "EXECUTE" : "IGNORE";
      final alvo = opcoesCores[random.nextInt(opcoesCores.length)];
      corAlvo = alvo['nome'] as String;
      corAlvoHex = alvo['cor'] as Color;
    });

    // O jogador tem 1.5 segundos para responder
    rodadaTimer?.cancel();
    rodadaTimer = Timer(const Duration(milliseconds: 1600), () {
      if (!respondeuRodada) {
        // Se a instrução era IGNORE, e o usuário não tocou, está correto!
        if (comandoAtual == "IGNORE") {
          acertos++;
        } else {
          erros++;
        }
        proximaRodada();
      }
    });
  }

  void responder(String corTocada) {
    if (respondeuRodada) return;
    rodadaTimer?.cancel();
    
    setState(() {
      respondeuRodada = true;
      if (comandoAtual == "EXECUTE" && corTocada == corAlvo) {
        acertos++;
      } else {
        erros++;
      }
    });

    Timer(const Duration(milliseconds: 600), proximaRodada);
  }

  void proximaRodada() {
    if (!mounted) return;
    setState(() {
      rodadaAtual++;
    });
    gerarRodada();
  }

  Future<void> finalizarJogo() async {
    setState(() => salvando = true);
    try {
      await service.registrarJogo(
        jogoId: 'missao_foco',
        dadosPlay: {
          'total_rodadas': totalRodadas,
          'acertos': acertos,
          'erros': erros,
          'precisao': (acertos / totalRodadas * 100).round(),
        },
        atividadePacienteId: widget.atividadePacienteId,
      );

      if (!mounted) return;
      setState(() {
        etapa = 2;
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
          'MISSÃO FOCO',
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
        return _buildIntro(cardColor, accentColor);
      case 1:
        return _buildGameplay(cardColor, accentColor);
      case 2:
        return _buildSucesso(cardColor, accentColor);
      default:
        return Container();
    }
  }

  Widget _buildIntro(Color cardColor, Color accentColor) {
    return Column(
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
              Icon(LucideIcons.shieldAlert, size: 48, color: accentColor),
              const SizedBox(height: 18),
              const Text(
                'Como jogar:',
                style: TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Responda apenas aos comandos corretos:\n\n'
                '• Se aparecer EXECUTE: Toque na cor correspondente rapidamente.\n'
                '• Se aparecer IGNORE: Não faça nada, espere o tempo passar.\n\n'
                'Evite agir no impulso!',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textLight, fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        const Text(
          'Treine foco e inibição de impulsos.',
          style: TextStyle(color: AppColors.muted, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildGameplay(Color cardColor, Color accentColor) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Rodada $rodadaAtual / $totalRodadas',
              style: const TextStyle(fontSize: 14, color: AppColors.textLight, fontWeight: FontWeight.bold),
            ),
            Text(
              'Foco: ${(acertos / max(1, rodadaAtual - 1) * 100).round()}%',
              style: TextStyle(fontSize: 14, color: accentColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 40),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: respondeuRodada ? AppColors.border : (comandoAtual == "EXECUTE" ? accentColor : AppColors.danger),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: (comandoAtual == "EXECUTE" ? accentColor : AppColors.danger).withOpacity(0.08),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                comandoAtual,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: comandoAtual == "IGNORE" ? AppColors.danger : accentColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'CLIQUE NO $corAlvo',
                style: const TextStyle(fontSize: 15, color: AppColors.text, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 60),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: opcoesCores.map((item) {
            final nome = item['nome'] as String;
            final cor = item['cor'] as Color;
            return GestureDetector(
              onTap: () => responder(nome),
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: cor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: cor.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSucesso(Color cardColor, Color accentColor) {
    final percentual = (acertos / totalRodadas * 100).round();
    return Column(
      children: [
        const SizedBox(height: 30),
        Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: accentColor, width: 2),
            ),
            child: Icon(
              LucideIcons.target,
              color: accentColor,
              size: 56,
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Missão Concluída!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.text),
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.015),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Desempenho de Foco', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.text)),
                ],
              ),
              const Divider(height: 24, color: AppColors.border),
              _buildMetricRow('Acertos', '$acertos / $totalRodadas'),
              const SizedBox(height: 12),
              _buildMetricRow('Erros/Impulsos', '$erros'),
              const SizedBox(height: 12),
              _buildMetricRow('Precisão de Foco', '$percentual%', valueColor: accentColor),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textLight, fontSize: 13)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: valueColor ?? AppColors.text)),
      ],
    );
  }

  Widget _buildBottomButton(Color accentColor) {
    if (etapa == 2) {
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
          child: const Text('Confirmar e Concluir', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      );
    }

    if (etapa == 0) {
      return Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: ElevatedButton(
          onPressed: iniciarJogo,
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('Iniciar Treino', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      );
    }

    return Container();
  }
}
