import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';

/// Widget responsável por renderizar visualmente a resposta do paciente,
/// convertendo JSONs estruturados de jogos e atividades em cards informativos,
/// badges de classificação, métricas e blocos estéticos.
class RespostaAtividadeWidget extends StatelessWidget {
  final dynamic resposta;
  final String? tituloAtividade;
  final Map<String, dynamic>? dadosAtividade;

  const RespostaAtividadeWidget({
    super.key,
    required this.resposta,
    this.tituloAtividade,
    this.dadosAtividade,
  });

  @override
  Widget build(BuildContext context) {
    if (resposta == null || resposta.toString().trim().isEmpty) {
      return _buildVazioCard('Nenhuma resposta registrada pelo paciente.');
    }

    // Tenta decodificar caso seja String JSON
    dynamic parsed;
    if (resposta is Map || resposta is List) {
      parsed = resposta;
    } else if (resposta is String) {
      final str = (resposta as String).trim();
      if ((str.startsWith('{') && str.endsWith('}')) ||
          (str.startsWith('[') && str.endsWith(']'))) {
        try {
          parsed = jsonDecode(str);
        } catch (_) {
          parsed = null;
        }
      }
    }

    if (parsed is Map<String, dynamic>) {
      return _renderizarMap(context, parsed);
    } else if (parsed is List) {
      return _renderizarList(context, parsed);
    }

    // Se for texto livre convencional (ou não for JSON)
    return _buildTextoLivreCard(resposta.toString());
  }

  Widget _renderizarMap(BuildContext context, Map<String, dynamic> data) {
    // 1. Decisão Sob Pressão
    if (data.containsKey('acao_escolhida') ||
        (data.containsKey('situacao') && data.containsKey('tipo_acao'))) {
      return _buildDecisaoSobPressao(data);
    }

    // 2. Detetive dos Pensamentos
    if (data.containsKey('reestruturacao') ||
        (data.containsKey('pensamento') && data.containsKey('emocao') && data.containsKey('intensidade'))) {
      return _buildDetetivePensamentos(data);
    }

    // 3. Tribunal dos Pensamentos
    if (data.containsKey('veredito') ||
        (data.containsKey('provasFavorCount') && data.containsKey('provasContraCount'))) {
      return _buildTribunalPensamentos(data);
    }

    // 4. Monstro da Ansiedade
    if (data.containsKey('formato') && data.containsKey('medo')) {
      return _buildMonstroAnsiedade(data);
    }

    // 5. Caçador de Gatilhos
    if (data.containsKey('gatilho')) {
      return _buildCacadorGatilhos(data);
    }

    // 6. Shark Mind
    if (data.containsKey('pitch_gravado') ||
        (data.containsKey('produto') && data.containsKey('comprador'))) {
      return _buildSharkMind(data);
    }

    // 7. Universos Paralelos
    if (data.containsKey('criacao') && data.containsKey('cenario')) {
      return _buildUniversosParalelos(data);
    }

    // 8. Memória Tática
    if (data.containsKey('arquivo_esperado') || data.containsKey('arquivo_respondido')) {
      return _buildMemoriaTatica(data);
    }

    // 9. Jogos de Desempenho / Foco / Reação / Precisão / Memória
    if (data.containsKey('precisao') ||
        data.containsKey('acertos') ||
        data.containsKey('taxa_acerto') ||
        data.containsKey('acertos_fases') ||
        data.containsKey('pontuacao') ||
        data.containsKey('movimentos') ||
        data.containsKey('tempoGasto') ||
        data.containsKey('jogo')) {
      return _buildJogosPerformance(data);
    }

    // 10. RPD (Registro de Pensamentos Disfuncionais)
    if (data.containsKey('intensidadeEmocionalInicial') ||
        data.containsKey('Pensamento Automático Disfuncional') ||
        data.containsKey('Resposta Alternativa / Racional')) {
      return _buildRPD(data);
    }

    // 11. Exercício Prático
    if (data.containsKey('passosConcluidos') ||
        data.containsKey('tensaoAntes') ||
        data.containsKey('duracaoMinutos')) {
      return _buildExercicioPratico(data);
    }

    // 12. Leitura Psicoeducativa
    if (data.containsKey('leituraConcluida') || data.containsKey('respostasFixacao')) {
      return _buildLeituraPsicoeducativa(data);
    }

    // 13. Checklist Simples (Map de String -> bool)
    final todosValoresBool = data.values.every((v) => v is bool || v == 'true' || v == 'false');
    if (todosValoresBool && data.isNotEmpty) {
      return _buildChecklist(data);
    }

    // Fallback inteligente para JSON Genérico
    return _buildJsonGenerico(data);
  }

