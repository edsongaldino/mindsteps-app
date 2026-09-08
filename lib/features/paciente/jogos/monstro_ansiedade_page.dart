import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../services/paciente_service.dart';

class MonstroAnsiedadePage extends StatefulWidget {
  final String? atividadePacienteId;
  const MonstroAnsiedadePage({super.key, this.atividadePacienteId});

  @override
  State<MonstroAnsiedadePage> createState() => _MonstroAnsiedadePageState();
}

class _MonstroAnsiedadePageState extends State<MonstroAnsiedadePage> {
  final service = PacienteService();
  bool salvando = false;

  final nomeController = TextEditingController(text: 'Catastrofossauro');
  final medoController = TextEditingController(text: 'E se tudo der errado?');
  final corpoController = TextEditingController(text: 'Aperto no peito e garganta seca');
  final pensamentoAutomaticoController = TextEditingController(text: 'Vão perceber que estou nervoso e rir de mim');
  String corSelecionada = 'Roxo';
  String formatoSelecionado = 'Chifrudo';

  final cores = ['Roxo', 'Azul', 'Vermelho', 'Verde', 'Preto'];
  final formatos = ['Chifrudo', 'Olhudo', 'Peludo', 'Gigante', 'Dentudo'];

  Future<void> salvarMonstro(String acaoEnfrentamento) async {
    if (nomeController.text.trim().isEmpty || medoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha o nome e o medo do monstro.')),
      );
      return;
    }

    setState(() => salvando = true);

    try {
      final resultado = await service.registrarJogo(
        jogoId: 'monstro',
        dadosPlay: {
          'nome': nomeController.text.trim(),
          'cor': corSelecionada,
          'formato': formatoSelecionado,
          'medo': medoController.text.trim(),
          'localCorpo': corpoController.text.trim(),
          'pensamentoAutomatico': pensamentoAutomaticoController.text.trim(),
          'acao': acaoEnfrentamento,
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
              Icon(LucideIcons.shieldCheck, color: AppColors.secondary),
              SizedBox(width: 8),
              Text('Monstro Enfrentado!'),
            ],
          ),
          content: Text(
            'Você nomeou e confrontou seu monstro da ansiedade!\n\nGanhou +${resultado['pontosGanhos'] ?? 15} XP!',
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
        title: const Text('REGULAÇÃO - ANSIEDADE SOCIAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.softPurple,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: const Icon(
                    LucideIcons.ghost,
                    size: 64,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Nome do seu monstro / ansiedade', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(filled: true, fillColor: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text('Como você se sente / medo principal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              TextField(
                controller: medoController,
                decoration: const InputDecoration(filled: true, fillColor: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text('Onde sentiu no corpo? (Sintomas físicos)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary)),
              const SizedBox(height: 8),
              TextField(
                controller: corpoController,
                decoration: const InputDecoration(
                  hintText: 'Ex: Aperto no peito, suor nas mãos, nó na garganta...',
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text('Qual foi o seu pensamento automático?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary)),
              const SizedBox(height: 8),
              TextField(
                controller: pensamentoAutomaticoController,
                decoration: const InputDecoration(
                  hintText: 'Ex: Todos vão reparar em mim e me julgar...',
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Cor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        DropdownButton<String>(
                          value: corSelecionada,
                          isExpanded: true,
                          items: cores.map((String val) {
                            return DropdownMenuItem<String>(value: val, child: Text(val));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => corSelecionada = val);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Formato', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        DropdownButton<String>(
                          value: formatoSelecionado,
                          isExpanded: true,
                          items: formatos.map((String val) {
                            return DropdownMenuItem<String>(value: val, child: Text(val));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => formatoSelecionado = val);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text('Como você quer enfrentá-lo hoje?', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.text)),
              const SizedBox(height: 16),
              _buildOpcaoEnfrentar('Respirar Fundo', 'Exercício de respiração diafragmática para acalmar o corpo.', LucideIcons.wind),
              _buildOpcaoEnfrentar('Pensar Diferente', 'Desafiar os pensamentos automáticos e catastróficos.', LucideIcons.brainCircuit),
              _buildOpcaoEnfrentar('Ação Corajosa', 'Dar pequenos passos práticos em direção ao que te assusta.', LucideIcons.footprints),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOpcaoEnfrentar(String acao, String descricao, IconData icone) {
    return GestureDetector(
      onTap: salvando ? null : () => salvarMonstro(acao),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.softBlue, shape: BoxShape.circle),
              child: Icon(icone, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(acao, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(descricao, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}
