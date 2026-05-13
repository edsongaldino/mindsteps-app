import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';

class RelatoriosPage extends StatelessWidget {
  const RelatoriosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Relatórios',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Acompanhe evolução, adesão e humor dos pacientes.',
            style: TextStyle(color: AppColors.muted),
          ),
          SizedBox(height: 20),
          _RelatorioCard('Adesão semanal', '85%', LucideIcons.trendingUp),
          _RelatorioCard('Check-ins realizados', '42', LucideIcons.heartPulse),
          _RelatorioCard('Atividades concluídas', '128', LucideIcons.clipboardCheck),
        ],
      ),
    );
  }
}

class _RelatorioCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icone;

  const _RelatorioCard(this.titulo, this.valor, this.icone);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icone, color: AppColors.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
            ),
          ),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}