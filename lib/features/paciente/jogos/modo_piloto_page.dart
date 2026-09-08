import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../services/paciente_service.dart';

class ModoPilotoPage extends StatefulWidget {
  final String? atividadePacienteId;
  const ModoPilotoPage({super.key, this.atividadePacienteId});

  @override
  State<ModoPilotoPage> createState() => _ModoPilotoPageState();
}

class _ModoPilotoPageState extends State<ModoPilotoPage> {
  final service = PacienteService();
  bool salvando = false;
  int etapa = 0; // 0: Alerta/Impulso, 1: Plano, 2: Sucesso
  int cenarioAtualIndex = 0;

  final List<Map<String, dynamic>> cenarios = [
    {
      "titulo": "Situação 1: Provocação no Grupo",
      "gatilho": "Seu amigo faz um comentário no grupo de mensagens que te irrita profundamente.",
      "nivelImpulso": 85,
    },
    {
      "titulo": "Situação 2: Crítica Injusta",
      "gatilho": "Você recebe uma crítica injusta sobre a sua tarefa na frente de várias pessoas.",
      "nivelImpulso": 90,
    },
    {
      "titulo": "Situação 3: Furada de Fila",
      "gatilho": "Alguém fura a fila diretamente na sua frente quando você está atrasado.",
      "nivelImpulso": 75,
    },
    {
      "titulo": "Situação 4: Falha Tecnológica Urgente",
      "gatilho": "Seu celular/computador trava no exato instante em que você precisa enviar um arquivo urgente.",
      "nivelImpulso": 95,
    },
  ];

  late List<List<Map<String, dynamic>>> checklistsPorCenario;

  @override
  void initState() {
    super.initState();
    checklistsPorCenario = List.generate(
      cenarios.length,
      (_) => [
        {"texto": "Respirar fundo por 5 segundos antes de reagir", "feito": false, "icone": LucideIcons.wind},
        {"texto": "Avaliar as consequências de responder com raiva ou impulso", "feito": false, "icone": LucideIcons.brainCircuit},
        {"texto": "Escolher uma resposta assertiva ou pausar a conversa", "feito": false, "icone": LucideIcons.squareCheck},
        {"texto": "Agir conforme sua escolha consciente e calma", "feito": false, "icone": LucideIcons.rocket},
      ],
    );
  }

  void toggleCheck(int index) {
    setState(() {
      checklistsPorCenario[cenarioAtualIndex][index]['feito'] =
          !checklistsPorCenario[cenarioAtualIndex][index]['feito'];
    });
  }

  void proximoCenarioOuFinalizar() {
    final checklistAtual = checklistsPorCenario[cenarioAtualIndex];
    final todosFeitos = checklistAtual.every((element) => element['feito'] as bool);
    if (!todosFeitos) return;

    if (cenarioAtualIndex < cenarios.length - 1) {
      setState(() {
        cenarioAtualIndex++;
        etapa = 0; // Volta para Alerta do próximo cenário
      });
    } else {
      finalizarJogo();
    }
  }

