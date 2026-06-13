import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../services/paciente_service.dart';

class InvestigacaoPage extends StatefulWidget {
  final String? atividadePacienteId;
  const InvestigacaoPage({super.key, this.atividadePacienteId});

  @override
  State<InvestigacaoPage> createState() => _InvestigacaoPageState();
}

class _InvestigacaoPageState extends State<InvestigacaoPage> {
  final service = PacienteService();
  bool salvando = false;
  int etapa = 0; // 0: Intro, 1: Caso, 2: Pergunta, 3: Concluido

  final String casoTitulo = "CASO #014";
  final String casoTexto = 
      "Uma mochila desapareceu na escola durante o recreio. "
      "Três alunos estavam na sala.\n\n"
      "O professor entrou depois e viu a mochila em cima da mesa. "
      "Rafael disse que Bianca foi a última a sair, "
      "mas Bianca jura que viu Lucas mexendo nos fechos antes do sinal tocar.";

  final String pergunta = "Quem foi o último a ver a mochila?";
  final List<String> alternativas = ["Rafael", "Bianca", "Lucas", "Professor"];
  final String respostaCorreta = "Professor";

  String? respostaSelecionada;

  Future<void> finalizarJogo() async {
    if (respostaSelecionada == null) return;
    setState(() => salvando = true);
    final acerto = respostaSelecionada == respostaCorreta;

    try {
      await service.registrarJogo(
        jogoId: 'investigacao',
        dadosPlay: {
          'caso': casoTitulo,
          'acerto': acerto,
          'resposta_respondida': respostaSelecionada!,
          'resposta_esperada': respostaCorreta,
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
          'INVESTIGAÇÃO',
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
        return _buildCaso(cardColor, accentColor);
      case 2:
        return _buildPergunta(cardColor, accentColor);
      case 3:
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
            color: AppColors.softBlue,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: const Text(
            'MEMÓRIA OPERACIONAL',
            style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
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
              Icon(LucideIcons.fileSearch, size: 48, color: accentColor),
              const SizedBox(height: 18),
              const Text(
                'Como jogar:',
                style: TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Leia o depoimento do caso com bastante atenção aos detalhes de nomes, lugares e ações.\n\n'
                'Depois, você terá que responder a uma pergunta secreta sobre o caso, testando sua memória operacional verbal.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textLight, fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        const Text(
          'Treine foco e memória verbal sob distração.',
          style: TextStyle(color: AppColors.muted, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildCaso(Color cardColor, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              casoTitulo,
              style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.5),
            ),
            const Icon(LucideIcons.bookOpen, color: AppColors.textLight, size: 20),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.015),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Text(
            casoTexto,
            style: const TextStyle(fontSize: 16, height: 1.6, color: AppColors.text),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Leia com atenção antes de continuar. Você não poderá voltar a ler o caso.',
          style: TextStyle(color: AppColors.muted, fontSize: 13, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Widget _buildPergunta(Color cardColor, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PERGUNTA DE MEMÓRIA',
          style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.2),
        ),
        const SizedBox(height: 12),
        Text(
          pergunta,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text),
        ),
        const SizedBox(height: 28),
        ...alternativas.map((alt) {
          final selecionada = respostaSelecionada == alt;
          return GestureDetector(
            onTap: () {
              setState(() {
                respostaSelecionada = alt;
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
                  width: selecionada ? 2 : 1
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.01),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      alt,
                      style: TextStyle(
                        fontSize: 15,
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
    final acerto = respostaSelecionada == respostaCorreta;
    return Column(
      children: [
        const SizedBox(height: 40),
        Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: acerto ? AppColors.success.withOpacity(0.12) : AppColors.danger.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: acerto ? AppColors.success : AppColors.danger, width: 2),
            ),
            child: Icon(
              acerto ? LucideIcons.check : LucideIcons.x,
              color: acerto ? AppColors.success : AppColors.danger,
              size: 56,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          acerto ? 'Investigação Correta!' : 'Dica de Investigador',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.text),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            acerto
                ? 'Muito bem! Você se lembrou de que o Professor entrou na sala depois e viu a mochila em cima da mesa (portanto, foi o último a vê-la).'
                : 'Não foi dessa vez. O professor viu a mochila por último na mesa. Rafael falou de Bianca, Bianca citou Lucas, mas o professor encerrou o fluxo do depoimento. Treine sua atenção verbal!',
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
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Concluir Investigação', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      );
    }

    if (etapa == 0) {
      return Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () => setState(() => etapa = 1),
          child: const Text('Iniciar Análise de Depoimento', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      );
    }

    if (etapa == 1) {
      return Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () => setState(() => etapa = 2),
          child: const Text('Ir para Pergunta', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      );
    }

    // Etapa 2: Responder
    final podeEnviar = respostaSelecionada != null;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: (podeEnviar && !salvando) ? finalizarJogo : null,
        child: salvando
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Enviar Resposta', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
