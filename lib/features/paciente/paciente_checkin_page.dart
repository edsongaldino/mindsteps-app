import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import 'services/paciente_service.dart';
import 'paciente_home_page.dart';

class PacienteCheckinPage extends StatefulWidget {
  const PacienteCheckinPage({super.key});

  @override
  State<PacienteCheckinPage> createState() => _PacienteCheckinPageState();
}

class _PacienteCheckinPageState extends State<PacienteCheckinPage> {
  final observacaoController = TextEditingController();
  final service = PacienteService();

  int humor = 3;
  int intensidade = 5;
  String emocaoPrincipal = 'Calmo';
  bool salvando = false;
  bool jaFezHoje = false;
  bool carregandoStatus = true;

  @override
  void initState() {
    super.initState();
    _verificarStatus();
  }

  Future<void> _verificarStatus() async {
    try {
      final status = await service.verificarCheckinHoje();
      if (mounted) {
        setState(() {
          jaFezHoje = status;
          carregandoStatus = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => carregandoStatus = false);
      }
    }
  }

  @override
  void dispose() {
    observacaoController.dispose();
    super.dispose();
  }

  Future<void> salvarCheckin() async {
    try {
      setState(() => salvando = true);

      await service.criarCheckin(
        humor: humor,
        intensidade: intensidade,
        emocaoPrincipal: emocaoPrincipal,
        observacao: observacaoController.text.trim().isEmpty
            ? null
            : observacaoController.text.trim(),
      );

      if (!mounted) return;

      observacaoController.clear();

      setState(() {
        humor = 3;
        intensidade = 5;
        emocaoPrincipal = 'Calmo';
        jaFezHoje = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Check-in salvo com sucesso.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar check-in: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => salvando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (carregandoStatus) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (jaFezHoje) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                LucideIcons.circleCheck,
                color: AppColors.success,
                size: 84,
              ),
              const SizedBox(height: 24),
              const Text(
                'Check-in concluído!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Você já registrou como está se sentindo hoje. Continue assim!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  final state = context.findAncestorStateOfType<PacienteHomePageState>();
                  state?.setState(() => state.paginaAtual = 0);
                },
                child: const Text('Voltar para o Início'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Check-in emocional',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Registre como você está se sentindo agora.',
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 24),
          _CardHumorAtual(
            humorSelecionado: humor,
            onSelecionar: (valor, emocao) {
              setState(() {
                humor = valor;
                emocaoPrincipal = emocao;
              });
            },
          ),
          const SizedBox(height: 22),
          _CardIntensidade(
            intensidade: intensidade,
            onChanged: (valor) {
              setState(() => intensidade = valor);
            },
          ),
          const SizedBox(height: 22),
          TextField(
            controller: observacaoController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Escreva brevemente o que está passando pela sua mente...',
              alignLabelWithHint: true,
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 82),
                child: Icon(LucideIcons.penLine),
              ),
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: salvando ? null : salvarCheckin,
            icon: salvando
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(LucideIcons.save),
            label: Text(salvando ? 'Salvando...' : 'Salvar check-in'),
          ),
        ],
      ),
    );
  }
}

class _CardHumorAtual extends StatelessWidget {
  final int humorSelecionado;
  final void Function(int valor, String emocao) onSelecionar;

  const _CardHumorAtual({
    required this.humorSelecionado,
    required this.onSelecionar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Como está seu humor?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _HumorOpcao(
                icone: LucideIcons.frown,
                texto: 'Difícil',
                selecionado: humorSelecionado == 1,
                onTap: () => onSelecionar(1, 'Difícil'),
              ),
              _HumorOpcao(
                icone: LucideIcons.meh,
                texto: 'Neutro',
                selecionado: humorSelecionado == 3,
                onTap: () => onSelecionar(3, 'Neutro'),
              ),
              _HumorOpcao(
                icone: LucideIcons.smile,
                texto: 'Bem',
                selecionado: humorSelecionado == 5,
                onTap: () => onSelecionar(5, 'Calmo'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HumorOpcao extends StatelessWidget {
  final IconData icone;
  final String texto;
  final bool selecionado;
  final VoidCallback onTap;

  const _HumorOpcao({
    required this.icone,
    required this.texto,
    required this.selecionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selecionado ? AppColors.softGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selecionado ? AppColors.primary : Colors.transparent,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: selecionado ? AppColors.primary : AppColors.softGreen,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                icone,
                color: selecionado ? Colors.white : AppColors.primary,
                size: 30,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              texto,
              style: TextStyle(
                color: selecionado ? AppColors.primary : AppColors.text,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardIntensidade extends StatelessWidget {
  final int intensidade;
  final ValueChanged<int> onChanged;

  const _CardIntensidade({
    required this.intensidade,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Intensidade da emoção',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: intensidade.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            label: intensidade.toString(),
            onChanged: (value) => onChanged(value.round()),
          ),
          Center(
            child: Text(
              '$intensidade/10',
              style: const TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}