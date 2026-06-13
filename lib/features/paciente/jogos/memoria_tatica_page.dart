import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../services/paciente_service.dart';

class MemoriaTaticaPage extends StatefulWidget {
  final String? atividadePacienteId;
  const MemoriaTaticaPage({super.key, this.atividadePacienteId});

  @override
  State<MemoriaTaticaPage> createState() => _MemoriaTaticaPageState();
}

class _MemoriaTaticaPageState extends State<MemoriaTaticaPage> {
  final service = PacienteService();
  bool salvando = false;
  int etapa = 0; // 0: Intro, 1: Memorizar, 2: Identificar, 3: Resultado

  final List<Map<String, dynamic>> arquivos = [
    {"nome": "Contratos", "icone": LucideIcons.fileText},
    {"nome": "Fotos", "icone": LucideIcons.image},
    {"nome": "Vídeos", "icone": LucideIcons.video},
    {"nome": "Mensagens", "icone": LucideIcons.messageSquare},
    {"nome": "Backup", "icone": LucideIcons.database},
    {"nome": "Finanças", "icone": LucideIcons.banknote},
  ];

  List<Map<String, dynamic>> itensAtivos = [];
  String? arquivoSumido;
  String? arquivoSelecionado;
  int segundosRestantes = 3;
  Timer? timerMemorizacao;

  @override
  void dispose() {
    timerMemorizacao?.cancel();
    super.dispose();
  }

