import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../services/paciente_service.dart';

class TribunalPensamentosPage extends StatefulWidget {
  final String? atividadePacienteId;
  const TribunalPensamentosPage({super.key, this.atividadePacienteId});

  @override
  State<TribunalPensamentosPage> createState() => _TribunalPensamentosPageState();
}

class _TribunalPensamentosPageState extends State<TribunalPensamentosPage> {
  final service = PacienteService();
  final pensamento = "Vou fracassar.";

  final List<String> provasFavor = ["Já errei antes", "Tenho medo de não ser o suficiente"];
  final List<String> provasContra = ["Já tive sucesso em outras coisas", "Estou me preparando e me dedicando"];

  String? veredito;
  bool salvando = false;

  void adicionarProva(bool aFavor) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(aFavor ? 'Adicionar prova A Favor' : 'Adicionar prova Contra'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Escreva a evidência factual...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  if (aFavor) {
                    provasFavor.add(controller.text.trim());
                  } else {
                    provasContra.add(controller.text.trim());
                  }
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  Future<void> salvarVeredito() async {
    if (veredito == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, escolha um veredito para o pensamento.')),
      );
      return;
    }

    setState(() => salvando = true);

    try {
      final resultado = await service.registrarJogo(
        jogoId: 'tribunal',
        dadosPlay: {
          'pensamento': pensamento,
          'provasFavorCount': provasFavor.length,
          'provasContraCount': provasContra.length,
          'veredito': veredito!,
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
              Icon(LucideIcons.gavel, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Veredito Declarado!'),
            ],
          ),
          content: Text(
            'Você julgou o pensamento com evidências reais e declarou o veredito!\n\nGanhou +${resultado['pontosGanhos'] ?? 15} XP!',
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
          SnackBar(content: Text('Erro ao registrar: $e')),
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
        title: const Text('Tribunal dos Pensamentos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text('O PENSAMENTO EM JULGAMENTO', style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.bold, fontSize: 11)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '"$pensamento"',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.text),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.danger.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('RÉU', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold, fontSize: 11)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildColunaProvas(true, provasFavor)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildColunaProvas(false, provasContra)),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Text('Veredito: Qual é a decisão final?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildVereditoButton('Concordo', LucideIcons.thumbsUp, Colors.red),
                        _buildVereditoButton('Talvez', LucideIcons.circleQuestionMark, Colors.amber),
                        _buildVereditoButton('Não concordo', LucideIcons.thumbsDown, AppColors.secondary),
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
                onPressed: salvando ? null : salvarVeredito,
                child: salvando
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white))
                    : const Text('Emitir Veredito'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColunaProvas(bool aFavor, List<String> lista) {
    final cor = aFavor ? AppColors.success : AppColors.danger;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(aFavor ? 'Provas a favor' : 'Provas contra', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Text('${lista.length}', style: TextStyle(color: cor, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          ...lista.map((item) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(item, style: const TextStyle(fontSize: 12, height: 1.3)),
              )),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => adicionarProva(aFavor),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.plus, size: 16, color: AppColors.primary),
                const SizedBox(width: 4),
                Text('Adicionar', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVereditoButton(String valor, IconData icone, Color cor) {
    final selected = veredito == valor;
    return GestureDetector(
      onTap: () => setState(() => veredito = valor),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected ? cor.withOpacity(0.15) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? cor : AppColors.border, width: selected ? 2 : 1),
        ),
        child: Column(
          children: [
            Icon(icone, color: cor),
            const SizedBox(height: 8),
            Text(valor, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: selected ? cor : AppColors.text)),
          ],
        ),
      ),
    );
  }
}
