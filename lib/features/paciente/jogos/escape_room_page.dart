import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../services/paciente_service.dart';

class EscapeRoomPage extends StatefulWidget {
  final String? atividadePacienteId;
  const EscapeRoomPage({super.key, this.atividadePacienteId});

  @override
  State<EscapeRoomPage> createState() => _EscapeRoomPageState();
}

class _EscapeRoomPageState extends State<EscapeRoomPage> {
  final service = PacienteService();
  bool salvando = false;
  int desafioIndex = 0;
  int acertos = 0;

  final List<Map<String, dynamic>> desafios = [
    {
      "sala": "SALA 1 - O GATILHO DA NOTA",
      "pensamento": "\"Se eu tirar uma nota baixa nesta prova, meus pais vão me odiar e minha vida estará destruída.\"",
      "distorcoes": ["Catastrofização", "Leitura de Mente", "Personalização"],
      "correta": "Catastrofização",
      "explicacao": "Catastrofização é antecipar o pior cenário possível sem evidências reais.",
    },
    {
      "sala": "SALA 2 - A FESTA E OS OLHARES",
      "pensamento": "\"Tenho certeza absoluta de que todos na festa acharam a minha roupa ridícula e estão debochando de mim.\"",
      "distorcoes": ["Supergeneralização", "Leitura de Mente", "Raciocínio Emocional"],
      "correta": "Leitura de Mente",
      "explicacao": "Leitura de mente é presumir que sabe exatamente o que os outros estão pensando de forma negativa.",
    },
    {
      "sala": "SALA 3 - O DESEMPENHO PERFEITO",
      "pensamento": "\"Se a minha apresentação não for 100% perfeita sem nenhum erro, eu sou um fracasso completo.\"",
      "distorcoes": ["Pensamento Tudo-ou-Nada", "Filtro Mental", "Personalização"],
      "correta": "Pensamento Tudo-ou-Nada",
      "explicacao": "Pensamento tudo-ou-nada (8 ou 80) vê as situações apenas em categorias extremas sem meio-termo.",
    },
    {
      "sala": "SALA 4 - O JOGO DE FUTEBOL",
      "pensamento": "\"Nosso time perdeu a partida de hoje inteiramente por minha culpa, mesmo eu tendo jogado só 5 minutos.\"",
      "distorcoes": ["Catastrofização", "Desqualificação do Positivo", "Personalização"],
      "correta": "Personalização",
      "explicacao": "Personalização é atribuir a si mesmo a responsabilidade por eventos externos fora do seu controle.",
    },
  ];

  String? distorcaoSelecionada;

  void proximoDesafioOuFinalizar() {
    if (distorcaoSelecionada == null) return;
    final desafio = desafios[desafioIndex];
    final acertou = distorcaoSelecionada == desafio['correta'];
    if (acertou) acertos++;

    if (desafioIndex < desafios.length - 1) {
      setState(() {
        desafioIndex++;
        distorcaoSelecionada = null;
      });
    } else {
      finalizarJogo();
    }
  }

  Future<void> finalizarJogo() async {
    setState(() => salvando = true);
    try {
      await service.registrarJogo(
        jogoId: 'escape',
        dadosPlay: {
          'desafios_totais': desafios.length,
          'acertos': acertos,
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
              Icon(LucideIcons.key, color: AppColors.success),
              SizedBox(width: 8),
              Text('Escapou da Ilusão! 🔑'),
            ],
          ),
          content: Text(
            'Você identificou as distorções cognitivas com sucesso!\n'
            'Resultado: $acertos de ${desafios.length} portas desbloqueadas.',
            style: const TextStyle(fontSize: 16),
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
          SnackBar(content: Text('Erro ao finalizar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final desafio = desafios[desafioIndex];
    final distorcoes = desafio['distorcoes'] as List<String>;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ACHE A DISTORÇÃO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2)),
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
                  Text(
                    desafio['sala'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13),
                  ),
                  Text(
                    'Porta ${desafioIndex + 1} de ${desafios.length}',
                    style: const TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    const Icon(LucideIcons.lock, size: 40, color: AppColors.primary),
                    const SizedBox(height: 16),
                    const Text(
                      'PENSAMENTO AUTOMÁTICO BLOQUEANDO A SAÍDA:',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textLight, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      desafio['pensamento'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Qual é a distorção cognitiva deste pensamento?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.text),
              ),
              const SizedBox(height: 16),
              ...distorcoes.map((d) {
                final selecionada = distorcaoSelecionada == d;
                return GestureDetector(
                  onTap: () => setState(() => distorcaoSelecionada = d),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(18),
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
                            d,
                            style: TextStyle(
                              fontSize: 15,
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
          onPressed: distorcaoSelecionada != null && !salvando ? proximoDesafioOuFinalizar : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: salvando
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  desafioIndex == desafios.length - 1 ? 'Desbloquear Última Porta' : 'Desbloquear Porta (${desafioIndex + 1}/${desafios.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }
}
