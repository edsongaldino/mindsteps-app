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
    final darkBackground = const Color(0xFF0D1B2A);
    final cardColor = const Color(0xFF1B263B);
    final neonAccent = const Color(0xFF00E5FF);

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: darkBackground,
        colorScheme: ColorScheme.dark(
          primary: neonAccent,
          surface: cardColor,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: darkBackground,
          title: const Text('MEMÓRIA TÁTICA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.5)),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: _buildConteudo(cardColor, neonAccent),
                ),
              ),
              _buildBottomButton(neonAccent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConteudo(Color cardColor, Color neonAccent) {
    switch (etapa) {
      case 0:
        return _buildIntro(cardColor, neonAccent);
      case 1:
        return _buildMemorizacao(cardColor, neonAccent);
      case 2:
        return _buildIdentificar(cardColor, neonAccent);
      case 3:
        return _buildResultado(cardColor, neonAccent);
      default:
        return Container();
    }
  }

  Widget _buildIntro(Color cardColor, Color neonAccent) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blueAccent),
          ),
          child: const Text(
            'MEMÓRIA OPERACIONAL',
            style: TextStyle(color: Colors.blueAccent, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
        ),
        const SizedBox(height: 32),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: neonAccent.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(LucideIcons.eye, size: 48, color: neonAccent),
              const SizedBox(height: 18),
              const Text(
                'Como jogar:',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                '1. Memorize a grade de arquivos por alguns segundos.\n'
                '2. Um dos arquivos irá sumir da grade e aparecerá como "?".\n'
                '3. Indique qual foi o arquivo removido.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        const Text(
          'Treine sua memória de trabalho visual.',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildMemorizacao(Color cardColor, Color neonAccent) {
    return Column(
      children: [
        const Text(
          'MEMORIZE OS ARQUIVOS',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        const SizedBox(height: 6),
        Text(
          'Preste muita atenção. Sumindo em ${segundosRestantes}s...',
          style: TextStyle(color: neonAccent, fontSize: 14, fontWeight: FontWeight.bold),
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
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item['icone'] as IconData, size: 36, color: Colors.orangeAccent),
                  const SizedBox(height: 12),
                  Text(
                    item['nome'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildIdentificar(Color cardColor, Color neonAccent) {
    return Column(
      children: [
        const Text(
          'QUAL ARQUIVO SUMIU?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        const SizedBox(height: 6),
        const Text(
          'Selecione a opção correta abaixo.',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 32),
        // Grid showing one item replaced by ?
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
                border: Border.all(color: sumiu ? neonAccent : Colors.white12, width: sumiu ? 2 : 1),
                boxShadow: sumiu
                    ? [BoxShadow(color: neonAccent.withOpacity(0.15), blurRadius: 10)]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(sumiu ? LucideIcons.circleQuestionMark : item['icone'] as IconData, size: 36, color: sumiu ? neonAccent : Colors.orangeAccent),
                  const SizedBox(height: 12),
                  Text(
                    sumiu ? '?' : item['nome'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: sumiu ? neonAccent : Colors.white,
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
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
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
                  color: selecionado ? neonAccent.withOpacity(0.2) : cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: selecionado ? neonAccent : Colors.white24, width: selecionado ? 2 : 1),
                ),
                child: Text(
                  item['nome'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: selecionado ? Colors.white : Colors.white70,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildResultado(Color cardColor, Color neonAccent) {
    final acerto = arquivoSelecionado == arquivoSumido;
    return Column(
      children: [
        const SizedBox(height: 40),
        Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: acerto ? Colors.teal.withOpacity(0.15) : Colors.red.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: acerto ? Colors.teal : Colors.red, width: 2),
            ),
            child: Icon(
              acerto ? LucideIcons.check : LucideIcons.x,
              color: acerto ? Colors.tealAccent : Colors.redAccent,
              size: 56,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          acerto ? 'Acurácia: 100%' : 'Mais atenção na próxima!',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            acerto
                ? 'Excelente! Você registrou o sumiço do arquivo "$arquivoSumido" perfeitamente na sua memória.'
                : 'O arquivo que sumiu era o "$arquivoSumido", mas você selecionou "$arquivoSelecionado". Tente se concentrar nos detalhes visuais da próxima vez.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.4),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton(Color neonAccent) {
    if (etapa == 3) {
      return Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: neonAccent,
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
            backgroundColor: neonAccent,
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
          backgroundColor: neonAccent,
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
