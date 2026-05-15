import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/auth/auth_storage.dart';
import '../../core/theme/app_theme.dart';
import '../auth/login_page.dart';
import 'perfil_page.dart';
import 'relatorios_page.dart';

class MaisPage extends StatelessWidget {
  const MaisPage({super.key});

  Future<void> _sair(BuildContext context) async {
    await AuthStorage.limpar();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mais',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 20),
          _OpcaoMais(
            titulo: 'Meu perfil',
            icone: LucideIcons.user,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PsicologoPerfilPage()),
              );
            },
          ),
          _OpcaoMais(
            titulo: 'Relatórios',
            icone: Icons.bar_chart,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RelatoriosPage()),
              );
            },
          ),
          _OpcaoMais(
            titulo: 'Configurações',
            icone: LucideIcons.settings,
            onTap: () {},
          ),
          _OpcaoMais(
            titulo: 'Ajuda e suporte',
            icone: LucideIcons.circleQuestionMark,
            onTap: () {},
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _sair(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFE5E5),
                foregroundColor: AppColors.danger,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: const Icon(LucideIcons.logOut),
              label: const Text('Sair da conta', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class _OpcaoMais extends StatelessWidget {
  final String titulo;
  final IconData icone;
  final VoidCallback onTap;

  const _OpcaoMais({
    required this.titulo,
    required this.icone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
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
            const Icon(LucideIcons.chevronRight, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}