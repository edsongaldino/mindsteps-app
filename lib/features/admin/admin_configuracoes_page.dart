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

  void _mostrarConfiguracoes(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Configurações da plataforma',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOut)),
          child: Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: AppColors.background,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: double.infinity,
                decoration: const BoxDecoration(
                  border: Border(left: BorderSide(color: AppColors.border, width: 1)),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Configurações',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.text,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(LucideIcons.x, color: AppColors.muted),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Configurações do Sistema',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Acesse os parâmetros globais da plataforma, limites de requisições, backups de bancos de dados PostgreSQL e chaves de APIs integradas.',
                                  style: TextStyle(fontSize: 14, color: AppColors.muted, height: 1.5),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _mostrarPlanos(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Planos e assinaturas',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOut)),
          child: Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: AppColors.background,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: double.infinity,
                decoration: const BoxDecoration(
                  border: Border(left: BorderSide(color: AppColors.border, width: 1)),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Planos e Assinaturas',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.text,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(LucideIcons.x, color: AppColors.muted),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Gerenciamento Financeiro',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Configure faixas de cobrança, faturas ativas de psicólogos credenciados e relatórios de receitas recorrentes da plataforma.',
                                  style: TextStyle(fontSize: 14, color: AppColors.muted, height: 1.5),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _mostrarAjuda(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Ajuda e suporte',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOut)),
          child: Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: AppColors.background,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: double.infinity,
                decoration: const BoxDecoration(
                  border: Border(left: BorderSide(color: AppColors.border, width: 1)),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Ajuda e Suporte',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.text,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(LucideIcons.x, color: AppColors.muted),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Suporte do Administrador',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Dúvidas sobre manutenção de servidores ou bugs críticos? Contate o time de engenharia da MindSteps:',
                                  style: TextStyle(fontSize: 14, color: AppColors.muted, height: 1.5),
                                ),
                                SizedBox(height: 20),
                                Row(
                                  children: [
                                    Icon(LucideIcons.mail, color: AppColors.primary, size: 18),
                                    SizedBox(width: 8),
                                    Text('admin@mindsteps.com.br', style: TextStyle(fontSize: 14, color: AppColors.text)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
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
            onTap: () => _mostrarConfiguracoes(context),
          ),
          _OpcaoAdmin(
            titulo: 'Planos e assinaturas',
            icone: LucideIcons.creditCard,
            onTap: () => _mostrarPlanos(context),
          ),
          _OpcaoAdmin(
            titulo: 'Ajuda e suporte',
            icone: LucideIcons.circleQuestionMark,
            onTap: () => _mostrarAjuda(context),
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