import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import 'admin_configuracoes_page.dart';
import 'admin_dashboard_page.dart';
import 'admin_metricas_page.dart';
import 'admin_psicologos_page.dart';
import 'admin_usuarios_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int paginaAtual = 0;

  final paginas = const [
    AdminDashboardPage(),
    AdminUsuariosPage(),
    AdminPsicologosPage(),
    AdminMetricasPage(),
    AdminConfiguracoesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: IndexedStack(
          index: paginaAtual,
          children: paginas,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: paginaAtual,
          onDestinationSelected: (index) {
            setState(() => paginaAtual = index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(LucideIcons.house),
              label: 'Início',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.users),
              label: 'Usuários',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.brain),
              label: 'Psicólogos',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.fileText),
              label: 'Métricas',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.settings),
              label: 'Mais',
            ),
          ],
        ),
      ),
    );
  }
}