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
    // Estilo Dark/Tecnológico para MINDSTEPS LABS
    final darkBackground = const Color(0xFF0D1B2A);
    final cardColor = const Color(0xFF1B263B);
    final neonAccent = const Color(0xFF00E5FF);

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: darkBackground,
        colorScheme: ColorScheme.dark(
          primary: neonAccent,
          surface: cardColor,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: darkBackground,
          title: const Text('DECISÃO SOB PRESSÃO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.5)),
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
                  child: _buildConteudo(cardColor, neonAccent),
                ),
              ),
              _buildBottomButton(neonAccent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConteudo(Color cardColor, Color neonAccent) {
    switch (etapa) {
      case 0:
        return _buildSituacaoCritica(cardColor, neonAccent);
      case 1:
        return _buildRespiracao(cardColor, neonAccent);
      case 2:
        return _buildEscolhaAcao(cardColor, neonAccent);
      case 3:
        return _buildSucesso(cardColor, neonAccent);
      default:
        return Container();
    }
  }

  Widget _buildSituacaoCritica(Color cardColor, Color neonAccent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.redAccent),
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
            border: Border.all(color: Colors.red.withOpacity(0.3), width: 1.5),
            boxShadow: [
              BoxShadow(color: Colors.red.withOpacity(0.1), blurRadius: 15, spreadRadius: 2),
            ],
          ),
          child: Column(
            children: [
              const Icon(LucideIcons.octagonAlert, size: 48, color: Colors.redAccent),
              const SizedBox(height: 18),
              const Text(
                'Situação de Alta Pressão:',
                style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                situacao,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.4, color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        const Text(
          'Suas emoções estão querendo dominar.',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 8),
        const Text(
          'Não reaja impulsivamente. Respire primeiro.',
          style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildRespiracao(Color cardColor, Color neonAccent) {
    final progresso = segundosRespiracao / 4.0;
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          'PARE E PENSE',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 2),
        ),
        const SizedBox(height: 8),
        const Text(
          'Respire. Não aja no impulso.',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 60),
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 180,
                height: 180,
                child: CircularProgressIndicator(
                  value: progresso,
                  strokeWidth: 10,
                  backgroundColor: cardColor,
                  valueColor: AlwaysStoppedAnimation<Color>(neonAccent),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    instrucaoRespiracao,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: neonAccent),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${segundosRespiracao}s',
                    style: const TextStyle(fontSize: 22, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 60),
        Text(
          'Ciclo respiratório: $respiracoesConcluidas / 3',
          style: const TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildEscolhaAcao(Color cardColor, Color neonAccent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ESCOLHA SUA AÇÃO',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1.5),
        ),
        const SizedBox(height: 6),
        const Text(
          'Qual é a melhor atitude agora?',
          style: TextStyle(color: Colors.grey, fontSize: 14),
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
                color: selecionada ? neonAccent.withOpacity(0.15) : cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selecionada ? neonAccent : Colors.white24,
                  width: selecionada ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item['texto']!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: selecionada ? FontWeight.bold : FontWeight.normal,
                        color: selecionada ? Colors.white : Colors.white70,
                      ),
                    ),
                  ),
                  if (selecionada)
                    Icon(LucideIcons.circleCheck, color: neonAccent, size: 20),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSucesso(Color cardColor, Color neonAccent) {
    final acaoObj = acoes.firstWhere((element) => element['texto'] == acaoSelecionada);
    final isAssertiva = acaoObj['tipo'] == 'Assertiva';

    return Column(
      children: [
        const SizedBox(height: 40),
        Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isAssertiva ? Colors.teal.withOpacity(0.2) : Colors.amber.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: isAssertiva ? Colors.teal : Colors.amber, width: 2),
            ),
            child: Icon(
              isAssertiva ? LucideIcons.check : LucideIcons.info,
              color: isAssertiva ? Colors.tealAccent : Colors.amberAccent,
              size: 56,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          isAssertiva ? 'Excelente Escolha!' : 'Decisão Registrada',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            isAssertiva
                ? 'Você respirou e agiu com assertividade e controle. Isso reduz a ansiedade e melhora os relacionamentos.'
                : 'Você tomou uma decisão mais impulsiva. Lembre-se de respirar mais e analisar as alternativas em situações reais.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.4),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton(Color neonAccent) {
    if (etapa == 3) {
      return Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: neonAccent,
            foregroundColor: Colors.black,
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
            backgroundColor: neonAccent,
            foregroundColor: Colors.black,
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
            style: const TextStyle(color: Colors.white24),
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
          backgroundColor: neonAccent,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: salvando
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
            : const Text('Enviar Escolha', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
