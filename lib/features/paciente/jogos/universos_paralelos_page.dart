import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../services/paciente_service.dart';

class UniversosParalelosPage extends StatefulWidget {
  final String? atividadePacienteId;
  const UniversosParalelosPage({super.key, this.atividadePacienteId});

  @override
  State<UniversosParalelosPage> createState() => _UniversosParalelosPageState();
}

class _UniversosParalelosPageState extends State<UniversosParalelosPage> {
  final service = PacienteService();
  bool salvando = false;
  int etapa = 0; // 0: Intro, 1: Escolha Método/Criação, 2: Sucesso

  final String cenario = "E se o vilão de uma história fosse, na verdade, o herói?";
  final TextEditingController textoController = TextEditingController();
  String? metodoSelecionado; // "Escrever", "Gravar Áudio", "Desenhar"

  @override
  void dispose() {
    textoController.dispose();
    super.dispose();
  }

  Future<void> finalizarJogo() async {
    final resposta = metodoSelecionado == "Escrever" ? textoController.text.trim() : "Mídia/Desenho criado no tablet";
    if (resposta.isEmpty) return;

    setState(() => salvando = true);
    try {
      await service.registrarJogo(
        jogoId: 'universos_paralelos',
        dadosPlay: {
          'cenario': cenario,
          'metodo': metodoSelecionado!,
          'criacao': resposta,
        },
        atividadePacienteId: widget.atividadePacienteId,
      );

      if (!mounted) return;
      setState(() {
        etapa = 2;
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
    final cardColor = AppColors.card;
    final accentColor = AppColors.secondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('UNIVERSOS PARALELOS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.5)),
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
                child: _buildConteudo(cardColor, accentColor),
              ),
            ),
            _buildBottomButton(accentColor),
          ],
        ),
      ),
    );
  }

  Widget _buildConteudo(Color cardColor, Color neonAccent) {
    switch (etapa) {
      case 0:
        return _buildIntro(cardColor, neonAccent);
      case 1:
        return _buildCriacao(cardColor, neonAccent);
      case 2:
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
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green.withOpacity(0.5)),
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
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(LucideIcons.globe, size: 48, color: neonAccent),
              const SizedBox(height: 18),
              const Text(
                'Como jogar:',
                style: TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Propomos uma premissa alternativa ("E se..."). '
                'Seu objetivo é usar sua criatividade divergente para reimaginar esse universo alternativo.\n\n'
                'Você pode descrever escrevendo, gravando áudio ou esboçando um desenho.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textLight, fontSize: 14, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        const Text(
          'Treine pensamento divergente, criatividade e originalidade.',
          style: TextStyle(color: AppColors.muted, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildCriacao(Color cardColor, Color neonAccent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'HISTÓRIA ALTERNATIVA',
          style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2),
        ),
        const SizedBox(height: 10),
        Text(
          cenario,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text),
        ),
        const SizedBox(height: 32),
        if (metodoSelecionado == null) ...[
          const Text(
            'Escolha como criar sua versão:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textLight),
          ),
          const SizedBox(height: 12),
          _buildOpcaoMetodo("Escrever", LucideIcons.penTool, cardColor, neonAccent),
          _buildOpcaoMetodo("Gravar Áudio", LucideIcons.mic, cardColor, neonAccent),
          _buildOpcaoMetodo("Desenhar", LucideIcons.palette, cardColor, neonAccent),
        ] else ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Modo selecionado: $metodoSelecionado',
                style: TextStyle(color: neonAccent, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              TextButton(
                onPressed: () => setState(() => metodoSelecionado = null),
                child: const Text('Alterar', style: TextStyle(color: AppColors.muted)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (metodoSelecionado == "Escrever")
            TextField(
              controller: textoController,
              onChanged: (val) => setState(() {}),
              maxLines: 6,
              style: const TextStyle(color: AppColors.text),
              decoration: InputDecoration(
                hintText: 'Escreva como seria esse universo alternativo...',
                hintStyle: const TextStyle(color: AppColors.muted),
                filled: true,
                fillColor: cardColor,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            )
          else if (metodoSelecionado == "Gravar Áudio")
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: const Center(
                child: Column(
                  children: [
                    Icon(LucideIcons.mic, size: 40, color: Colors.redAccent),
                    SizedBox(height: 12),
                    Text('Gravando áudio... (Toque para parar)', style: TextStyle(color: AppColors.textLight)),
                  ],
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: const Center(
                child: Column(
                  children: [
                    Icon(LucideIcons.palette, size: 40, color: Colors.purpleAccent),
                    SizedBox(height: 12),
                    Text('Canvas de desenho aberto (Toque para salvar)', style: TextStyle(color: AppColors.textLight)),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildOpcaoMetodo(String nome, IconData icone, Color cardColor, Color neonAccent) {
    return GestureDetector(
      onTap: () => setState(() => metodoSelecionado = nome),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icone, color: neonAccent, size: 24),
            const SizedBox(width: 16),
            Text(nome, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.text)),
            const Spacer(),
            const Icon(LucideIcons.chevronRight, color: AppColors.muted),
          ],
        ),
      ),
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
              LucideIcons.sparkles,
              color: neonAccent,
              size: 56,
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Universo Criado!',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.text),
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Incrível! Sua mente conseguiu quebrar a lógica estabelecida e criar um novo caminho. '
            'Exercitar a criatividade divergente abre portas neurais para lidar com problemas reais de forma muito mais ampla.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textLight, fontSize: 14, height: 1.4),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton(Color neonAccent) {
    if (etapa == 2) {
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
          onPressed: () => setState(() => etapa = 1),
          style: ElevatedButton.styleFrom(
            backgroundColor: neonAccent,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('Iniciar Criação', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      );
    }

    // Etapa 1: Responder
    final podeEnviar = metodoSelecionado != null && (metodoSelecionado != "Escrever" || textoController.text.trim().isNotEmpty);
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
            : const Text('Enviar Universo Alternativo', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
