import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import 'services/paciente_service.dart';

class PacienteRegistroPensamentoPage extends StatefulWidget {
  const PacienteRegistroPensamentoPage({super.key});

  @override
  State<PacienteRegistroPensamentoPage> createState() =>
      _PacienteRegistroPensamentoPageState();
}

class _PacienteRegistroPensamentoPageState
    extends State<PacienteRegistroPensamentoPage> {
  final service = PacienteService();
  final formKey = GlobalKey<FormState>();

  final situacaoController = TextEditingController();
  final pensamentoController = TextEditingController();
  final emocaoController = TextEditingController();
  double intensidadeEmocao = 5;

  final evidenciasAFavorController = TextEditingController();
  final evidenciasContraController = TextEditingController();
  final pensamentoAlternativoController = TextEditingController();
  double intensidadeFinal = 5;

  bool carregando = false;

  Future<void> _salvar() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => carregando = true);

    try {
      await service.criarRegistroPensamento(
        situacao: situacaoController.text,
        pensamentoAutomatico: pensamentoController.text,
        emocao: emocaoController.text,
        intensidadeEmocao: intensidadeEmocao.toInt(),
        evidenciasAFavor: evidenciasAFavorController.text,
        evidenciasContra: evidenciasContraController.text,
        pensamentoAlternativo: pensamentoAlternativoController.text,
        intensidadeFinal: intensidadeFinal.toInt(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro salvo com sucesso!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Registro de Pensamento'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'O que aconteceu?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 16),
              _CampoTexto(
                label: 'Situação',
                hint: 'Ex: Estava no trabalho e meu chefe me chamou...',
                controller: situacaoController,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _CampoTexto(
                label: 'Pensamento Automático',
                hint: 'O que passou pela sua cabeça?',
                controller: pensamentoController,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _CampoTexto(
                label: 'Emoção',
                hint: 'Ex: Ansiedade, Tristeza, Raiva...',
                controller: emocaoController,
              ),
              const SizedBox(height: 16),
              Text(
                'Intensidade da emoção (0-10): ${intensidadeEmocao.toInt()}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Slider(
                value: intensidadeEmocao,
                min: 0,
                max: 10,
                divisions: 10,
                onChanged: (v) => setState(() => intensidadeEmocao = v),
              ),
              const Divider(height: 40),
              const Text(
                'Desafiando o pensamento',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 16),
              _CampoTexto(
                label: 'Evidências a favor',
                hint: 'O que confirma esse pensamento?',
                controller: evidenciasAFavorController,
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              _CampoTexto(
                label: 'Evidências contra',
                hint: 'O que contradiz esse pensamento?',
                controller: evidenciasContraController,
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              _CampoTexto(
                label: 'Pensamento Alternativo',
                hint: 'Uma forma mais equilibrada de ver a situação',
                controller: pensamentoAlternativoController,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Text(
                'Intensidade final (0-10): ${intensidadeFinal.toInt()}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Slider(
                value: intensidadeFinal,
                min: 0,
                max: 10,
                divisions: 10,
                onChanged: (v) => setState(() => intensidadeFinal = v),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: carregando ? null : _salvar,
                  child: carregando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Salvar Registro'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _CampoTexto extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final int maxLines;

  const _CampoTexto({
    required this.label,
    required this.hint,
    required this.controller,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
          ),
          validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
        ),
      ],
    );
  }
}
