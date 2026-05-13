import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/auth/auth_storage.dart';
import '../../core/theme/app_theme.dart';
import '../auth/login_page.dart';

class AdminConfiguracoesPage extends StatelessWidget {
  const AdminConfiguracoesPage({super.key});

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
            'Configurações',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 20),
          const _OpcaoAdmin(
            titulo: 'Minha conta',
            icone: LucideIcons.user,
          ),
          const _OpcaoAdmin(
            titulo: 'Configurações da plataforma',
            icone: LucideIcons.settings,
          ),
          const _OpcaoAdmin(
            titulo: 'Planos e assinaturas',
            icone: LucideIcons.creditCard,
          ),
          const _OpcaoAdmin(
            titulo: 'Ajuda e suporte',
            icone: LucideIcons.circleQuestionMark,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _sair(context),
            icon: const Icon(LucideIcons.logOut),
            label: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}

class _OpcaoAdmin extends StatelessWidget {
  final String titulo;
  final IconData icone;

  const _OpcaoAdmin({
    required this.titulo,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                color: AppColors.text,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const Icon(
            LucideIcons.chevronRight,
            color: AppColors.muted,
          ),
        ],
      ),
    );
  }
}