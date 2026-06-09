import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../services/paciente_service.dart';

class LaboratorioMentalPage extends StatefulWidget {
  final String? atividadePacienteId;
  const LaboratorioMentalPage({super.key, this.atividadePacienteId});

  @override
  State<LaboratorioMentalPage> createState() => _LaboratorioMentalPageState();
}

class _LaboratorioMentalPageState extends State<LaboratorioMentalPage> {
  final service = PacienteService();
  bool salvando = false;
  int etapa = 0; // 0: Intro, 1: Palavra GATO->PATO, 2: Palavra PATO->MATO, 3: Sucesso

  // Fase 1: Formar PATO (Temos as letras A, O, P, T no grid, o usuário precisa ordenar como P A T O)
  // Fase 2: Formar MATO (Temos as letras A, M, T, O no grid, ordenar como M A T O)
  List<String> letrasDisponiveis = [];
  List<String> letrasUsuario = [];
  int acertos = 0;

  void iniciarFase1() {
    setState(() {
      etapa = 1;
      letrasDisponiveis = ["A", "O", "P", "T"];
      letrasUsuario = [];
    });
  }

  void iniciarFase2() {
    setState(() {
      etapa = 2;
      letrasDisponiveis = ["A", "M", "T", "O"];
      letrasUsuario = [];
    });
  }

  void adicionarLetra(String letra) {
    if (letrasUsuario.contains(letra)) return;
    setState(() {
      letrasUsuario.add(letra);
    });
  }

  void removerLetra(String letra) {
    setState(() {
      letrasUsuario.remove(letra);
    });
  }

  void limparLetras() {
    setState(() {
      letrasUsuario.clear();
    });
  }

  void verificarResposta() {
    final palavraFormada = letrasUsuario.join();
    if (etapa == 1) {
      if (palavraFormada == "PATO") {
        acertos++;
        iniciarFase2();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Palavra incorreta. Tente formar PATO.')),
        );
        limparLetras();
      }
    } else if (etapa == 2) {
      if (palavraFormada == "MATO") {
        acertos++;
        finalizarJogo();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Palavra incorreta. Tente formar MATO.')),
        );
        limparLetras();
      }
    }
  }

  Future<void> finalizarJogo() async {
    setState(() => salvando = true);
    try {
      await service.registrarJogo(
        jogoId: 'laboratorio_mental',
        dadosPlay: {
          'acertos': acertos,
          'fases_concluidas': 2,
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
          title: const Text('LABORATÓRIO MENTAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.5)),
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
        return _buildGameplay("GATO", "PATO", cardColor, neonAccent);
      case 2:
        return _buildGameplay("PATO", "MATO", cardColor, neonAccent);
      case 3:
        return _buildSucesso(cardColor, neonAccent);
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
            color: Colors.green.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green),
          ),
          child: const Text(
            'FLEXIBILIDADE COGNITIVA',
            style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
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
              Icon(LucideIcons.puzzle, size: 48, color: neonAccent),
              const SizedBox(height: 18),
              const Text(
                'Como jogar:',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Troque uma letra por vez para formar novas palavras do laboratório.\n\n'
                'Exemplo: GATO ➔ PATO ➔ MATO.\n'
                'Toque nas letras embaralhadas na ordem correta para soletrar a nova palavra.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        const Text(
          'Treine flexibilidade cognitiva e criatividade verbal.',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildGameplay(String dePalavra, String paraPalavra, Color cardColor, Color neonAccent) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dePalavra,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey, decoration: TextDecoration.lineThrough),
            ),
            const SizedBox(width: 20),
            const Icon(LucideIcons.arrowRight, color: Colors.grey),
            const SizedBox(width: 20),
            Text(
              paraPalavra,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: neonAccent),
            ),
          ],
        ),
        const SizedBox(height: 48),
        // Empty slots for current typing
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(paraPalavra.length, (index) {
            final temLetra = index < letrasUsuario.length;
            final letra = temLetra ? letrasUsuario[index] : "";
            return GestureDetector(
              onTap: temLetra ? () => removerLetra(letra) : null,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: temLetra ? neonAccent : Colors.white24, width: temLetra ? 2 : 1),
                ),
                child: Center(
                  child: Text(
                    letra,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: temLetra ? Colors.white : Colors.grey),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 48),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('Letras disponíveis:', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 12),
        // Available letters selection
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: letrasDisponiveis.map((letra) {
            final jaUsada = letrasUsuario.contains(letra);
            return GestureDetector(
              onTap: jaUsada ? null : () => adicionarLetra(letra),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: jaUsada ? Colors.white10 : cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: jaUsada ? Colors.transparent : Colors.white24),
                ),
                child: Center(
                  child: Text(
                    letra,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: jaUsada ? Colors.white24 : Colors.white,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSucesso(Color cardColor, Color neonAccent) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: neonAccent.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: neonAccent, width: 2),
            ),
            child: Icon(
              LucideIcons.award,
              color: neonAccent,
              size: 56,
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Laboratório Concluído!',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Incrível! Você reestruturou as conexões de letras rapidamente. '
            'Exercitar a flexibilidade cognitiva verbal ajuda a encontrar soluções alternativas diante de problemas cotidianos bloqueados.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.4),
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
          onPressed: iniciarFase1,
          style: ElevatedButton.styleFrom(
            backgroundColor: neonAccent,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('Iniciar Laboratório', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      );
    }

    // Gameplay phases: verify button
    final pronto = letrasUsuario.length == letrasDisponiveis.length;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: limparLetras,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Limpar'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: pronto ? verificarResposta : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: neonAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Confirmar', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
