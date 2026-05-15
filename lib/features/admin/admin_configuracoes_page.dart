import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/auth/auth_storage.dart';
import '../../core/theme/app_theme.dart';
import '../auth/login_page.dart';

import 'admin_metricas_page.dart';
import 'admin_perfil_page.dart';

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
          _OpcaoAdmin(
            titulo: 'Meu perfil',
            icone: LucideIcons.user,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminPerfilPage()),
              );
            },
          ),
          _OpcaoAdmin(
            titulo: 'Métricas',
            icone: LucideIcons.fileText,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminMetricasPage()),
              );
            },
          ),
          _OpcaoAdmin(
            titulo: 'Configurações da plataforma',
            icone: LucideIcons.settings,
            onTap: () {},
          ),
          _OpcaoAdmin(
            titulo: 'Planos e assinaturas',
            icone: LucideIcons.creditCard,
            onTap: () {},
          ),
          _OpcaoAdmin(
            titulo: 'Ajuda e suporte',
            icone: LucideIcons.circleQuestionMark,
            onTap: () {},
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () => _sair(context),
              icon: const Icon(LucideIcons.logOut, color: AppColors.danger),
              label: const Text(
                'Sair da conta',
                style: TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger.withOpacity(0.1),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OpcaoAdmin extends StatelessWidget {
  final String titulo;
  final IconData icone;
  final VoidCallback onTap;

  const _OpcaoAdmin({
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
      ),
    );
  }
}