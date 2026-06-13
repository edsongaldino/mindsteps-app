import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../services/paciente_service.dart';

class MenteFlexivelPage extends StatefulWidget {
  final String? atividadePacienteId;
  const MenteFlexivelPage({super.key, this.atividadePacienteId});

  @override
  State<MenteFlexivelPage> createState() => _MenteFlexivelPageState();
}

class _MenteFlexivelPageState extends State<MenteFlexivelPage> {
  final service = PacienteService();
  bool salvando = false;
  int etapa = 0; // 0: Intro, 1: Fase 1 (Objetos Azuis), 2: Fase 2 (Objetos Grandes), 3: Fase 3 (Mais de 3 Lados), 4: Sucesso

  List<String> selecionados = [];
  int acertosFases = 0;

  // Fase 1: Objetos azuis
  final itensFase1 = [
    {"item": "🚙", "nome": "Carro Azul", "valido": true},
    {"item": "👕", "nome": "Camisa Azul", "valido": true},
    {"item": "🍎", "nome": "Maçã", "valido": false},
    {"item": "🚗", "nome": "Carro Vermelho", "valido": false},
    {"item": "🍌", "nome": "Banana", "valido": false},
    {"item": "🌲", "nome": "Árvore", "valido": false},
  ];

  // Fase 2: Objetos grandes
  final itensFase2 = [
    {"item": "🏠", "nome": "Casa", "valido": true},
    {"item": "🏢", "nome": "Prédio", "valido": true},
    {"item": "🚢", "nome": "Navio", "valido": true},
    {"item": "🐜", "nome": "Formiga", "valido": false},
    {"item": "🔑", "nome": "Chave", "valido": false},
    {"item": "🍓", "nome": "Morango", "valido": false},
  ];

  // Fase 3: Mais de 3 lados (Ignore a cor!)
  final itensFase3 = [
    {"item": "🟦", "nome": "Quadrado Azul", "valido": true},
    {"item": "🟪", "nome": "Quadrado Roxo", "valido": true},
    {"item": "⭐", "nome": "Estrela (>3 lados/pontas)", "valido": true},
    {"item": "🔺", "nome": "Triângulo", "valido": false},
    {"item": "🟡", "nome": "Círculo", "valido": false},
    {"item": "🟢", "nome": "Círculo Verde", "valido": false},
  ];

  void toggleItem(String item) {
    setState(() {
      if (selecionados.contains(item)) {
        selecionados.remove(item);
      } else {
        selecionados.add(item);
      }
    });
  }

  void avancarFase() {
    bool correto = false;
    if (etapa == 1) {
      final corretos = itensFase1.where((x) => x['valido'] as bool).map((x) => x['item'] as String).toList();
      correto = selecionados.length == corretos.length && selecionados.every((x) => corretos.contains(x));
      if (correto) acertosFases++;
      setState(() {
        etapa = 2;
        selecionados.clear();
      });
    } else if (etapa == 2) {
      final corretos = itensFase2.where((x) => x['valido'] as bool).map((x) => x['item'] as String).toList();
      correto = selecionados.length == corretos.length && selecionados.every((x) => corretos.contains(x));
      if (correto) acertosFases++;
      setState(() {
        etapa = 3;
        selecionados.clear();
      });
    } else if (etapa == 3) {
      final corretos = itensFase3.where((x) => x['valido'] as bool).map((x) => x['item'] as String).toList();
      correto = selecionados.length == corretos.length && selecionados.every((x) => corretos.contains(x));
      if (correto) acertosFases++;
      finalizarJogo();
    }
  }

  Future<void> finalizarJogo() async {
    setState(() => salvando = true);
    try {
      await service.registrarJogo(
        jogoId: 'mente_flexivel',
        dadosPlay: {
          'total_fases': 3,
          'acertos_fases': acertosFases,
          'pontuacao': acertosFases * 200,
        },
        atividadePacienteId: widget.atividadePacienteId,
      );

      if (!mounted) return;
      setState(() {
        etapa = 4;
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
          'MENTE FLEXÍVEL',
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
        return _buildGameplay("REGRA ATUAL", "Clique apenas nos objetos azuis. 🚙", itensFase1, cardColor, accentColor);
      case 2:
        return _buildGameplay("NOVA REGRA", "Agora clique apenas nos objetos grandes. 🏢", itensFase2, cardColor, accentColor);
      case 3:
        return _buildGameplay("NOVA REGRA", "Agora ignore a cor. Clique apenas nos que têm mais de 3 lados. 🟦", itensFase3, cardColor, accentColor);
      case 4:
        return _buildSucesso(cardColor, accentColor);
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
            color: AppColors.softGreen,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
          ),
          child: const Text(
            'FLEXIBILIDADE COGNITIVA',
            style: TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
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
              Icon(LucideIcons.gitFork, size: 48, color: accentColor),
              const SizedBox(height: 18),
              const Text(
                'Como jogar:',
                style: TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'As regras mudam sem aviso prévio!\n\n'
                'Você terá que se adaptar rapidamente e selecionar os elementos de acordo com a regra da vez. '
                'Fique atento às instruções no topo!',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textLight, fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        const Text(
          'Treine alternância de estratégias de atenção.',
          style: TextStyle(color: AppColors.muted, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildGameplay(String tagRegra, String regraTexto, List<Map<String, dynamic>> itens, Color cardColor, Color accentColor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.softOrange,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            tagRegra,
            style: const TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          regraTexto,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text),
        ),
        const SizedBox(height: 32),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.0,
          ),
          itemCount: itens.length,
          itemBuilder: (context, index) {
            final itemMap = itens[index];
            final item = itemMap['item'] as String;
            final selecionado = selecionados.contains(item);

            return GestureDetector(
              onTap: () => toggleItem(item),
              child: Container(
                decoration: BoxDecoration(
                  color: selecionado ? accentColor.withOpacity(0.12) : cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selecionado ? accentColor : AppColors.border, 
                    width: selecionado ? 2.5 : 1
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.01),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: Center(
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSucesso(Color cardColor, Color accentColor) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: accentColor, width: 2),
            ),
            child: Icon(
              LucideIcons.repeat,
              color: accentColor,
              size: 56,
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Mente Altamente Flexível!',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.text),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Incrível! Você conseguiu concluir $acertosFases de 3 fases de regras trocadas. '
            'Adaptar-se a novas regras impede o cérebro de entrar no automatismo rígido disfuncional.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textLight, fontSize: 14, height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton(Color accentColor) {
    if (etapa == 4) {
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
          onPressed: () => setState(() => etapa = 1),
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('Entrar no Desafio', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      );
    }

    final temSelecoes = selecionados.isNotEmpty;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: ElevatedButton(
        onPressed: (temSelecoes && !salvando) ? avancarFase : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: salvando
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Confirmar Seleções', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
