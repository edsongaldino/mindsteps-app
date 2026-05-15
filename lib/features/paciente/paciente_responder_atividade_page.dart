import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import 'services/paciente_service.dart';

class PacienteResponderAtividadePage extends StatefulWidget {
  final String atividadePacienteId;
  final String titulo;
  final String descricao;

  const PacienteResponderAtividadePage({
    super.key,
    required this.atividadePacienteId,
    required this.titulo,
    required this.descricao,
  });

  @override
  State<PacienteResponderAtividadePage> createState() =>
      _PacienteResponderAtividadePageState();
}

class _PacienteResponderAtividadePageState
    extends State<PacienteResponderAtividadePage> {
  final respostaController = TextEditingController();
  final service = PacienteService();

  bool salvando = false;
  int notaHumor = 5;

  @override
  void dispose() {
    respostaController.dispose();
    super.dispose();
  }

  Future<void> salvar() async {
    if (respostaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escreva sua resposta antes de enviar.')),
      );
      return;
    }

    try {
      setState(() => salvando = true);

      await service.responderAtividade(
        atividadePacienteId: widget.atividadePacienteId,
        respostaTexto: respostaController.text.trim(),
        notaHumor: notaHumor,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Atividade enviada com sucesso.')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar atividade: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => salvando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text('1 de 1', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Descreva a situação',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Conte sobre o que aconteceu.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: respostaController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Ex: Tive uma reunião importante e fiquei muito ansioso...',
                      hintStyle: const TextStyle(color: AppColors.muted),
                      alignLabelWithHint: true,
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Como você se sentiu?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Intensidade da emoção',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SliderHumor(
                    valor: notaHumor,
                    onChanged: (valor) {
                      setState(() => notaHumor = valor);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
          ],
        ),
        child: ElevatedButton(
          onPressed: salvando ? null : salvar,
          child: salvando
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white))
              : const Text('Salvar e continuar'),
        ),
      ),
    );
  }
}

class _CardAtividade extends StatelessWidget {
  final String titulo;
  final String descricao;

  const _CardAtividade({
    required this.titulo,
    required this.descricao,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            LucideIcons.clipboardList,
            color: AppColors.primary,
            size: 30,
          ),
          const SizedBox(height: 14),
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            descricao,
            style: const TextStyle(
              color: AppColors.muted,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SliderHumor extends StatelessWidget {
  final int valor;
  final ValueChanged<int> onChanged;

  const _SliderHumor({
    required this.valor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons.frown,
                color: AppColors.muted,
              ),
              Expanded(
                child: Slider(
                  value: valor.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: valor.toString(),
                  onChanged: (value) => onChanged(value.round()),
                ),
              ),
              const Icon(
                LucideIcons.smile,
                color: AppColors.primary,
              ),
            ],
          ),
          Text(
            'Nota do humor: $valor/10',
            style: const TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}