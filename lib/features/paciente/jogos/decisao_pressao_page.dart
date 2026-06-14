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
              // Gif de respiração
              Image.asset(
                'assets/images/respiracao.gif',
                width: 220,
                height: 220,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      color: AppColors.border.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Adicione seu GIF em\nassets/images/respiracao.gif',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textLight, fontSize: 13),
                        ),
                      ),
                    ),
                  );
                },
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
