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
  String emocaoPrincipal = 'Calma';
  bool salvando = false;
  bool jaFezHoje = false;
  bool carregandoStatus = true;

  final emocoes = ['Ansiedade', 'Tristeza', 'Alegria', 'Raiva', 'Calma', 'Medo', 'Outra'];

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
        intensidade: 5, // Default pois não tem no mockup 09
        emocaoPrincipal: emocaoPrincipal,
        observacao: observacaoController.text.trim().isEmpty
            ? null
            : observacaoController.text.trim(),
      );

      if (!mounted) return;

      observacaoController.clear();

      setState(() {
        humor = 3;
        emocaoPrincipal = 'Calma';
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Check-in de hoje',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Como você está se sentindo?',
                      style: TextStyle(color: AppColors.muted, fontSize: 16),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _EmojiButton(
                          icone: LucideIcons.frown,
                          corFundo: const Color(0xFFFFE5E5),
                          corIcone: AppColors.danger,
                          selecionado: humor == 1,
                          onTap: () => setState(() => humor = 1),
                        ),
                        _EmojiButton(
                          icone: LucideIcons.meh,
                          corFundo: const Color(0xFFFFF2E5),
                          corIcone: AppColors.warning,
                          selecionado: humor == 2,
                          onTap: () => setState(() => humor = 2),
                        ),
                        _EmojiButton(
                          icone: LucideIcons.smile,
                          corFundo: const Color(0xFFE5F0FF),
                          corIcone: Colors.blue,
                          selecionado: humor == 3,
                          onTap: () => setState(() => humor = 3),
                        ),
                        _EmojiButton(
                          icone: LucideIcons.laugh,
                          corFundo: const Color(0xFFE5FFE5),
                          corIcone: AppColors.success,
                          selecionado: humor == 4,
                          onTap: () => setState(() => humor = 4),
                        ),
                        _EmojiButton(
                          icone: LucideIcons.heart,
                          corFundo: const Color(0xFFFFE5F2),
                          corIcone: Colors.pink,
                          selecionado: humor == 5,
                          onTap: () => setState(() => humor = 5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Qual emoção principal?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: emocoes.map((emocao) {
                        return _TagEmocao(
                          texto: emocao,
                          selecionada: emocaoPrincipal == emocao,
                          onTap: () => setState(() => emocaoPrincipal = emocao),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Quer adicionar alguma anotação? (Opcional)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: observacaoController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Escreva aqui...',
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
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: salvando ? null : salvarCheckin,
                child: salvando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : const Text('Salvar Check-in'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmojiButton extends StatelessWidget {
  final IconData icone;
  final Color corFundo;
  final Color corIcone;
  final bool selecionado;
  final VoidCallback onTap;

  const _EmojiButton({
    required this.icone,
    required this.corFundo,
    required this.corIcone,
    required this.selecionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: corFundo,
          shape: BoxShape.circle,
          border: Border.all(
            color: selecionado ? corIcone : Colors.transparent,
            width: selecionado ? 3 : 0,
          ),
          boxShadow: selecionado
              ? [
                  BoxShadow(
                    color: corIcone.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Icon(
          icone,
          color: corIcone,
          size: selecionado ? 34 : 28,
        ),
      ),
    );
  }
}

class _TagEmocao extends StatelessWidget {
  final String texto;
  final bool selecionada;
  final VoidCallback onTap;

  const _TagEmocao({
    required this.texto,
    required this.selecionada,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selecionada ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selecionada ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          texto,
          style: TextStyle(
            color: selecionada ? Colors.white : AppColors.text,
            fontWeight: selecionada ? FontWeight.bold : FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}