import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import 'admin_configuracoes_page.dart';
import 'admin_dashboard_page.dart';
import 'admin_perfil_page.dart';
import 'admin_psicologos_page.dart';
import 'admin_usuarios_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int paginaAtual = 0;

  final usuariosKey = GlobalKey<AdminUsuariosPageState>();
  final psicologosKey = GlobalKey<AdminPsicologosPageState>();

  late final List<Widget> paginas;

  @override
  void initState() {
    super.initState();
    paginas = [
      const AdminDashboardPage(),
      AdminUsuariosPage(key: usuariosKey),
      const AdminPerfilPage(),
      AdminPsicologosPage(key: psicologosKey),
      const AdminConfiguracoesPage(),
    ];
  }

  void _onFabPressed() {
    if (paginaAtual == 1) {
      usuariosKey.currentState?.exibirDialogoCriar(context);
    } else if (paginaAtual == 3) {
      psicologosKey.currentState?.exibirDialogoCriar(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool temFab = paginaAtual == 1 || paginaAtual == 3;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: IndexedStack(
          index: paginaAtual,
          children: paginas,
        ),
      ),
      floatingActionButton: temFab
          ? FloatingActionButton(
              onPressed: _onFabPressed,
              backgroundColor: AppColors.secondary,
              elevation: 4,
              shape: const CircleBorder(),
              child: const Icon(LucideIcons.plus, color: Colors.white, size: 28),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: paginaAtual,
          onTap: (index) {
            setState(() => paginaAtual = index);
          },
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.muted,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          elevation: 20,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(LucideIcons.house, size: 24),
              label: 'Início',
            ),
            const BottomNavigationBarItem(
              icon: Icon(LucideIcons.users, size: 24),
              label: 'Usuários',
            ),
            BottomNavigationBarItem(
              icon: temFab
                  ? const Icon(Icons.circle, color: Colors.transparent)
                  : const Icon(LucideIcons.user, size: 24),
              label: temFab ? '' : 'Perfil',
            ),
            const BottomNavigationBarItem(
              icon: Icon(LucideIcons.brain, size: 24),
              label: 'Psicólogos',
            ),
            const BottomNavigationBarItem(
              icon: Icon(LucideIcons.settings, size: 24),
              label: 'Mais',
            ),
          ],
        ),
      ),
    );
  }
}