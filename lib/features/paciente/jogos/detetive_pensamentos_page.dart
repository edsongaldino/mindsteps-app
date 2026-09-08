import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../services/paciente_service.dart';

class DetetivePensamentosPage extends StatefulWidget {
  final String? atividadePacienteId;
  const DetetivePensamentosPage({super.key, this.atividadePacienteId});

  @override
  State<DetetivePensamentosPage> createState() => _DetetivePensamentosPageState();
}

class _DetetivePensamentosPageState extends State<DetetivePensamentosPage> {
  final service = PacienteService();
  int etapa = 1;
  int situacaoIndex = 0;

  final List<Map<String, dynamic>> situacoes = [
    {
      "titulo": "Situação 1: A Mensagem sem Resposta",
      "gatilho": "Seu amigo visualizou sua mensagem e não respondeu há mais de 3 horas.",
      "pensamentos": ['Ele está bravo comigo', 'Talvez esteja ocupado', 'Ele não gosta mais de mim', 'Eu fiz algo de errado'],
    },
    {
      "titulo": "Situação 2: O Chamado do Superior",
      "gatilho": "Seu chefe/professor pediu para conversar a sós com você no final do dia.",
      "pensamentos": ['Vou ser demitido/reprovado', 'Eles descobriram um erro meu', 'Querem me dar um novo projeto', 'É apenas uma reunião de rotina'],
    },
    {
      "titulo": "Situação 3: O Convite Recusado",
      "gatilho": "Você convidou um conhecido para sair e ele disse que não poderá ir hoje.",
      "pensamentos": ['Ninguém gosta da minha companhia', 'Ele realmente tinha outro compromisso', 'Fui inconveniente em chamar', 'Posso convidar outra pessoa'],
    },
    {
      "titulo": "Situação 4: A Avaliação Injusta",
      "gatilho": "Seu chefe elogiou o trabalho da equipe, mas não mencionou o seu esforço específico.",
      "pensamentos": ['Meu trabalho não vale nada', 'Ele me odeia', 'Talvez eu devesse ter falado', 'Foi um elogio geral para todos'],
    },
    {
      "titulo": "Situação 5: A Apresentação",
      "gatilho": "Você gaguejou brevemente durante uma apresentação importante.",
      "pensamentos": ['Todos acharam que sou uma fraude', 'Estraguei tudo', 'Ninguém vai me levar a sério', 'Foi só um tropeço normal'],
    },
  ];

  String? pensamentoEscolhido;
  String? emocaoEscolhida;
  double intensidade = 5;
  final reestruturacaoController = TextEditingController();

  final emocoes = ['Ansiedade', 'Tristeza', 'Frustração', 'Insegurança', 'Raiva'];

  bool salvando = false;

  Future<void> finalizarJogo() async {
    if (reestruturacaoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha a reestruturação cognitiva.')),
      );
      return;
    }

    setState(() => salvando = true);

    try {
      final resultado = await service.registrarJogo(
        jogoId: 'detetive',
        dadosPlay: {
          'situacao': 'Seu amigo visualizou sua mensagem e não respondeu.',
          'pensamento': pensamentoEscolhido ?? '',
          'emocao': emocaoEscolhida ?? '',
          'intensidade': intensidade.toInt(),
          'reestruturacao': reestruturacaoController.text.trim(),
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
              Icon(LucideIcons.sparkles, color: AppColors.warning),
              SizedBox(width: 8),
              Text('Excelente Trabalho!'),
            ],
          ),
          content: Text(
            'Você agiu como um verdadeiro detetive e desafiou seus pensamentos!\n\nGanhou +${resultado['pontosGanhos'] ?? 15} XP!',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Fecha dialog
                Navigator.pop(context, true); // Volta para a tela anterior
              },
              child: const Text('Ótimo!', style: TextStyle(fontWeight: FontWeight.bold)),
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detetive dos Pensamentos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeaderXP(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (etapa == 1) _buildEtapa1(),
                    if (etapa == 2) _buildEtapa2(),
                    if (etapa == 3) _buildEtapa3(),
                  ],
                ),
              ),
            ),
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderXP() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.softPurple,
            child: const Icon(LucideIcons.searchCode, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nível 2 - Investigador',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                  child: LinearProgressIndicator(
                    value: 0.6,
                    minHeight: 6,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Text('120/200 XP', style: TextStyle(fontSize: 12, color: AppColors.muted)),
        ],
      ),
    );
  }

  Widget _buildEtapa1() {
    final situacao = situacoes[situacaoIndex];
    final pensamentos = situacao['pensamentos'] as List<String>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              situacao['titulo'] as String,
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
            ),
            Text(
              'Situação ${situacaoIndex + 1} de ${situacoes.length}',
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('SITUAÇÃO GATILHO', style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.bold, fontSize: 11)),
              const SizedBox(height: 8),
              Text(
                '"${situacao['gatilho']}"',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Que pensamento passou pela sua cabeça?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text),
        ),
        const SizedBox(height: 16),
        ...pensamentos.map((p) {
          final isSelected = pensamentoEscolhido == p;
          return GestureDetector(
            onTap: () => setState(() => pensamentoEscolhido = p),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: isSelected ? 2 : 1),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected ? LucideIcons.circleCheck : LucideIcons.circle,
                    color: isSelected ? AppColors.primary : AppColors.muted,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      p,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: AppColors.text,
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

  Widget _buildEtapa2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Qual emoção esse pensamento te traz?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: emocoes.map((e) {
            final isSelected = emocaoEscolhida == e;
            return ChoiceChip(
              label: Text(e),
              selected: isSelected,
              onSelected: (val) {
                if (val) setState(() => emocaoEscolhida = e);
              },
              selectedColor: AppColors.primary,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.text, fontWeight: FontWeight.bold),
            );
          }).toList(),
        ),
        const SizedBox(height: 32),
        const Text(
          'Qual a intensidade dessa emoção?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(LucideIcons.gauge, color: AppColors.primary),
            Expanded(
              child: Slider(
                value: intensidade,
                min: 1,
                max: 10,
                divisions: 9,
                label: intensidade.round().toString(),
                onChanged: (val) => setState(() => intensidade = val),
              ),
            ),
            Text(intensidade.round().toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
      ],
    );
  }

  Widget _buildEtapa3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reestruturação Cognitiva',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text),
        ),
        const SizedBox(height: 8),
        const Text(
          'Pense em um pensamento alternativo mais realista e menos catastrófico para a situação:',
          style: TextStyle(color: AppColors.muted, fontSize: 14),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: reestruturacaoController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Escreva um pensamento alternativo (ex: Talvez ele esteja ocupado ou sem bateria, ele costuma responder quando pode...)',
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
    final bool canProceed = (etapa == 1 && pensamentoEscolhido != null) ||
        (etapa == 2 && emocaoEscolhida != null) ||
        (etapa == 3 && !salvando);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: ElevatedButton(
        onPressed: canProceed ? () {
          if (etapa < 3) {
            setState(() => etapa++);
          } else {
            if (situacaoIndex < situacoes.length - 1) {
              setState(() {
                situacaoIndex++;
                etapa = 1;
                pensamentoEscolhido = null;
                emocaoEscolhida = null;
                intensidade = 5;
                reestruturacaoController.clear();
              });
            } else {
              finalizarJogo();
            }
          }
        } : null,
        child: salvando
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white))
            : Text(etapa == 3 
                ? (situacaoIndex < situacoes.length - 1 ? 'Próxima Situação' : 'Finalizar Desafio') 
                : 'Próximo'),
      ),
    );
  }
}