  void iniciarJogo() {
    final random = Random();
    // Selecionar 4 arquivos aleatórios
    final listaCopiada = List<Map<String, dynamic>>.from(arquivos)..shuffle(random);
    final selecionados = listaCopiada.take(4).toList();

    // Escolher qual vai sumir
    final indexSumido = random.nextInt(selecionados.length);
    arquivoSumido = selecionados[indexSumido]['nome'] as String;

    setState(() {
      etapa = 1;
      itensAtivos = selecionados;
      segundosRestantes = 4;
      arquivoSelecionado = null;
    });

    timerMemorizacao = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (segundosRestantes > 1) {
          segundosRestantes--;
        } else {
          timer.cancel();
          etapa = 2; // Identificar
        }
      });
    });
  }

  void responder(String nome) {
    if (arquivoSelecionado != null) return;
    setState(() {
      arquivoSelecionado = nome;
    });
  }

  Future<void> finalizarJogo() async {
    if (arquivoSelecionado == null) return;
    setState(() => salvando = true);
    final acerto = arquivoSelecionado == arquivoSumido;

    try {
      await service.registrarJogo(
        jogoId: 'memoria_tatica',
        dadosPlay: {
          'acerto': acerto,
          'arquivo_esperado': arquivoSumido!,
          'arquivo_respondido': arquivoSelecionado!,
          'itens_mostrados': itensAtivos.map((e) => e['nome']).join(','),
        },
        atividadePacienteId: widget.atividadePacienteId,
      );

      if (!mounted) return;
      setState(() {
        etapa = 3;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = AppColors.background;
    final cardColor = Colors.white;
    final accentColor = AppColors.secondary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: const Text(
          'MEMÓRIA TÁTICA',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.text,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _buildConteudo(cardColor, accentColor),
              ),
            ),
            _buildBottomButton(accentColor),
          ],
        ),
      ),
    );
  }

  Widget _buildConteudo(Color cardColor, Color accentColor) {
    switch (etapa) {
      case 0:
        return _buildIntro(cardColor, accentColor);
      case 1:
        return _buildMemorizacao(cardColor, accentColor);
      case 2:
        return _buildIdentificar(cardColor, accentColor);
      case 3:
        return _buildResultado(cardColor, accentColor);
      default:
        return Container();
    }
  }

  Widget _buildIntro(Color cardColor, Color accentColor) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.softBlue,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: const Text(
            'MEMÓRIA OPERACIONAL',
            style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
        ),
        const SizedBox(height: 32),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 16,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Column(
            children: [
              Icon(LucideIcons.eye, size: 48, color: accentColor),
              const SizedBox(height: 18),
              const Text(
                'Como jogar:',
                style: TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                '1. Memorize a grade de arquivos por alguns segundos.\n'
                '2. Um dos arquivos irá sumir da grade e aparecerá como "?".\n'
                '3. Indique qual foi o arquivo removido.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textLight, fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        const Text(
          'Treine sua memória de trabalho visual.',
          style: TextStyle(color: AppColors.muted, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildMemorizacao(Color cardColor, Color accentColor) {
    return Column(
      children: [
        const Text(
          'MEMORIZE OS ARQUIVOS',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text, letterSpacing: 1.2),
        ),
        const SizedBox(height: 6),
        Text(
          'Preste muita atenção. Sumindo em ${segundosRestantes}s...',
          style: TextStyle(color: accentColor, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 40),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: itensAtivos.map((item) {
            return Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.015),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item['icone'] as IconData, size: 36, color: AppColors.primary),
                  const SizedBox(height: 12),
                  Text(
                    item['nome'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.text),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildIdentificar(Color cardColor, Color accentColor) {
    return Column(
      children: [
        const Text(
          'QUAL ARQUIVO SUMIU?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text, letterSpacing: 1.2),
        ),
        const SizedBox(height: 6),
        const Text(
          'Selecione a opção correta abaixo.',
          style: TextStyle(color: AppColors.textLight, fontSize: 14),
        ),
        const SizedBox(height: 32),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: itensAtivos.map((item) {
            final sumiu = item['nome'] == arquivoSumido;
            return Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: sumiu ? accentColor : AppColors.border, 
                  width: sumiu ? 2 : 1
                ),
                boxShadow: [
                  BoxShadow(
                    color: sumiu ? accentColor.withOpacity(0.08) : Colors.black.withOpacity(0.01),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    sumiu ? LucideIcons.circleQuestionMark : item['icone'] as IconData, 
                    size: 36, 
                    color: sumiu ? accentColor : AppColors.primary
                  ),
                  const SizedBox(height: 12),
                  Text(
                    sumiu ? '?' : item['nome'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: sumiu ? accentColor : AppColors.text,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 40),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Escolha a sua resposta:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textLight),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: arquivos.map((item) {
            final selecionado = arquivoSelecionado == item['nome'];
            return GestureDetector(
              onTap: () => responder(item['nome'] as String),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: selecionado ? accentColor.withOpacity(0.12) : cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selecionado ? accentColor : AppColors.border, 
                    width: selecionado ? 2 : 1
                  ),
                ),
                child: Text(
                  item['nome'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: selecionado ? accentColor : AppColors.text,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildResultado(Color cardColor, Color accentColor) {
    final acerto = arquivoSelecionado == arquivoSumido;
    return Column(
      children: [
        const SizedBox(height: 40),
        Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: acerto ? AppColors.success.withOpacity(0.12) : AppColors.danger.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: acerto ? AppColors.success : AppColors.danger, width: 2),
            ),
            child: Icon(
              acerto ? LucideIcons.check : LucideIcons.x,
              color: acerto ? AppColors.success : AppColors.danger,
              size: 56,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          acerto ? 'Acurácia: 100%' : 'Mais atenção na próxima!',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.text),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            acerto
                ? 'Excelente! Você registrou o sumiço do arquivo "$arquivoSumido" perfeitamente na sua memória.'
                : 'O arquivo que sumiu era o "$arquivoSumido", mas você selecionou "$arquivoSelecionado". Tente se concentrar nos detalhes visuais da próxima vez.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textLight, fontSize: 14, height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton(Color accentColor) {
    if (etapa == 3) {
      return Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('Concluir Atividade', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      );
    }

    if (etapa == 0) {
      return Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: ElevatedButton(
          onPressed: iniciarJogo,
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('Entrar no Servidor', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      );
    }

    if (etapa == 1) {
      return Container();
    }

    // Etapa 2: Responder
    final podeEnviar = arquivoSelecionado != null;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: ElevatedButton(
        onPressed: (podeEnviar && !salvando) ? finalizarJogo : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: salvando
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Enviar Resposta', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
