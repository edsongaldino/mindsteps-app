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
  int casoIndex = 0;
  int pontuacaoAcertos = 0;

  final List<Map<String, dynamic>> casos = [
    {
      "titulo": "CASO #014 - A Mochila Desaparecida",
      "texto": "Uma mochila desapareceu na escola durante o recreio. Três alunos estavam na sala.\n\n"
          "O professor entrou depois e viu a mochila em cima da mesa. "
          "Rafael disse que Bianca foi a última a sair, "
          "mas Bianca jura que viu Lucas mexendo nos fechos antes do sinal tocar.",
      "pergunta": "Quem foi a última pessoa que declarou ter visto a mochila em cima da mesa?",
      "alternativas": ["Rafael", "Bianca", "Lucas", "Professor"],
      "correta": "Professor",
    },
    {
      "titulo": "CASO #015 - O Caderno de Anotações",
      "texto": "Mariana deixou seu caderno sobre a bancada do laboratório às 14h.\n\n"
          "Às 14h15, Pedro entrou no laboratório apenas para pegar os óculos. "
          "Às 14h30, Camila pegou o caderno por engano achando que era o dela. "
          "Por fim, às 14h45, João notou que a bancada já estava totalmente vazia.",
      "pergunta": "Quem pegou o caderno sobre a bancada às 14h30?",
      "alternativas": ["Mariana", "Pedro", "Camila", "João"],
      "correta": "Camila",
    },
    {
      "titulo": "CASO #016 - O Segredo da Chave",
      "texto": "A chave do armário principal costuma ficar guardada na gaveta azul da recepção.\n\n"
          "Contudo, por segurança durante o final de semana, "
          "o supervisor retirou a chave da gaveta e a colocou dentro de um cofre cinza no segundo andar.",
      "pergunta": "Onde a chave ficou guardada durante o final de semana?",
      "alternativas": ["Na gaveta azul", "No armário principal", "No cofre cinza", "Com a recepção"],
      "correta": "No cofre cinza",
    },
    {
      "titulo": "CASO #017 - O Computador Logado",
      "texto": "O computador da recepção ficou logado no sistema após as 18h.\n\n"
          "Carlos diz que saiu às 17h50, e Márcia fechou a clínica às 18h15. "
          "A câmera mostra o último acesso ao sistema às 18h05.",
      "pergunta": "Que horas a câmera registrou o último acesso?",
      "alternativas": ["17h50", "18h00", "18h05", "18h15"],
      "correta": "18h05",
    },
    {
      "titulo": "CASO #018 - O Café Derramado",
      "texto": "Alguém derramou café na mesa de reuniões e não limpou.\n\n"
          "Sabemos que Ana, Marcos e Júlia usaram a sala. "
          "Ana só toma chá, e Marcos estava segurando uma garrafa de água quando entrou. "
          "Júlia foi vista com uma caneca manchada saindo de lá.",
      "pergunta": "O que Marcos estava segurando quando entrou na sala?",
      "alternativas": ["Uma caneca de café", "Um copo de suco", "Uma garrafa de água", "Nada"],
      "correta": "Uma garrafa de água",
    },
  ];

  String? respostaSelecionada;

  void reiniciarJogo() {
    setState(() {
      etapa = 0;
      casoIndex = 0;
      pontuacaoAcertos = 0;
      respostaSelecionada = null;
    });
  }

  void proximoCasoOuFinalizar() {
    if (respostaSelecionada == null) return;
    final caso = casos[casoIndex];
    if (respostaSelecionada == caso['correta']) {
      pontuacaoAcertos++;
    }

    if (casoIndex < casos.length - 1) {
      setState(() {
        casoIndex++;
        respostaSelecionada = null;
        etapa = 1;
      });
    } else {
      finalizarJogo();
    }
  }

  Future<void> finalizarJogo() async {
    setState(() => salvando = true);
    try {
      await service.registrarJogo(
        jogoId: 'investigacao',
        dadosPlay: {
          'casos_totais': casos.length,
          'acertos': pontuacaoAcertos,
          'taxa_acerto': (pontuacaoAcertos / casos.length) * 100,
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
          'MEMÓRIA OPERACIONAL',
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: List.generate(casos.length, (index) {
                  final ativo = index <= casoIndex;
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: ativo ? AppColors.primary : AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
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
            'MEMÓRIA OPERACIONAL VERBAL',
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
          ),
          child: const Column(
            children: [
              Icon(LucideIcons.fileText, size: 48, color: AppColors.primary),
              SizedBox(height: 18),
              Text(
                'DESAFIO DE RETENÇÃO E DETALHES',
                style: TextStyle(color: AppColors.textLight, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
              SizedBox(height: 12),
              Text(
                'Você lerá 3 depoimentos. Leia com bastante atenção, pois após avançar o texto sumirá e você responderá a perguntas sobre os detalhes informados.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: AppColors.text, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCaso(Color cardColor, Color accentColor) {
    final caso = casos[casoIndex];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              caso['titulo'] as String,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            Text(
              'Caso ${casoIndex + 1} de ${casos.length}',
              style: const TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            caso['texto'] as String,
            style: const TextStyle(fontSize: 16, height: 1.5, color: AppColors.text),
          ),
        ),
      ],
    );
  }

  Widget _buildPergunta(Color cardColor, Color accentColor) {
    final caso = casos[casoIndex];
    final alternativas = caso['alternativas'] as List<String>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CASO ${casoIndex + 1}: COMPREENSÃO DE DETALHES',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.muted, letterSpacing: 1.2),
        ),
        const SizedBox(height: 12),
        Text(
          caso['pergunta'] as String,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text),
        ),
        const SizedBox(height: 24),
        ...alternativas.map((alt) {
          final selecionada = respostaSelecionada == alt;
          return GestureDetector(
            onTap: () => setState(() => respostaSelecionada = alt),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: selecionada ? AppColors.primary.withOpacity(0.12) : cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: selecionada ? AppColors.primary : AppColors.border, width: selecionada ? 2 : 1),
              ),
              child: Row(
                children: [
                  Icon(
                    selecionada ? LucideIcons.checkCircle2 : LucideIcons.circle,
                    color: selecionada ? AppColors.primary : AppColors.muted,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      alt,
                      style: TextStyle(
                        fontSize: 15,
                        color: selecionada ? AppColors.primary : AppColors.text,
                        fontWeight: selecionada ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSucesso(Color cardColor, Color accentColor) {
    return Column(
      children: [
        const SizedBox(height: 30),
        Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.success, width: 2),
            ),
            child: const Icon(
              LucideIcons.brain,
              color: AppColors.success,
              size: 56,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Treino de Memória Operacional Concluído!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.text),
        ),
        const SizedBox(height: 12),
        Text(
          'Você acertou $pontuacaoAcertos de ${casos.length} casos analisados.',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'A memória operacional é a habilidade de reter e manipular informações na mente enquanto realizamos tarefas complexas. Bom trabalho!',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textLight, fontSize: 14, height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton(Color accentColor) {
    if (etapa == 3) {
      return Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          children: [
            OutlinedButton.icon(
              onPressed: reiniciarJogo,
              icon: const Icon(LucideIcons.rotateCcw, size: 18),
              label: const Text('Repetir o Jogo (Treinar Novamente)'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Concluir Atividade', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
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
          child: const Text('Iniciar Análise de Depoimentos', style: TextStyle(fontWeight: FontWeight.bold)),
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
          child: const Text('Responder Pergunta', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      );
    }

    final podeEnviar = respostaSelecionada != null;
    final isUltimo = casoIndex == casos.length - 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: (podeEnviar && !salvando) ? proximoCasoOuFinalizar : null,
        child: salvando
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(isUltimo ? 'Finalizar Atividade' : 'Próximo Caso (${casoIndex + 1}/${casos.length})',
                style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
