import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../services/paciente_service.dart';

class CacadorGatilhosPage extends StatefulWidget {
  final String? atividadePacienteId;
  const CacadorGatilhosPage({super.key, this.atividadePacienteId});

  @override
  State<CacadorGatilhosPage> createState() => _CacadorGatilhosPageState();
}

class _CacadorGatilhosPageState extends State<CacadorGatilhosPage> {
  final service = PacienteService();

  final situacaoController = TextEditingController();
  String? gatilhoSelecionado;
  String? emocaoSelecionada;
  double intensidade = 5;
  bool salvando = false;

  final gatilhos = ['Escola/Trabalho', 'Família', 'Redes sociais', 'Finanças', 'Saúde', 'Outro'];
  final emocoes = ['Raiva', 'Tristeza', 'Medo', 'Ansiedade', 'Frustração'];

  Future<void> registrarGatilho() async {
    if (gatilhoSelecionado == null || emocaoSelecionada == null || situacaoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos.')),
      );
      return;
    }

    setState(() => salvando = true);

    try {
      final resultado = await service.registrarJogo(
        jogoId: 'gatilhos',
        dadosPlay: {
          'gatilho': gatilhoSelecionado!,
          'situacao': situacaoController.text.trim(),
          'emocao': emocaoSelecionada!,
          'intensidade': intensidade.toInt(),
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
              Icon(LucideIcons.radar, color: AppColors.secondary),
              SizedBox(width: 8),
              Text('Gatilho Capturado!'),
            ],
          ),
          content: Text(
            'Você identificou e mapeou seu gatilho emocional com sucesso!\n\nGanhou +${resultado['pontosGanhos'] ?? 15} XP!',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, true);
              },
              child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
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
        title: const Text('Caçador de Gatilhos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Qual foi a categoria do gatilho?',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: gatilhos.map((g) {
                        final isSelected = gatilhoSelecionado == g;
                        return ChoiceChip(
                          label: Text(g),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) setState(() => gatilhoSelecionado = g);
                          },
                          selectedColor: AppColors.primary,
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.text, fontWeight: FontWeight.bold),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'O que aconteceu na situação?',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: situacaoController,
                      decoration: const InputDecoration(
                        hintText: 'Descreva a situação em poucas palavras...',
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Qual emoção principal você sentiu?',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: emocoes.map((e) {
                        final isSelected = emocaoSelecionada == e;
                        return ChoiceChip(
                          label: Text(e),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) setState(() => emocaoSelecionada = e);
                          },
                          selectedColor: AppColors.primary,
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.text, fontWeight: FontWeight.bold),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Qual a intensidade do sentimento?',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 12),
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
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: ElevatedButton(
                onPressed: salvando ? null : registrarGatilho,
                child: salvando
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white))
                    : const Text('Capturar Gatilho'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
