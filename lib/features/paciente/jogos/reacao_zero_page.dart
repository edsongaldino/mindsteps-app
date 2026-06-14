import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../services/paciente_service.dart';

class ReacaoZeroPage extends StatefulWidget {
  final String? atividadePacienteId;
  const ReacaoZeroPage({super.key, this.atividadePacienteId});

  @override
  State<ReacaoZeroPage> createState() => _ReacaoZeroPageState();
}

class _ReacaoZeroPageState extends State<ReacaoZeroPage> {
  final service = PacienteService();
  bool salvando = false;
  int etapa = 0; // 0: Intro, 1: Gameplay, 2: Sucesso

  int rodadaAtual = 1;
  final int totalRodadas = 12;

  String comandoAtual = "TOQUE"; // "TOQUE", "NÃO TOQUE", "CONGELAR!"
  Color corComando = Colors.green;
  IconData iconeComando = LucideIcons.circle;

  int acertos = 0;
  int erros = 0;
  bool respondeuRodada = false;
  Timer? rodadaTimer;

  final random = Random();

  @override
  void dispose() {
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
      rodadaTimer?.cancel();
      finalizarJogo();
      return;
    }

    final randVal = random.nextInt(3);
    setState(() {
      respondeuRodada = false;
      if (randVal == 0) {
        comandoAtual = "TOQUE";
        corComando = Colors.green;
        iconeComando = LucideIcons.squareCheck;
      } else if (randVal == 1) {
        comandoAtual = "NÃO TOQUE";
        corComando = Colors.redAccent;
        iconeComando = LucideIcons.x;
      } else {
        comandoAtual = "CONGELAR!";
        corComando = Colors.blueAccent;
        iconeComando = LucideIcons.snowflake;
      }
    });

    rodadaTimer?.cancel();
    // O jogador tem 1.3 segundos para reagir
    rodadaTimer = Timer(const Duration(milliseconds: 1400), () {
      if (!respondeuRodada) {
        // Se o comando era NÃO TOQUE ou CONGELAR!, e o usuário NÃO tocou, ele acertou!
        if (comandoAtual == "NÃO TOQUE" || comandoAtual == "CONGELAR!") {
          acertos++;
        } else {
          erros++;
        }
        proximaRodada();
      }
    });
  }

  void responderAoToque() {
    if (respondeuRodada) return;
    rodadaTimer?.cancel();

    setState(() {
      respondeuRodada = true;
      if (comandoAtual == "TOQUE") {
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
        jogoId: 'reacao_zero',
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
    final cardColor = AppColors.card;
    final accentColor = AppColors.secondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('REAÇÃO ZERO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.5)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
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

  Widget _buildConteudo(Color cardColor, Color neonAccent) {
    switch (etapa) {
      case 0:
        return _buildIntro(cardColor, neonAccent);
      case 1:
        return _buildGameplay(cardColor, neonAccent);
      case 2:
        return _buildSucesso(cardColor, neonAccent);
      default:
        return Container();
    }
  }

  Widget _buildIntro(Color cardColor, Color neonAccent) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
          ),
          child: const Text(
            'CONTROLE INIBITÓRIO',
            style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
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
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(LucideIcons.zap, size: 48, color: neonAccent),
              const SizedBox(height: 18),
              const Text(
                'Como jogar:',
                style: TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Reaja rapidamente aos sinais na tela:\n\n'
                '• Se aparecer TOQUE (Verde): Clique no botão rápido!\n'
                '• Se aparecer NÃO TOQUE (Vermelho): Fique parado!\n'
                '• Se aparecer CONGELAR! (Azul): Fique congelado!\n\n'
                'Teste seu tempo de reação motora.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textLight, fontSize: 14, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        const Text(
          'Treine inibição de reações motoras automáticas.',
          style: TextStyle(color: AppColors.muted, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildGameplay(Color cardColor, Color neonAccent) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Sinal $rodadaAtual / $totalRodadas',
              style: const TextStyle(fontSize: 14, color: AppColors.textLight, fontWeight: FontWeight.bold),
            ),
            Text(
              'Acurácia: ${(acertos / max(1, rodadaAtual - 1) * 100).round()}%',
              style: TextStyle(fontSize: 14, color: neonAccent, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 50),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: respondeuRodada ? AppColors.border : corComando,
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: corComando.withOpacity(0.1),
                blurRadius: 25,
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(iconeComando, size: 56, color: corComando),
              const SizedBox(height: 20),
              Text(
                comandoAtual,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: corComando,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 60),
        GestureDetector(
          onTap: responderAoToque,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: cardColor,
              shape: BoxShape.circle,
              border: Border.all(color: neonAccent, width: 3),
              boxShadow: [
                BoxShadow(color: neonAccent.withOpacity(0.15), blurRadius: 20),
              ],
            ),
            child: const Center(
              child: Text(
                'TOQUE!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: AppColors.text),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSucesso(Color cardColor, Color neonAccent) {
    final percentual = (acertos / totalRodadas * 100).round();
    return Column(
      children: [
        const SizedBox(height: 30),
        Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: neonAccent.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: neonAccent, width: 2),
            ),
            child: Icon(
              LucideIcons.zap,
              color: neonAccent,
              size: 56,
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Reação Concluída!',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.text),
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Desempenho Motor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.text)),
                ],
              ),
              const Divider(height: 24, color: AppColors.border),
              _buildMetricRow('Acertos/Sinais corretos', '$acertos / $totalRodadas'),
              const SizedBox(height: 12),
              _buildMetricRow('Erros/Reações falsas', '$erros'),
              const SizedBox(height: 12),
              _buildMetricRow('Acurácia de Reação', '$percentual%', valueColor: neonAccent),
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

  Widget _buildBottomButton(Color neonAccent) {
    if (etapa == 2) {
      return Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: neonAccent,
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
            backgroundColor: neonAccent,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('Iniciar Teste de Reação', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      );
    }

    // Gameplay
    return Container();
  }
}
