import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/auth/auth_storage.dart';
import '../../core/theme/app_theme.dart';
import '../auth/login_page.dart';
import 'services/paciente_service.dart';

class PacientePerfilPage extends StatefulWidget {
  const PacientePerfilPage({super.key});

  @override
  State<PacientePerfilPage> createState() => _PacientePerfilPageState();
}

class _PacientePerfilPageState extends State<PacientePerfilPage> {
  final service = PacienteService();

  late Future<Map<String, dynamic>> meFuture;

  @override
  void initState() {
    super.initState();
    meFuture = service.obterMe();
  }

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
    return FutureBuilder<Map<String, dynamic>>(
      future: meFuture,
      builder: (context, snapshot) {
        final me = snapshot.data ?? {};
        final nome = me['nome'] ?? 'Paciente';
        final email = me['email'] ?? '';

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Meu perfil',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 22),
              _CardPerfil(nome: nome, email: email),
              const SizedBox(height: 20),
              const _OpcaoPerfil(
                titulo: 'Meus dados',
                icone: LucideIcons.user,
              ),
              const _OpcaoPerfil(
                titulo: 'Privacidade',
                icone: LucideIcons.lock,
              ),
              const _OpcaoPerfil(
                titulo: 'Ajuda',
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
      },
    );
  }
}

class _CardPerfil extends StatelessWidget {
  final String nome;
  final String email;

  const _CardPerfil({
    required this.nome,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final inicial = nome.isNotEmpty ? nome.substring(0, 1) : '?';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: AppColors.softGreen,
            child: Text(
              inicial,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            nome,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _OpcaoPerfil extends StatelessWidget {
  final String titulo;
  final IconData icone;

  const _OpcaoPerfil({
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