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

  final pergunta = "Se eu tirar uma nota baixa, meus pais vão me odiar.";
  final distorcoes = ['Catastrofização', 'Leitura mental', 'Personalização'];
  final distorcaoCorreta = 'Catastrofização';

  String? distorcaoSelecionada;

  Future<void> enviarEscolha() async {
    if (distorcaoSelecionada == null) return;

    setState(() => salvando = true);

    final correta = distorcaoSelecionada == distorcaoCorreta;

    try {
      final resultado = await service.registrarJogo(
        jogoId: 'escape',
        dadosPlay: {
          'situacao': 'Problema na escola/prova.',
          'pergunta': pergunta,
          'distorcao': distorcaoSelecionada!,
          'correta': correta,
        },
        atividadePacienteId: widget.atividadePacienteId,
      );

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Icon(correta ? LucideIcons.key : LucideIcons.info, color: correta ? AppColors.success : AppColors.danger),
              const SizedBox(width: 8),
              Text(correta ? 'Porta Desbloqueada! 🔑' : 'Resposta Incorreta'),
            ],
          ),
          content: Text(
            correta
                ? 'Parabéns! Você identificou a distorção de Catastrofização e abriu a porta para a próxima sala!\n\nGanhou +${resultado['pontosGanhos'] ?? 15} XP!'
                : 'Esta não é a distorção correta. Tente ler novamente e desafiar o pensamento.\n\nDica: Exagerar as consequências negativas é catastrofização.',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (correta) {
                  Navigator.pop(context, true);
                }
              },
              child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar: $e')),
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
        title: const Text('Escape Room Terapêutico', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.doorClosed, size: 64, color: AppColors.primary),
                    SizedBox(height: 12),
                    Text(
                      'Sala 2 - A Floresta da Mente',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Resolva o desafio para abrir a porta.',
                      style: TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('Desafio', style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.bold, fontSize: 11)),
              const SizedBox(height: 8),
              Text(
                'Qual é o pensamento distorcido nesta situação?\n"$pergunta"',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.text, height: 1.4),
              ),
              const SizedBox(height: 24),
              ...distorcoes.map((d) {
                final isSelected = distorcaoSelecionada == d;
                return GestureDetector(
                  onTap: () => setState(() => distorcaoSelecionada = d),
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
                          isSelected ? LucideIcons.circleDot : LucideIcons.circle,
                          color: isSelected ? AppColors.primary : AppColors.muted,
                        ),
                        const SizedBox(width: 12),
                        Text(d, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: distorcaoSelecionada != null
          ? Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppColors.border))),
              child: ElevatedButton(
                onPressed: salvando ? null : enviarEscolha,
                child: salvando
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white))
                    : const Text('Tentar Abrir Porta'),
              ),
            )
          : null,
    );
  }
}
