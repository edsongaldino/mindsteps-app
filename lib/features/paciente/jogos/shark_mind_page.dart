import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../services/paciente_service.dart';

class SharkMindPage extends StatefulWidget {
  final String? atividadePacienteId;
  const SharkMindPage({super.key, this.atividadePacienteId});

  @override
  State<SharkMindPage> createState() => _SharkMindPageState();
}

class _SharkMindPageState extends State<SharkMindPage> {
  final service = PacienteService();
  bool salvando = false;
  int etapa = 0; // 0: Intro, 1: Pitch, 2: Sucesso

  final String produto = "Clip de Papel";
  final String comprador = "Um astronauta";

  bool gravando = false;
  int segundosRestantes = 30;
  Timer? timerGravacao;
  String statusGravacao = "Clique no microfone para gravar";

  @override
  void dispose() {
    timerGravacao?.cancel();
    super.dispose();
  }

  void alternarGravacao() {
    if (gravando) {
      // Parar
      timerGravacao?.cancel();
      setState(() {
        gravando = false;
        statusGravacao = "Áudio gravado com sucesso!";
      });
    } else {
      // Começar
      setState(() {
        gravando = true;
        segundosRestantes = 30;
        statusGravacao = "Gravando seu Pitch... fale como venderia o clip.";
      });

      timerGravacao = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        setState(() {
          if (segundosRestantes > 1) {
            segundosRestantes--;
          } else {
            timer.cancel();
            gravando = false;
            statusGravacao = "Áudio gravado com sucesso!";
          }
        });
      });
    }
  }

  Future<void> finalizarJogo() async {
    setState(() => salvando = true);
    try {
      await service.registrarJogo(
        jogoId: 'shark_mind',
        dadosPlay: {
          'produto': produto,
          'comprador': comprador,
          'tempo_gravado': 30 - segundosRestantes,
          'pitch_gravado': true,
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
        title: const Text('SHARK MIND', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.5)),
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
        return _buildPitch(cardColor, neonAccent);
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
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green.withOpacity(0.5)),
          ),
          child: const Text(
            'FLEXIBILIDADE COGNITIVA',
            style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
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
              Icon(LucideIcons.speech, size: 48, color: neonAccent),
              const SizedBox(height: 18),
              const Text(
                'Como jogar:',
                style: TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Você terá o desafio de vender um produto totalmente comum para um comprador inusitado.\n\n'
                'Isso exige criar argumentos criativos e alternativos fora do padrão. Grave seu pitch de 30 segundos usando o microfone.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textLight, fontSize: 14, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        const Text(
          'Treine fluência verbal, criatividade e persuasão.',
          style: TextStyle(color: AppColors.muted, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildPitch(Color cardColor, Color neonAccent) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text('PRODUTO', style: TextStyle(color: AppColors.textLight, fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(produto, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text('VENDA PARA', style: TextStyle(color: AppColors.textLight, fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(comprador, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 48),
        Text(
          'GRAVE SEU PITCH',
          style: TextStyle(fontSize: 14, color: neonAccent, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        const SizedBox(height: 8),
        Text(
          'Tempo: ${segundosRestantes}s',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.text),
        ),
        const SizedBox(height: 32),
        GestureDetector(
          onTap: alternarGravacao,
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: gravando ? Colors.redAccent.withOpacity(0.1) : neonAccent.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: gravando ? Colors.redAccent : neonAccent, width: 3),
              boxShadow: [
                BoxShadow(
                  color: (gravando ? Colors.redAccent : neonAccent).withOpacity(0.2),
                  blurRadius: 15,
                ),
              ],
            ),
            child: Icon(
              gravando ? LucideIcons.square : LucideIcons.mic,
              color: gravando ? Colors.redAccent : neonAccent,
              size: 40,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          statusGravacao,
          style: TextStyle(color: gravando ? Colors.redAccent : AppColors.textLight, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSucesso(Color cardColor, Color neonAccent) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: neonAccent.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: neonAccent, width: 2),
            ),
            child: Icon(
              LucideIcons.rocket,
              color: neonAccent,
              size: 56,
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Pitch Gravado com Sucesso!',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.text),
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Excelente! Você encontrou usos inovadores e inusitados para um clip simples. '
            'Exercitar o pensamento alternativo ajuda a superar a rigidez mental e redefinir problemas difíceis em oportunidades.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textLight, fontSize: 14, height: 1.4),
          ),
        ),
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
          child: const Text('Concluir Atividade', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      );
    }

    if (etapa == 0) {
      return Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: ElevatedButton(
          onPressed: () => setState(() => etapa = 1),
          style: ElevatedButton.styleFrom(
            backgroundColor: neonAccent,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('Entrar na Rodada de Pitch', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      );
    }

    // Etapa 1: Pitch. Permitir enviar apenas se gravou algo (ou seja, se a gravação encerrou e o tempo mudou)
    final gravou = (segundosRestantes < 30) && !gravando;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: ElevatedButton(
        onPressed: (gravou && !salvando) ? finalizarJogo : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: neonAccent,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: salvando
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Enviar Pitch de Vendas', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
