import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../services/paciente_service.dart';

class MissaoCoragemPage extends StatefulWidget {
  final String? atividadePacienteId;
  const MissaoCoragemPage({super.key, this.atividadePacienteId});

  @override
  State<MissaoCoragemPage> createState() => _MissaoCoragemPageState();
}

class _MissaoCoragemPageState extends State<MissaoCoragemPage> {
  final service = PacienteService();
  bool salvando = false;

  final desafios = [
    {'nome': 'Dar bom dia para alguém', 'nivel': 1, 'concluido': true},
    {'nome': 'Fazer uma pergunta a um desconhecido', 'nivel': 2, 'concluido': false},
    {'nome': 'Iniciar uma conversa curta', 'nivel': 3, 'concluido': false},
    {'nome': 'Puxar assunto com alguém no trabalho/escola', 'nivel': 4, 'concluido': false},
    {'nome': 'Falar ou fazer pergunta em um grupo grande', 'nivel': 5, 'concluido': false},
  ];

  Future<void> registrarExposicao(String desafio, String status) async {
    setState(() => salvando = true);

    try {
      final resultado = await service.registrarJogo(
        jogoId: 'coragem',
        dadosPlay: {
          'desafio': desafio,
          'status': status, // 'concluido', 'recusado', 'adiado'
        },
        atividadePacienteId: widget.atividadePacienteId,
      );

      if (!mounted) return;

      // Update state local
      if (status == 'concluido') {
        setState(() {
          final index = desafios.indexWhere((x) => x['nome'] == desafio);
          if (index != -1) {
            desafios[index]['concluido'] = true;
          }
        });
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Icon(
                status == 'concluido' ? LucideIcons.trophy : LucideIcons.info,
                color: status == 'concluido' ? AppColors.warning : AppColors.muted,
              ),
              const SizedBox(width: 8),
              Text(status == 'concluido' ? 'Desafio Superado!' : 'Progresso Registrado'),
            ],
          ),
          content: Text(
            status == 'concluido'
                ? 'Incrível! Você enfrentou o medo e concluiu este nível de exposição gradual!\n\nGanhou +${resultado['pontosGanhos'] ?? 15} XP!'
                : 'Você registrou o status do desafio. O importante é continuar tentando!\n\nGanhou +${resultado['pontosGanhos'] ?? 15} XP pela tentativa.',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (status == 'concluido') {
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
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => salvando = false);
    }
  }

  void _abrirPainelDesafio(String desafio) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              desafio,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text),
            ),
            const SizedBox(height: 12),
            const Text(
              'Registre como foi o resultado dessa atividade de exposição gradual:',
              style: TextStyle(color: AppColors.muted, fontSize: 13),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      registrarExposicao(desafio, 'concluido');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('Concluí'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      registrarExposicao(desafio, 'adiado');
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      side: const BorderSide(color: AppColors.warning),
                    ),
                    child: const Text('Adiei', style: TextStyle(color: AppColors.warning)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      registrarExposicao(desafio, 'recusado');
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      side: const BorderSide(color: AppColors.danger),
                    ),
                    child: const Text('Desisti', style: TextStyle(color: AppColors.danger)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Missão Coragem', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFE0F7FA), Color(0xFFE8EAF6)]),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.rocket, color: AppColors.primary, size: 36),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Sua missão atual', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 4),
                          const Text('Desafio: Ansiedade Social', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Expanded(
                                child: LinearProgressIndicator(
                                  value: 0.4,
                                  backgroundColor: AppColors.border,
                                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text('Nível 2/5', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const Text('Desafios Graduais', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text)),
              const SizedBox(height: 16),
              ...desafios.map((d) {
                final concluido = d['concluido'] as bool;
                final nivel = d['nivel'] as int;
                final nome = d['nome'] as String;

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
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: concluido ? AppColors.softGreen : AppColors.softBlue,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          concluido ? LucideIcons.circleCheck : LucideIcons.circleUser,
                          color: concluido ? AppColors.secondary : AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Nivel $nivel', style: const TextStyle(fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(nome, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.text)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (concluido)
                        const Icon(LucideIcons.check, color: AppColors.secondary)
                      else
                        ElevatedButton(
                          onPressed: () => _abrirPainelDesafio(nome),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(60, 36),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: const Text('Fazer', style: TextStyle(fontSize: 12)),
                        ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
