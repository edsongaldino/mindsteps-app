import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../services/paciente_service.dart';

class HeroiInteriorPage extends StatefulWidget {
  final String? atividadePacienteId;
  const HeroiInteriorPage({super.key, this.atividadePacienteId});

  @override
  State<HeroiInteriorPage> createState() => _HeroiInteriorPageState();
}

class _HeroiInteriorPageState extends State<HeroiInteriorPage> {
  final service = PacienteService();
  bool salvando = false;

  String nome = "Lucas";
  int pontos = 650;
  int nivel = 2;
  String tituloHeroi = "Explorador";

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final me = await service.obterMe();
      setState(() {
        nome = me['nome'] ?? 'Paciente';
        pontos = me['pontos'] ?? 0;
        nivel = me['nivel'] ?? 1;

        if (nivel >= 10) {
          tituloHeroi = "Mentor";
        } else if (nivel >= 5) {
          tituloHeroi = "Guardião";
        } else {
          tituloHeroi = "Explorador";
        }
      });
    } catch (e) {
      // Usa mocks se falhar
    }
  }

  Future<void> registrarConquista() async {
    setState(() => salvando = true);

    try {
      final resultado = await service.registrarJogo(
        jogoId: 'jornada',
        dadosPlay: {
          'avatar': 'Explorador',
          'nivel': nivel,
          'totalXP': pontos,
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
              Icon(LucideIcons.award, color: AppColors.warning),
              SizedBox(width: 8),
              Text('Jornada Atualizada!'),
            ],
          ),
          content: Text(
            'Seu herói interno ganhou mais XP pela dedicação hoje!\n\nGanhou +${resultado['pontosGanhos'] ?? 15} XP!',
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
    final progressoNivel = (pontos % 100) / 100.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Jornada do Herói Interior', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: const BoxDecoration(color: AppColors.softGreen, shape: BoxShape.circle),
                      child: const Icon(LucideIcons.userRoundCheck, size: 56, color: AppColors.primary),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      nome,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.text),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        'Nível $nivel • $tituloHeroi',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const Text('Progresso do Nível', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progressoNivel,
                  minHeight: 12,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Faltam ${100 - (pontos % 100)} XP para alcançar o próximo nível!',
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
              ),
              const SizedBox(height: 32),
              const Text('Conquistas da Semana', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.text)),
              const SizedBox(height: 16),
              _buildAchievement('Diário emocional preenchido', '+50 XP', true),
              _buildAchievement('Desafio Missão Coragem concluído', '+100 XP', true),
              _buildAchievement('Jogar minijogo diário', '+80 XP', false),
              _buildAchievement('Fazer check-in emocional de humor', '+30 XP', true),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppColors.border))),
        child: ElevatedButton(
          onPressed: salvando ? null : registrarConquista,
          child: salvando
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white))
              : const Text('Reivindicar XP do Herói'),
        ),
      ),
    );
  }

  Widget _buildAchievement(String titulo, String xp, bool completo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            completo ? LucideIcons.circleCheck : LucideIcons.circle,
            color: completo ? AppColors.success : AppColors.muted,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              titulo,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: completo ? AppColors.text : AppColors.muted,
                decoration: completo ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(xp, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: completo ? AppColors.primary : AppColors.muted)),
        ],
      ),
    );
  }
}
