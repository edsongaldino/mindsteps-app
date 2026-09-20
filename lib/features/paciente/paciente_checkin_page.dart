import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import 'services/paciente_service.dart';
import 'paciente_home_page.dart';

class EmotionData {
  final String label;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  EmotionData(this.label, this.icon, this.bgColor, this.iconColor);
}

final List<EmotionData> todasEmocoes = [
  EmotionData('Amor', LucideIcons.heart, const Color(0xFFFFE5E5), Colors.pink),
  EmotionData('Alegria', LucideIcons.smile, const Color(0xFFFFF2E5), Colors.orange),
  EmotionData('Calma', LucideIcons.smile, const Color(0xFFE5F0FF), Colors.blue),
  EmotionData('Gratidão', LucideIcons.smilePlus, const Color(0xFFE5FFE5), Colors.green),
  EmotionData('Tranquilidade', LucideIcons.smile, const Color(0xFFF3E5F5), Colors.purple),
  EmotionData('Raiva', LucideIcons.angry, const Color(0xFFFFE5E5), Colors.red),
  EmotionData('Ansiedade', LucideIcons.frown, const Color(0xFFFFEBE5), Colors.deepOrange),
  EmotionData('Tristeza', LucideIcons.frown, const Color(0xFFFFF2E5), Colors.orange),
  EmotionData('Estresse', LucideIcons.zap, const Color(0xFFEBE5FF), Colors.deepPurple),
  EmotionData('Tédio', LucideIcons.meh, const Color(0xFFE5FFFA), Colors.teal),
  EmotionData('Irritação', LucideIcons.flame, const Color(0xFFFFE5E5), Colors.redAccent),
  EmotionData('Confusão', LucideIcons.helpCircle, const Color(0xFFF0F0F0), Colors.grey),
  EmotionData('Cansaço', LucideIcons.moon, const Color(0xFFE5F0FF), Colors.indigo),
  EmotionData('Esperança', LucideIcons.sun, const Color(0xFFE5FFE5), Colors.green),
  EmotionData('Motivação', LucideIcons.rocket, const Color(0xFFFFE5F2), Colors.pinkAccent),
  EmotionData('Outra', LucideIcons.moreHorizontal, const Color(0xFFF0F0F0), Colors.blueGrey),
];

class PacienteCheckinPage extends StatefulWidget {
  const PacienteCheckinPage({super.key});

  @override
  State<PacienteCheckinPage> createState() => _PacienteCheckinPageState();
}

class _PacienteCheckinPageState extends State<PacienteCheckinPage> {
  final observacaoController = TextEditingController();
  final service = PacienteService();

  int humor = 3; 
  String emocaoPrincipal = 'Calma';
  bool salvando = false;
  bool jaFezHoje = false;
  bool carregandoStatus = true;

  @override
  void initState() {
    super.initState();
    _verificarStatus();
  }

  Future<void> _verificarStatus() async {
    try {
      final status = await service.verificarCheckinHoje();
      if (mounted) {
        setState(() {
          jaFezHoje = status;
          carregandoStatus = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => carregandoStatus = false);
      }
    }
  }

  @override
  void dispose() {
    observacaoController.dispose();
    super.dispose();
  }

  Future<void> salvarCheckin() async {
    try {
      setState(() => salvando = true);

      await service.criarCheckin(
        humor: humor,
        intensidade: 5,
        emocaoPrincipal: emocaoPrincipal,
        observacao: observacaoController.text.trim().isEmpty
            ? null
            : observacaoController.text.trim(),
      );

      if (!mounted) return;

      observacaoController.clear();

      setState(() {
        humor = 3;
        emocaoPrincipal = 'Calma';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Check-in salvo com sucesso.')),
      );

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        final state = context.findAncestorStateOfType<PacienteHomePageState>();
        state?.mudarPagina(0);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar check-in: ')),
      );
    } finally {
      if (mounted) {
        setState(() => salvando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (carregandoStatus) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Check-in de hoje',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppColors.text,
                          ),
                        ),
                        if (Navigator.canPop(context))
                          IconButton(
                            icon: const Icon(LucideIcons.x, color: AppColors.muted),
                            onPressed: () => Navigator.pop(context),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Como você está se sentindo?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Escolha a emoção que melhor representa seu momento agora.',
                      style: TextStyle(color: AppColors.muted, fontSize: 14),
                    ),
                    const SizedBox(height: 32),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: todasEmocoes.length,
                      itemBuilder: (context, index) {
                        final emo = todasEmocoes[index];
                        final isSelected = emocaoPrincipal == emo.label;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              emocaoPrincipal = emo.label;
                              if (['Amor', 'Alegria', 'Gratidão', 'Esperança', 'Motivação'].contains(emo.label)) {
                                humor = 5;
                              } else if (['Calma', 'Tranquilidade'].contains(emo.label)) {
                                humor = 4;
                              } else if (['Tédio', 'Confusão', 'Outra'].contains(emo.label)) {
                                humor = 3;
                              } else if (['Ansiedade', 'Estresse', 'Cansaço'].contains(emo.label)) {
                                humor = 2;
                              } else {
                                humor = 1;
                              }
                            });
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: emo.bgColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? emo.iconColor : Colors.transparent,
                                    width: isSelected ? 3 : 0,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: emo.iconColor.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          )
                                        ]
                                      : null,
                                ),
                                child: Icon(
                                  emo.icon,
                                  color: emo.iconColor,
                                  size: isSelected ? 32 : 28,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                emo.label,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                  color: isSelected ? AppColors.text : AppColors.text.withOpacity(0.7),
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F3FF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: AppColors.softPurple,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(LucideIcons.pencil, color: AppColors.primary, size: 20),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Quer nos contar mais?',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.text,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Fique à vontade para descrever o que está sentindo.',
                                      style: TextStyle(color: AppColors.muted, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: observacaoController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: 'Escreva aqui...',
                              hintStyle: const TextStyle(color: AppColors.muted),
                              alignLabelWithHint: true,
                              fillColor: Colors.white,
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                                borderSide: BorderSide(color: AppColors.primary),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: salvando ? null : salvarCheckin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.text, 
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: salvando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : const Text('Salvar Check-in', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