  Widget _renderizarList(BuildContext context, List<dynamic> list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < list.length; i++)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.softGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    list[i].toString(),
                    style: const TextStyle(fontSize: 14, color: AppColors.text, height: 1.3),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ==========================================
  // 1. DECISÃO SOB PRESSÃO (Atividade da Imagem)
  // ==========================================
  Widget _buildDecisaoSobPressao(Map<String, dynamic> data) {
    final situacao = data['situacao']?.toString();
    final acaoEscolhida = data['acao_escolhida']?.toString() ?? 'Não informada';
    final tipoAcao = data['tipo_acao']?.toString() ?? '';
    final respirou = data['respirou'] == true || data['respirou']?.toString().toLowerCase() == 'true';

    final isAssertiva = tipoAcao.toLowerCase().contains('assertiv');
    final isImpulsiva = tipoAcao.toLowerCase().contains('impulsiv');
    final isPassiva = tipoAcao.toLowerCase().contains('passiv');

    Color corBadge;
    Color corTextoBadge;
    IconData iconeBadge;
    String labelBadge;

    if (isAssertiva) {
      corBadge = const Color(0xFFDCFCE7); // Soft Green
      corTextoBadge = const Color(0xFF15803D); // Emerald green
      iconeBadge = LucideIcons.shieldCheck;
      labelBadge = 'Comportamento Assertivo';
    } else if (isImpulsiva) {
      corBadge = const Color(0xFFFEE2E2); // Soft Red
      corTextoBadge = const Color(0xFFB91C1C); // Dark Red
      iconeBadge = LucideIcons.zap;
      labelBadge = 'Comportamento Impulsivo';
    } else if (isPassiva) {
      corBadge = const Color(0xFFFEF3C7); // Soft Amber
      corTextoBadge = const Color(0xFFB45309);
      iconeBadge = LucideIcons.shieldAlert;
      labelBadge = 'Comportamento Passivo';
    } else {
      corBadge = AppColors.softBlue;
      corTextoBadge = AppColors.primary;
      iconeBadge = LucideIcons.tag;
      labelBadge = tipoAcao.isNotEmpty ? tipoAcao : 'Classificação';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badges no topo
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: corBadge,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: corTextoBadge.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(iconeBadge, size: 14, color: corTextoBadge),
                  const SizedBox(width: 6),
                  Text(
                    labelBadge,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: corTextoBadge,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: respirou ? const Color(0xFFE0F2FE) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: respirou
                      ? const Color(0xFF0284C7).withValues(alpha: 0.2)
                      : AppColors.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.wind,
                    size: 14,
                    color: respirou ? const Color(0xFF0284C7) : AppColors.muted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    respirou ? 'Pausa para Respiração Realizada' : 'Sem Pausa Respiratória',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: respirou ? const Color(0xFF0369A1) : AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Cenário / Situação
        if (situacao != null && situacao.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(LucideIcons.helpCircle, size: 15, color: AppColors.muted),
                    SizedBox(width: 6),
                    Text(
                      'SITUAÇÃO APRESENTADA',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  situacao,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.text,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Ação Escolhida
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isAssertiva
                ? AppColors.softGreen.withValues(alpha: 0.4)
                : isImpulsiva
                    ? const Color(0xFFFEF2F2)
                    : AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isAssertiva
                  ? AppColors.secondary.withValues(alpha: 0.4)
                  : isImpulsiva
                      ? AppColors.danger.withValues(alpha: 0.3)
                      : AppColors.border,
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    LucideIcons.circleCheck,
                    size: 16,
                    color: isAssertiva ? AppColors.secondary : AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'AÇÃO ESCOLHIDA PELO PACIENTE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: isAssertiva ? AppColors.secondary : AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                acaoEscolhida,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 2. DETETIVE DOS PENSAMENTOS
  // ==========================================
  Widget _buildDetetivePensamentos(Map<String, dynamic> data) {
    final situacao = data['situacao']?.toString();
    final pensamento = data['pensamento']?.toString();
    final emocao = data['emocao']?.toString();
    final intensidade = int.tryParse(data['intensidade']?.toString() ?? '');
    final reestruturacao = data['reestruturacao']?.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (emocao != null || intensidade != null) ...[
          Wrap(
            spacing: 8,
            children: [
              if (emocao != null && emocao.isNotEmpty)
                _buildTagPill(
                  icone: LucideIcons.heart,
                  label: 'Emoção: $emocao',
                  bgCor: const Color(0xFFFDE8E8),
                  textoCor: const Color(0xFF9B1C1C),
                ),
              if (intensidade != null)
                _buildTagPill(
                  icone: LucideIcons.gauge,
                  label: 'Intensidade: $intensidade%',
                  bgCor: AppColors.softBlue,
                  textoCor: AppColors.primary,
                ),
            ],
          ),
          const SizedBox(height: 14),
        ],
        if (situacao != null && situacao.isNotEmpty)
          _buildInfoBloco(
            titulo: 'SITUAÇÃO GATILHO',
            icone: LucideIcons.mapPin,
            conteudo: situacao,
          ),
        if (pensamento != null && pensamento.isNotEmpty)
          _buildInfoBloco(
            titulo: 'PENSAMENTO AUTOMÁTICO',
            icone: LucideIcons.brain,
            conteudo: pensamento,
            bgCor: const Color(0xFFFFFBEB),
            bordaCor: const Color(0xFFFDE68A),
            iconeCor: const Color(0xFFD97706),
          ),
        if (reestruturacao != null && reestruturacao.isNotEmpty)
          _buildInfoBloco(
            titulo: 'REESTRUTURAÇÃO COGNITIVA / RESPOSTA ALTERNATIVA',
            icone: LucideIcons.lightbulb,
            conteudo: reestruturacao,
            bgCor: AppColors.softGreen.withValues(alpha: 0.5),
            bordaCor: AppColors.secondary.withValues(alpha: 0.4),
            iconeCor: AppColors.secondary,
            destaque: true,
          ),
      ],
    );
  }

  // ==========================================
  // 3. TRIBUNAL DOS PENSAMENTOS
  // ==========================================
  Widget _buildTribunalPensamentos(Map<String, dynamic> data) {
    final pensamento = data['pensamento']?.toString() ?? '';
    final favor = data['provasFavorCount']?.toString() ?? '0';
    final contra = data['provasContraCount']?.toString() ?? '0';
    final veredito = data['veredito']?.toString() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (pensamento.isNotEmpty)
          _buildInfoBloco(
            titulo: 'PENSAMENTO NO BANCO DOS RÉUS',
            icone: LucideIcons.scale,
            conteudo: pensamento,
          ),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                titulo: 'Provas a Favor',
                valor: favor,
                icone: LucideIcons.fileSearch,
                cor: const Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricTile(
                titulo: 'Provas Contra',
                valor: contra,
                icone: LucideIcons.shieldCheck,
                cor: AppColors.secondary,
              ),
            ),
          ],
        ),
        if (veredito.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildInfoBloco(
            titulo: 'VEREDITO FINAL DO PACIENTE',
            icone: LucideIcons.gavel,
            conteudo: veredito,
            bgCor: AppColors.softGreen.withValues(alpha: 0.4),
            bordaCor: AppColors.secondary.withValues(alpha: 0.4),
            iconeCor: AppColors.secondary,
            destaque: true,
          ),
        ],
      ],
    );
  }

  // ==========================================
  // 4. MONSTRO DA ANSIEDADE
  // ==========================================
  Widget _buildMonstroAnsiedade(Map<String, dynamic> data) {
    final nome = data['nome']?.toString() ?? 'Monstro';
    final formato = data['formato']?.toString();
    final cor = data['cor']?.toString();
    final medo = data['medo']?.toString();
    final localCorpo = data['localCorpo']?.toString();
    final pensamento = data['pensamentoAutomatico']?.toString();
    final acao = data['acao']?.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF3E8FF), // Soft purple
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFD8B4FE)),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFF9333EA),
                child: Icon(LucideIcons.ghost, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nome,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF581C87),
                      ),
                    ),
                    Text(
                      'Formato: ${formato ?? 'Livre'} • Cor: ${cor ?? 'Personalizada'}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF7E22CE)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (localCorpo != null && localCorpo.isNotEmpty)
          _buildInfoBloco(
            titulo: 'ONDE SE MANIFESTA NO CORPO',
            icone: LucideIcons.activity,
            conteudo: localCorpo,
          ),
        if (medo != null && medo.isNotEmpty)
          _buildInfoBloco(
            titulo: 'MEDO PRINCIPAL',
            icone: LucideIcons.alertTriangle,
            conteudo: medo,
            bgCor: const Color(0xFFFFFBEB),
            bordaCor: const Color(0xFFFDE68A),
            iconeCor: const Color(0xFFD97706),
          ),
        if (pensamento != null && pensamento.isNotEmpty)
          _buildInfoBloco(
            titulo: 'PENSAMENTO DO MONSTRO',
            icone: LucideIcons.messageSquare,
            conteudo: pensamento,
          ),
        if (acao != null && acao.isNotEmpty)
          _buildInfoBloco(
            titulo: 'AÇÃO DE ENFRENTAMENTO ADOTADA',
            icone: LucideIcons.shieldCheck,
            conteudo: acao,
            bgCor: AppColors.softGreen.withValues(alpha: 0.4),
            bordaCor: AppColors.secondary.withValues(alpha: 0.4),
            iconeCor: AppColors.secondary,
            destaque: true,
          ),
      ],
    );
  }

  // ==========================================
  // 5. CAÇADOR DE GATILHOS
  // ==========================================
  Widget _buildCacadorGatilhos(Map<String, dynamic> data) {
    final gatilho = data['gatilho']?.toString() ?? '';
    final situacao = data['situacao']?.toString() ?? '';
    final emocao = data['emocao']?.toString() ?? '';
    final intensidade = data['intensidade']?.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (gatilho.isNotEmpty)
          _buildTagPill(
            icone: LucideIcons.crosshair,
            label: 'Gatilho: $gatilho',
            bgCor: const Color(0xFFFEF3C7),
            textoCor: const Color(0xFFB45309),
          ),
        const SizedBox(height: 12),
        if (situacao.isNotEmpty)
          _buildInfoBloco(
            titulo: 'SITUAÇÃO DO GATILHO',
            icone: LucideIcons.fileText,
            conteudo: situacao,
          ),
        if (emocao.isNotEmpty || intensidade != null)
          Row(
            children: [
              if (emocao.isNotEmpty)
                Expanded(
                  child: _buildMetricTile(
                    titulo: 'Emoção Sentida',
                    valor: emocao,
                    icone: LucideIcons.heart,
                    cor: AppColors.danger,
                  ),
                ),
              if (emocao.isNotEmpty && intensidade != null) const SizedBox(width: 12),
              if (intensidade != null)
                Expanded(
                  child: _buildMetricTile(
                    titulo: 'Intensidade',
                    valor: '$intensidade/100',
                    icone: LucideIcons.gauge,
                    cor: AppColors.secondary,
                  ),
                ),
            ],
          ),
      ],
    );
  }

  // ==========================================
  // 6. SHARK MIND
  // ==========================================
  Widget _buildSharkMind(Map<String, dynamic> data) {
    final produto = data['produto']?.toString() ?? '';
    final comprador = data['comprador']?.toString() ?? '';
    final tempoGravado = data['tempo_gravado']?.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                titulo: 'Pitch Gravado',
                valor: '${tempoGravado ?? '30'}s',
                icone: LucideIcons.mic,
                cor: AppColors.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (produto.isNotEmpty)
          _buildInfoBloco(
            titulo: 'PRODUTO / PROPOSTA',
            icone: LucideIcons.box,
            conteudo: produto,
          ),
        if (comprador.isNotEmpty)
          _buildInfoBloco(
            titulo: 'PERFIL DO COMPRADOR',
            icone: LucideIcons.user,
            conteudo: comprador,
          ),
      ],
    );
  }

  // ==========================================
  // 7. UNIVERSOS PARALELOS
  // ==========================================
  Widget _buildUniversosParalelos(Map<String, dynamic> data) {
    final cenario = data['cenario']?.toString() ?? '';
    final metodo = data['metodo']?.toString() ?? 'Escrever';
    final criacao = data['criacao']?.toString() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTagPill(
          icone: LucideIcons.palette,
          label: 'Método: $metodo',
          bgCor: AppColors.softBlue,
          textoCor: AppColors.primary,
        ),
        const SizedBox(height: 12),
        if (cenario.isNotEmpty)
          _buildInfoBloco(
            titulo: 'CENÁRIO HIPOTÉTICO',
            icone: LucideIcons.compass,
            conteudo: cenario,
          ),
        if (criacao.isNotEmpty)
          _buildInfoBloco(
            titulo: 'CRIAÇÃO / RESPOSTA CRIATIVA DO PACIENTE',
            icone: LucideIcons.sparkles,
            conteudo: criacao,
            bgCor: AppColors.softGreen.withValues(alpha: 0.4),
            bordaCor: AppColors.secondary.withValues(alpha: 0.4),
            iconeCor: AppColors.secondary,
            destaque: true,
          ),
      ],
    );
  }

  // ==========================================
  // 8. MEMÓRIA TÁTICA
  // ==========================================
  Widget _buildMemoriaTatica(Map<String, dynamic> data) {
    final acerto = data['acerto'] == true || data['acerto']?.toString().toLowerCase() == 'true';
    final esperado = data['arquivo_esperado']?.toString();
    final respondido = data['arquivo_respondido']?.toString();
    final mostrados = data['itens_mostrados']?.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTagPill(
          icone: acerto ? LucideIcons.checkCircle : LucideIcons.xCircle,
          label: acerto ? 'Acertou o Item Desaparecido' : 'Resposta Incorreta',
          bgCor: acerto ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
          textoCor: acerto ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
        ),
        const SizedBox(height: 12),
        if (respondido != null)
          _buildInfoBloco(
            titulo: 'ITEM SELECIONADO PELO PACIENTE',
            icone: LucideIcons.mousePointerClick,
            conteudo: respondido,
          ),
        if (esperado != null && esperado != respondido)
          _buildInfoBloco(
            titulo: 'ITEM CORRETO ESPERADO',
            icone: LucideIcons.helpCircle,
            conteudo: esperado,
            bgCor: const Color(0xFFFFFBEB),
            bordaCor: const Color(0xFFFDE68A),
          ),
        if (mostrados != null && mostrados.isNotEmpty)
          _buildInfoBloco(
            titulo: 'ITENS MOSTRADOS NA RODADA',
            icone: LucideIcons.layoutGrid,
            conteudo: mostrados,
          ),
      ],
    );
  }

  // ==========================================
  // 9. JOGOS DE PERFORMANCE / MÉTRICAS
  // ==========================================
  Widget _buildJogosPerformance(Map<String, dynamic> data) {
    final precisao = data['precisao'] ?? data['taxa_acerto'];
    final acertos = data['acertos'] ?? data['acertos_fases'];
    final erros = data['erros'];
    final rodadas = data['total_rodadas'] ?? data['casos_totais'] ?? data['total_fases'];
    final tempo = data['tempoGasto'] ?? data['tempo'];
    final movimentos = data['movimentos'];
    final dificuldade = data['dificuldade']?.toString();
    final pontuacao = data['pontuacao'] ?? data['totalXP'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data.containsKey('jogo')) ...[
          _buildTagPill(
            icone: LucideIcons.gamepad2,
            label: data['jogo'].toString(),
            bgCor: AppColors.softBlue,
            textoCor: AppColors.primary,
          ),
          const SizedBox(height: 12),
        ],
        // Métricas principais em Grid
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            if (precisao != null)
              SizedBox(
                width: 140,
                child: _buildMetricTile(
                  titulo: 'Precisão',
                  valor: '$precisao%',
                  icone: LucideIcons.target,
                  cor: AppColors.secondary,
                ),
              ),
            if (acertos != null)
              SizedBox(
                width: 140,
                child: _buildMetricTile(
                  titulo: 'Acertos',
                  valor: '$acertos${rodadas != null ? '/$rodadas' : ''}',
                  icone: LucideIcons.checkCircle,
                  cor: const Color(0xFF16A34A),
                ),
              ),
            if (erros != null)
              SizedBox(
                width: 140,
                child: _buildMetricTile(
                  titulo: 'Erros',
                  valor: '$erros',
                  icone: LucideIcons.alertCircle,
                  cor: AppColors.danger,
                ),
              ),
            if (tempo != null)
              SizedBox(
                width: 140,
                child: _buildMetricTile(
                  titulo: 'Tempo Gasto',
                  valor: '$tempo',
                  icone: LucideIcons.clock,
                  cor: AppColors.primary,
                ),
              ),
            if (movimentos != null)
              SizedBox(
                width: 140,
                child: _buildMetricTile(
                  titulo: 'Movimentos',
                  valor: '$movimentos',
                  icone: LucideIcons.refreshCw,
                  cor: const Color(0xFF8B5CF6),
                ),
              ),
            if (pontuacao != null)
              SizedBox(
                width: 140,
                child: _buildMetricTile(
                  titulo: 'Pontuação',
                  valor: '$pontuacao pts',
                  icone: LucideIcons.trophy,
                  cor: const Color(0xFFF59E0B),
                ),
              ),
          ],
        ),
        if (dificuldade != null && dificuldade.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Nível de Dificuldade: $dificuldade',
            style: const TextStyle(fontSize: 12, color: AppColors.muted, fontWeight: FontWeight.w600),
          ),
        ],
      ],
    );
  }

  // ==========================================
  // 10. RPD (REGISTRO DE PENSAMENTOS)
  // ==========================================
  Widget _buildRPD(Map<String, dynamic> data) {
    final intInicial = data['intensidadeEmocionalInicial'];
    final intFinal = data['intensidadeEmocionalFinal'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (intInicial != null && intFinal != null) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.softGreen.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.softGreen.withValues(alpha: 0.6)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('Intensidade Inicial', style: TextStyle(fontSize: 11, color: AppColors.muted)),
                    const SizedBox(height: 4),
                    Text('$intInicial%', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.danger)),
                  ],
                ),
                const Icon(LucideIcons.arrowRight, color: AppColors.secondary, size: 20),
                Column(
                  children: [
                    const Text('Reavaliação Final', style: TextStyle(fontSize: 11, color: AppColors.muted)),
                    const SizedBox(height: 4),
                    Text('$intFinal%', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
        for (var entry in data.entries)
          if (!entry.key.startsWith('intensidadeEmocional') && entry.value.toString().isNotEmpty)
            _buildInfoBloco(
              titulo: _formatarTituloChave(entry.key),
              icone: LucideIcons.fileCheck,
              conteudo: entry.value.toString(),
            ),
      ],
    );
  }

  // ==========================================
  // 11. EXERCÍCIO PRÁTICO
  // ==========================================
  Widget _buildExercicioPratico(Map<String, dynamic> data) {
    final duracao = data['duracaoMinutos']?.toString();
    final tensaoAntes = data['tensaoAntes'];
    final tensaoDepois = data['tensaoDepois'];
    final passos = data['passosConcluidos'];
    final comentario = data['comentario']?.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (duracao != null)
          _buildTagPill(
            icone: LucideIcons.timer,
            label: 'Duração: $duracao min',
            bgCor: AppColors.softBlue,
            textoCor: AppColors.primary,
          ),
        const SizedBox(height: 12),
        if (tensaoAntes != null && tensaoDepois != null) ...[
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  titulo: 'Tensão Pré',
                  valor: '$tensaoAntes/10',
                  icone: LucideIcons.activity,
                  cor: AppColors.danger,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile(
                  titulo: 'Tensão Pós',
                  valor: '$tensaoDepois/10',
                  icone: LucideIcons.heartPulse,
                  cor: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        if (passos is List) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('PASSOS REALIZADOS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.muted)),
                const SizedBox(height: 8),
                for (int i = 0; i < passos.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Icon(
                          passos[i] == true ? LucideIcons.checkSquare : LucideIcons.square,
                          size: 16,
                          color: passos[i] == true ? AppColors.secondary : AppColors.muted,
                        ),
                        const SizedBox(width: 8),
                        Text('Etapa ${i + 1}: ${passos[i] == true ? 'Concluída' : 'Pendente'}', style: const TextStyle(fontSize: 13, color: AppColors.text)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (comentario != null && comentario.isNotEmpty)
          _buildInfoBloco(
            titulo: 'OBSERVAÇÕES DO PACIENTE',
            icone: LucideIcons.messageSquare,
            conteudo: comentario,
            destaque: true,
          ),
      ],
    );
  }

  // ==========================================
  // 12. LEITURA PSICOEDUCATIVA
  // ==========================================
  Widget _buildLeituraPsicoeducativa(Map<String, dynamic> data) {
    final fixacao = data['respostasFixacao'];
    final comentario = data['comentario']?.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTagPill(
          icone: LucideIcons.bookOpenCheck,
          label: 'Leitura Concluída pelo Paciente',
          bgCor: const Color(0xFFDCFCE7),
          textoCor: const Color(0xFF15803D),
        ),
        const SizedBox(height: 12),
        if (fixacao is Map) ...[
          for (var entry in fixacao.entries)
            _buildInfoBloco(
              titulo: entry.key.toString(),
              icone: LucideIcons.helpCircle,
              conteudo: entry.value.toString().isNotEmpty ? entry.value.toString() : 'Sem resposta',
            ),
        ],
        if (comentario != null && comentario.isNotEmpty)
          _buildInfoBloco(
            titulo: 'REFLEXÃO / COMENTÁRIO DO PACIENTE',
            icone: LucideIcons.messageSquare,
            conteudo: comentario,
            destaque: true,
          ),
      ],
    );
  }

  // ==========================================
  // 13. CHECKLIST
  // ==========================================
  Widget _buildChecklist(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var entry in data.entries) ...[
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(
                  (entry.value == true || entry.value?.toString().toLowerCase() == 'true')
                      ? LucideIcons.checkSquare
                      : LucideIcons.square,
                  color: (entry.value == true || entry.value?.toString().toLowerCase() == 'true')
                      ? AppColors.secondary
                      : AppColors.muted,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: (entry.value == true || entry.value?.toString().toLowerCase() == 'true')
                          ? AppColors.text
                          : AppColors.muted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ==========================================
  // FALLBACK: JSON GENÉRICO HUMANIZADO
  // ==========================================
  Widget _buildJsonGenerico(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var entry in data.entries) ...[
          if (entry.value is bool)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildTagPill(
                icone: entry.value == true ? LucideIcons.check : LucideIcons.x,
                label: '${_formatarTituloChave(entry.key)}: ${entry.value == true ? "Sim" : "Não"}',
                bgCor: entry.value == true ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                textoCor: entry.value == true ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
              ),
            )
          else if (entry.value is num)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildMetricTile(
                titulo: _formatarTituloChave(entry.key),
                valor: entry.value.toString(),
                icone: LucideIcons.hash,
                cor: AppColors.primary,
              ),
            )
          else
            _buildInfoBloco(
              titulo: _formatarTituloChave(entry.key),
              icone: LucideIcons.info,
              conteudo: entry.value?.toString() ?? '',
            ),
        ],
      ],
    );
  }

  // ==========================================
  // HELPER WIDGETS
  // ==========================================

  Widget _buildInfoBloco({
    required String titulo,
    required IconData icone,
    required String conteudo,
    Color? bgCor,
    Color? bordaCor,
    Color? iconeCor,
    bool destaque = false,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgCor ?? AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: bordaCor ?? AppColors.border, width: destaque ? 1.5 : 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icone, size: 14, color: iconeCor ?? AppColors.muted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  titulo.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: iconeCor ?? AppColors.muted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            conteudo,
            style: TextStyle(
              fontSize: destaque ? 15 : 14,
              fontWeight: destaque ? FontWeight.w600 : FontWeight.normal,
              color: AppColors.text,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagPill({
    required IconData icone,
    required String label,
    required Color bgCor,
    required Color textoCor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgCor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textoCor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 14, color: textoCor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textoCor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String titulo,
    required String valor,
    required IconData icone,
    required Color cor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icone, size: 14, color: cor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.muted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            valor,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cor),
          ),
        ],
      ),
    );
  }

  Widget _buildTextoLivreCard(String texto) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.softGreen.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.softGreen.withValues(alpha: 0.6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(LucideIcons.quote, size: 18, color: AppColors.secondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.text,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVazioCard(String mensagem) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.info, size: 18, color: AppColors.muted),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              mensagem,
              style: const TextStyle(fontSize: 13, color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }

  String _formatarTituloChave(String key) {
    // Transforma camelCase ou snake_case em Palavras Legíveis
    final semSnake = key.replaceAll('_', ' ');
    final resultado = StringBuffer();
    for (int i = 0; i < semSnake.length; i++) {
      final char = semSnake[i];
      if (i > 0 &&
          char.toUpperCase() == char &&
          char.toLowerCase() != char &&
          semSnake[i - 1] != ' ') {
        resultado.write(' ');
      }
      resultado.write(char);
    }
    final raw = resultado.toString().trim();
    if (raw.isEmpty) return key;
    return raw[0].toUpperCase() + raw.substring(1);
  }
}
