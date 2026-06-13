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

  final String alertaGatilho = "Seu amigo faz um comentário no grupo que te irrita profundamente.";

  final List<Map<String, dynamic>> checklistPlan = [
    {"texto": "Respirar fundo por 5 segundos", "feito": false, "icone": LucideIcons.wind},
    {"texto": "Pensar nas possíveis consequências de responder com raiva", "feito": false, "icone": LucideIcons.brainCircuit},
    {"texto": "Escolher uma resposta assertiva ou ignorar a provocação", "feito": false, "icone": LucideIcons.squareCheck},
    {"texto": "Agir conforme sua escolha consciente", "feito": false, "icone": LucideIcons.rocket},
  ];

  void toggleCheck(int index) {
    setState(() {
      checklistPlan[index]['feito'] = !checklistPlan[index]['feito'];
    });
  }

  Future<void> finalizarJogo() async {
    final todosFeitos = checklistPlan.every((element) => element['feito'] as bool);
    if (!todosFeitos) return;

    setState(() => salvando = true);
    try {
      await service.registrarJogo(
        jogoId: 'modo_piloto',
        dadosPlay: {
          'gatilho': alertaGatilho,
          'etapas_concluidas': checklistPlan.length,
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
          'MODO PILOTO',
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
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.danger.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.danger),
          ),
          child: const Text(
            'CONTROLE INIBITÓRIO',
            style: TextStyle(color: AppColors.danger, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
        ),
        const SizedBox(height: 32),
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
              const Text(
                'ALERTA DE GATILHO',
                style: TextStyle(color: AppColors.textLight, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
              const SizedBox(height: 12),
              Text(
                alertaGatilho,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
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
                      flex: 85,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [Colors.orange, AppColors.danger]),
                        ),
                      ),
                    ),
                    const Expanded(
                      flex: 15,
                      child: SizedBox(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Baixo', style: TextStyle(color: AppColors.muted, fontSize: 11)),
                Text('CRÍTICO (85%)', style: TextStyle(color: AppColors.danger, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlanoDeVoo(Color cardColor, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SEU PLANO DE CONTROLE',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text, letterSpacing: 1.2),
        ),
        const SizedBox(height: 6),
        const Text(
          'Marque os passos para desarmar o seu impulso.',
          style: TextStyle(color: AppColors.textLight, fontSize: 14),
        ),
        const SizedBox(height: 24),
        ...checklistPlan.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final feito = item['feito'] as bool;
          return GestureDetector(
            onTap: () => toggleCheck(index),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: feito ? AppColors.success.withOpacity(0.12) : cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: feito ? AppColors.success : AppColors.border, width: feito ? 2 : 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.01),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                children: [
                  Icon(item['icone'] as IconData, color: feito ? AppColors.success : AppColors.muted, size: 24),
                  const SizedBox(width: 16),
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
                    width: 24,
                    height: 24,
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
        const SizedBox(height: 40),
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
        const SizedBox(height: 32),
        const Text(
          'Piloto Automático Desativado!',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.text),
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Sucesso! Você assumiu o controle manual das suas ações. '
            'Seguir um plan lógico (Respirar ➔ Pensar ➔ Escolher ➔ Agir) nos permite inibir reações que geram arrependimento posterior.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textLight, fontSize: 14, height: 1.5),
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
          child: const Text('Entrar em modo piloto', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      );
    }

    final todosFeitos = checklistPlan.every((element) => element['feito'] as bool);
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: ElevatedButton(
        onPressed: (todosFeitos && !salvando) ? finalizarJogo : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: salvando
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Confirmar Ações', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