  Future<void> finalizarJogo() async {
    setState(() => salvando = true);
    try {
      await service.registrarJogo(
        jogoId: 'modo_piloto',
        dadosPlay: {
          'cenarios_concluidos': cenarios.length,
          'controle_impulso': 'Alto',
        },
        atividadePacienteId: widget.atividadePacienteId,
      );

      if (!mounted) return;
      setState(() {
        etapa = 2;
      });
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
    final backgroundColor = AppColors.background;
    final cardColor = Colors.white;
    final accentColor = AppColors.secondary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: const Text(
          'CONTROLE INIBITÓRIO',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.text,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: List.generate(cenarios.length, (index) {
                  final ativo = index <= cenarioAtualIndex;
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: ativo ? AppColors.danger : AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _buildConteudo(cardColor, accentColor),
              ),
            ),
            _buildBottomButton(accentColor),
          ],
        ),
      ),
    );
  }

  Widget _buildConteudo(Color cardColor, Color accentColor) {
    switch (etapa) {
      case 0:
        return _buildAlertaImpulso(cardColor, accentColor);
      case 1:
        return _buildPlanoDeVoo(cardColor, accentColor);
      case 2:
        return _buildSucesso(cardColor, accentColor);
      default:
        return Container();
    }
  }

  Widget _buildAlertaImpulso(Color cardColor, Color accentColor) {
    final cenario = cenarios[cenarioAtualIndex];
    final int impulso = cenario['nivelImpulso'] as int;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.danger.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.danger),
          ),
          child: Text(
            'SITUAÇÃO ${cenarioAtualIndex + 1} DE ${cenarios.length}',
            style: const TextStyle(color: AppColors.danger, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 16,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Column(
            children: [
              const Icon(LucideIcons.bell, size: 48, color: AppColors.danger),
              const SizedBox(height: 18),
              Text(
                cenario['titulo'] as String,
                style: const TextStyle(color: AppColors.textLight, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
              const SizedBox(height: 12),
              Text(
                cenario['gatilho'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Column(
          children: [
            const Text(
              'IMPULSO DE REAÇÃO',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textLight),
            ),
            const SizedBox(height: 12),
            Container(
              height: 24,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Row(
                  children: [
                    Expanded(
                      flex: impulso,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [Colors.orange, AppColors.danger]),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 100 - impulso,
                      child: const SizedBox(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Baixo', style: TextStyle(color: AppColors.muted, fontSize: 11)),
                Text('NÍVEL $impulso%', style: const TextStyle(color: AppColors.danger, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlanoDeVoo(Color cardColor, Color accentColor) {
    final checklist = checklistsPorCenario[cenarioAtualIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PLANO DE CONTROLE INIBITÓRIO (${cenarioAtualIndex + 1}/${cenarios.length})',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text, letterSpacing: 1.1),
        ),
        const SizedBox(height: 6),
        const Text(
          'Marque todos os passos para desarmar o seu impulso nesta situação.',
          style: TextStyle(color: AppColors.textLight, fontSize: 13),
        ),
        const SizedBox(height: 20),
        ...checklist.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final feito = item['feito'] as bool;
          return GestureDetector(
            onTap: () => toggleCheck(index),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: feito ? AppColors.success.withOpacity(0.12) : cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: feito ? AppColors.success : AppColors.border, width: feito ? 2 : 1),
              ),
              child: Row(
                children: [
                  Icon(item['icone'] as IconData, color: feito ? AppColors.success : AppColors.muted, size: 22),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      item['texto'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        color: feito ? AppColors.success : AppColors.text,
                        fontWeight: feito ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: feito ? AppColors.success : AppColors.muted, width: 2),
                      color: feito ? AppColors.success : Colors.transparent,
                    ),
                    child: feito ? const Icon(LucideIcons.check, size: 14, color: Colors.white) : null,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSucesso(Color cardColor, Color accentColor) {
    return Column(
      children: [
        const SizedBox(height: 30),
        Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.success, width: 2),
            ),
            child: const Icon(
              LucideIcons.shieldCheck,
              color: AppColors.success,
              size: 56,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Controle Inibitório Concluído!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.text),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Excelente! Você desativou o impulso automático nas ${cenarios.length} situações. '
            'Exercitar a pausa consciente (Respirar ➔ Avaliar ➔ Escolher ➔ Agir) fortifica seu controle inibitório no dia a dia.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textLight, fontSize: 14, height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton(Color accentColor) {
    if (etapa == 2) {
      return Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('Concluir Atividade', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      );
    }

    if (etapa == 0) {
      return Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: ElevatedButton(
          onPressed: () => setState(() => etapa = 1),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.danger,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('Iniciar Controle Inibitório', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      );
    }

    final checklist = checklistsPorCenario[cenarioAtualIndex];
    final todosFeitos = checklist.every((element) => element['feito'] as bool);
    final isUltimo = cenarioAtualIndex == cenarios.length - 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: ElevatedButton(
        onPressed: (todosFeitos && !salvando) ? proximoCenarioOuFinalizar : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: salvando
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(isUltimo ? 'Finalizar Atividade' : 'Próxima Situação (${cenarioAtualIndex + 1}/${cenarios.length})',
                style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
