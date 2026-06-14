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

  final regioes = [
    {'nome': 'Raiva', 'cor': Colors.red, 'descricao': 'Região dos vulcões. Estratégia: PARE, respire e canalize a energia em atividade física.'},
    {'nome': 'Tristeza', 'cor': Colors.blue, 'descricao': 'Região do lago reflexivo. Estratégia: Acolha o sentimento, escreva e busque suporte social.'},
    {'nome': 'Alegria', 'cor': Colors.amber, 'descricao': 'Região da floresta ensolarada. Estratégia: Pratique a gratidão e compartilhe suas conquistas.'},
    {'nome': 'Medo', 'cor': Colors.purple, 'descricao': 'Região das cavernas escuras. Estratégia: Respire fundo e exponha-se gradualmente ao que te assusta.'},
    {'nome': 'Vergonha', 'cor': Colors.teal, 'descricao': 'Região da praia de conchas. Estratégia: Lembre-se que errar é humano e exercite a autocompaixão.'},
  ];

  Future<void> explorarRegiao(String regiao, String estrategia) async {
    setState(() => salvando = true);

    try {
      final resultado = await service.registrarJogo(
        jogoId: 'ilha',
        dadosPlay: {
          'regiao': regiao,
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
              const Icon(LucideIcons.compass, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Explorou a Ilha: $regiao'),
            ],
          ),
          content: Text(
            'Você acessou a área da $regiao e aprendeu a estratégia:\n\n"$estrategia"\n\nGanhou +${resultado['pontosGanhos'] ?? 15} XP!',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, true);
              },
              child: const Text('Entendi', style: TextStyle(fontWeight: FontWeight.bold)),
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
        title: const Text('Ilha das Emoções', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text(
                'Explore uma região para ler reflexões e desbloquear estratégias de regulação emocional.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted, fontSize: 14),
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemCount: regioes.length,
                itemBuilder: (context, index) {
                  final reg = regioes[index];
                  final nome = reg['nome'] as String;
                  final cor = reg['cor'] as Color;
                  final desc = reg['descricao'] as String;

                  return GestureDetector(
                    onTap: salvando ? null : () => explorarRegiao(nome, desc),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(color: cor.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.mapPin, color: cor, size: 36),
                          const SizedBox(height: 12),
                          Text(
                            nome,
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: cor),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
