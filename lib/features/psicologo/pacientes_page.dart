import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import 'paciente_detalhe_page.dart';
import 'services/psicologo_service.dart';

class PacientesPage extends StatefulWidget {
  const PacientesPage({super.key});

  @override
  State<PacientesPage> createState() => _PacientesPageState();
}

class _PacientesPageState extends State<PacientesPage> {
  final service = PsicologoService();

  late Future<List<dynamic>> pacientesFuture;

  @override
  void initState() {
    super.initState();
    pacientesFuture = service.listarPacientesDoPsicologo();
  }

  Future<void> _recarregar() async {
    setState(() {
      pacientesFuture = service.listarPacientesDoPsicologo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: pacientesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Text(
                'Erro ao carregar pacientes: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final pacientes = snapshot.data ?? [];

        return RefreshIndicator(
          onRefresh: _recarregar,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Meus pacientes',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 18),
                const _CampoBuscaPaciente(),
                const SizedBox(height: 18),

                if (pacientes.isEmpty)
                  const Text(
                    'Nenhum paciente encontrado.',
                    style: TextStyle(color: AppColors.muted),
                  ),

                ...pacientes.map((paciente) {
                  final usuario = paciente['usuario'];
                  final nome = usuario?['nome'] ?? paciente['nome'] ?? 'Paciente';
                  final id = paciente['id']?.toString() ?? '';

                  return _PacienteItem(
                    id: id,
                    nome: nome,
                    descricao: 'Paciente em acompanhamento',
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CampoBuscaPaciente extends StatelessWidget {
  const _CampoBuscaPaciente();

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Buscar paciente',
        prefixIcon: const Icon(LucideIcons.search, size: 20),
        suffixIcon: IconButton(
          onPressed: () {},
          icon: const Icon(LucideIcons.slidersHorizontal, size: 20),
        ),
      ),
    );
  }
}

class _PacienteItem extends StatelessWidget {
  final String id;
  final String nome;
  final String descricao;

  const _PacienteItem({
    required this.id,
    required this.nome,
    required this.descricao,
  });

  @override
  Widget build(BuildContext context) {
    final inicial = nome.isNotEmpty ? nome.substring(0, 1) : '?';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PacienteDetalhePage(
              pacienteId: id,
              nome: nome,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: AppColors.softGreen,
              child: Text(
                inicial,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nome,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    descricao,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                ],
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