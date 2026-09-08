import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../services/paciente_service.dart';

class IlhaEmocoesPage extends StatefulWidget {
  final String? atividadePacienteId;
  const IlhaEmocoesPage({super.key, this.atividadePacienteId});

  @override
  State<IlhaEmocoesPage> createState() => _IlhaEmocoesPageState();
}

class _IlhaEmocoesPageState extends State<IlhaEmocoesPage> {
  final service = PacienteService();
  bool salvando = false;
  int problemaIndex = 0;
  int problemasResolvidos = 0;

  final List<Map<String, dynamic>> problemas = [
    {
      "situacao": "Situação 1: Provocação e Conflito",
      "descricao": "Seu colega pegou o seu material escolar sem pedir e o estragou por descuido.",
      "emocaoDominante": "Raiva / Indignação",
      "cor": Colors.red,
      "estrategias": [
        "Expressar a insatisfação com calma e impor limites claros",
        "Gritar e quebrar um pertence do colega como troco",
        "Guardar a raiva para si e remoer o acontecido o dia todo"
      ],
      "corretaIndex": 0,
      "explicacao": "A raiva sinaliza que um limite foi violado. A estratégia assertiva expõe a necessidade sem agir com violência.",
    },
    {
      "situacao": "Situação 2: Expectativa Frustrada",
      "descricao": "Você estudou bastante para uma prova, mas o resultado ficou abaixo do que você esperava.",
      "emocaoDominante": "Tristeza / Frustração",
      "cor": Colors.blue,
      "estrategias": [
        "Desistir da matéria e dizer que nunca mais vai estudar",
        "Acolher a frustração, analisar onde errou e pedir apoio ao professor",
        "Fingir que não se importa com nada para não sentir dor"
      ],
      "corretaIndex": 1,
      "explicacao": "A frustração faz parte do aprendizado. Acolher o sentimento e buscar soluções práticas promove resiliência.",
    },
    {
      "situacao": "Situação 3: Exposição em Público",
      "descricao": "Você foi chamado para apresentar um trabalho na frente de toda a escola amanhã.",
      "emocaoDominante": "Medo / Ansiedade",
      "cor": Colors.purple,
      "estrategias": [
        "Faltar na escola para fugir completamente da apresentação",
        "Praticar a respiração pausada e treinar a fala antes de se expor",
        "Ficar pensando em tudo de ruim que pode dar errado até a hora"
      ],
      "corretaIndex": 1,
      "explicacao": "O medo diminui quando nos preparamos e enfrentamos gradualmente a situação com técnicas de respiração.",
    },
    {
      "situacao": "Situação 4: Pequeno Deslize em Público",
      "descricao": "Você se desequilibrou e deixou cair sua bandeja de refeição no refeitório lotado.",
      "emocaoDominante": "Vergonha / Constrangimento",
      "cor": Colors.teal,
      "estrategias": [
        "Lembrar que acidentes acontecem com qualquer um e dar uma risada leve",
        "Esconder a cabeça e achar que todos ficarão lembrando disso pra sempre",
        "Sair correndo chorando do local sem pedir ajuda"
      ],
      "corretaIndex": 0,
      "explicacao": "A autocompaixão nos lembra de que deslizes cotidianos acontecem com todos os seres humanos.",
    },
  ];

  int? estrategiaSelecionada;

  void proximoProblemaOuFinalizar() {
    if (estrategiaSelecionada == null) return;
    final prob = problemas[problemaIndex];
    if (estrategiaSelecionada == prob['corretaIndex']) {
      problemasResolvidos++;
    }

    if (problemaIndex < problemas.length - 1) {
      setState(() {
        problemaIndex++;
        estrategiaSelecionada = null;
      });
    } else {
      finalizarJogo();
    }
  }

  Future<void> finalizarJogo() async {
    setState(() => salvando = true);
    try {
      await service.registrarJogo(
        jogoId: 'ilha',
        dadosPlay: {
          'problemas_totais': problemas.length,
          'problemas_resolvidos': problemasResolvidos,
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
              Text('Jornada Concluída!'),
            ],
          ),
          content: Text(
            'Você navegou por ${problemas.length} desafios na Ilha das Emoções e aprendeu técnicas valiosas de autorregulação.\n\n'
            'Estratégias assertivas escolhidas: $problemasResolvidos de ${problemas.length}.',
            style: const TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, true);
              },
              child: const Text('Concluir', style: TextStyle(fontWeight: FontWeight.bold)),
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

  @override
  Widget build(BuildContext context) {
    final prob = problemas[problemaIndex];
    final estrategias = prob['estrategias'] as List<String>;
    final Color corTema = prob['cor'] as Color;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('PSICOEDUCAÇÃO - ILHA DAS EMOÇÕES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.1)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: corTema.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      prob['emocaoDominante'] as String,
                      style: TextStyle(color: corTema, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  Text(
                    'Problema ${problemaIndex + 1} de ${problemas.length}',
                    style: const TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Text(
                      prob['situacao'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.muted, letterSpacing: 1.1),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      prob['descricao'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Qual é a melhor estratégia de regulação emocional?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.text),
              ),
              const SizedBox(height: 16),
              ...estrategias.asMap().entries.map((entry) {
                final idx = entry.key;
                final texto = entry.value;
                final selecionada = estrategiaSelecionada == idx;

                return GestureDetector(
                  onTap: () => setState(() => estrategiaSelecionada = idx),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: selecionada ? AppColors.primary.withOpacity(0.12) : Colors.white,
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
                            texto,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: selecionada ? FontWeight.bold : FontWeight.normal,
                              color: selecionada ? AppColors.primary : AppColors.text,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
        child: ElevatedButton(
          onPressed: estrategiaSelecionada != null && !salvando ? proximoProblemaOuFinalizar : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: salvando
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  problemaIndex == problemas.length - 1 ? 'Concluir Psicoeducação' : 'Próximo Problema (${problemaIndex + 1}/${problemas.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }
}
