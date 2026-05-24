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

  void _mostrarConfiguracoes(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Configurações',
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
                                  'Configurações do Aplicativo',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Gerencie notificações, preferências de temas, idiomas e outros ajustes do sistema clínico aqui. Algumas opções podem estar restritas conforme seu perfil.',
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

  void _mostrarAjudaSuporte(BuildContext context) {
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
                                  'Suporte Técnico & Clínico',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Se precisar de suporte com a moderação de pacientes, atribuição de atividades cognitivas ou problemas de instabilidade na plataforma, contate-nos:',
                                  style: TextStyle(fontSize: 14, color: AppColors.muted, height: 1.5),
                                ),
                                SizedBox(height: 20),
                                Row(
                                  children: [
                                    Icon(LucideIcons.mail, color: AppColors.primary, size: 18),
                                    SizedBox(width: 8),
                                    Text('suporte.clinico@mindsteps.com.br', style: TextStyle(fontSize: 14, color: AppColors.text)),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(LucideIcons.phone, color: AppColors.primary, size: 18),
                                    SizedBox(width: 8),
                                    Text('(11) 98765-4321', style: TextStyle(fontSize: 14, color: AppColors.text)),
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
            onTap: () => _mostrarConfiguracoes(context),
          ),
          _OpcaoMais(
            titulo: 'Ajuda e suporte',
            icone: LucideIcons.circleQuestionMark,
            onTap: () => _mostrarAjudaSuporte(context),
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