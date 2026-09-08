import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import 'models/avatar_model.dart';
import 'services/paciente_service.dart';
import 'widgets/avatar_widget.dart';

class CriarAvatarPage extends StatefulWidget {
  final AvatarModel? currentAvatar;
  final int? nivel;
  final int? xp;

  const CriarAvatarPage({
    super.key,
    this.currentAvatar,
    this.nivel,
    this.xp,
  });

  @override
  State<CriarAvatarPage> createState() => _CriarAvatarPageState();
}

class _CriarAvatarPageState extends State<CriarAvatarPage> with SingleTickerProviderStateMixin {
  final service = PacienteService();
  late TabController _tabController;

  bool carregando = true;
  bool salvando = false;
  int pacienteNivel = 3;
  int pacientePontos = 280;
  AvatarModel avatarAtual = const AvatarModel();

  // Subcategorias
  String subcategoriaRoupa = 'Todos';
  String subcategoriaAcessorio = 'Todos';

  // ============== DADOS DO CATÁLOGO ==============

  // Formato de Rosto
  final formatosRosto = [
    {'id': 'oval', 'nome': 'Oval', 'sub': 'Equilibrado'},
    {'id': 'redondo', 'nome': 'Redondo', 'sub': 'Suave'},
    {'id': 'quadrado', 'nome': 'Quadrado', 'sub': 'Marcante'},
    {'id': 'fino', 'nome': 'Fino', 'sub': 'Alongado'},
  ];

  // Tom de Pele
  final tonsPele = [
    {'nome': 'Claro 1', 'hex': '#FFDFD3'},
    {'nome': 'Claro 2', 'hex': '#F5D0A9'},
    {'nome': 'Moreno 1', 'hex': '#E0AC69'},
    {'nome': 'Moreno 2', 'hex': '#C68642'},
    {'nome': 'Escuro 1', 'hex': '#8D5524'},
    {'nome': 'Escuro 2', 'hex': '#583617'},
  ];

  // Expressões
  final expressoes = [
    {'id': 'calmo', 'nome': 'Neutro'},
    {'id': 'alegre', 'nome': 'Alegre'},
    {'id': 'confiante', 'nome': 'Confiante'},
    {'id': 'determinado', 'nome': 'Determinado'},
    {'id': 'sorrindo', 'nome': 'Tranquilo'},
  ];

  // Cabelo - Estilos
  final estilosCabelo = [
    {'id': 'curto_liso', 'nome': 'Curto liso'},
    {'id': 'curto_ondulado', 'nome': 'Curto ondulado'},
    {'id': 'medio', 'nome': 'Médio'},
    {'id': 'cacheado', 'nome': 'Cacheado'},
    {'id': 'crespo', 'nome': 'Crespo'},
    {'id': 'undercut', 'nome': 'Undercut'},
    {'id': 'topete', 'nome': 'Topete'},
    {'id': 'longo_liso', 'nome': 'Longo liso'},
    {'id': 'longo_ondulado', 'nome': 'Longo ondulado'},
    {'id': 'trancas', 'nome': 'Tranças'},
  ];

  // Cabelo - Cores
  final coresCabelo = [
    {'nome': 'Preto', 'hex': '#1F2937'},
    {'nome': 'Castanho Escuro', 'hex': '#2C1B18'},
    {'nome': 'Castanho Claro', 'hex': '#4A2E10'},
    {'nome': 'Loiro', 'hex': '#E5B869'},
    {'nome': 'Ruivo', 'hex': '#A52A2A'},
    {'nome': 'Prata', 'hex': '#9CA3AF'},
    {'nome': 'Rosa', 'hex': '#EC4899'},
  ];

  // Roupas
  final categoriasRoupas = ['Todos', 'Camisetas', 'Moletons', 'Jaquetas', 'Calças', 'Conjuntos'];

  final estilosRoupa = [
    {'id': 'moletom_mindsteps', 'nome': 'Moletom\nMindSteps', 'cat': 'Moletons'},
    {'id': 'moletom_basico', 'nome': 'Moletom\nBásico', 'cat': 'Moletons'},
    {'id': 'moletom_esportivo', 'nome': 'Moletom\nEsportivo', 'cat': 'Moletons'},
    {'id': 'moletom_casual', 'nome': 'Moletom\nCasual', 'cat': 'Moletons'},
    {'id': 'moletom_minimalista', 'nome': 'Moletom\nMinimalista', 'cat': 'Moletons'},
    {'id': 'camiseta_mindsteps', 'nome': 'Camiseta\nMindSteps', 'cat': 'Camisetas'},
    {'id': 'camiseta_basica', 'nome': 'Camiseta\nBásica', 'cat': 'Camisetas'},
    {'id': 'camiseta_estonada', 'nome': 'Camiseta\nEstonada', 'cat': 'Camisetas'},
    {'id': 'camiseta_oversized', 'nome': 'Camiseta\nOversized', 'cat': 'Camisetas'},
    {'id': 'camiseta_estampada', 'nome': 'Camiseta\nEstampada', 'cat': 'Camisetas'},
    {'id': 'jaqueta_puffer', 'nome': 'Jaqueta\nPuffer', 'cat': 'Jaquetas'},
    {'id': 'jaqueta_college', 'nome': 'Jaqueta\nCollege', 'cat': 'Jaquetas'},
    {'id': 'jaqueta_jeans', 'nome': 'Jaqueta\nJeans', 'cat': 'Jaquetas'},
    {'id': 'jaqueta_corta_vento', 'nome': 'Jaqueta\nCorta-Vento', 'cat': 'Jaquetas'},
    {'id': 'jaqueta_casual', 'nome': 'Jaqueta\nCasual', 'cat': 'Jaquetas'},
  ];

  // Cores de roupa
  final coresRoupa = [
    {'nome': 'Preto', 'hex': '#1F2937'},
    {'nome': 'Branco', 'hex': '#F8FAFC'},
    {'nome': 'Azul', 'hex': '#3B82F6'},
    {'nome': 'Roxo', 'hex': '#8B5CF6'},
    {'nome': 'Verde', 'hex': '#10B981'},
    {'nome': 'Amarelo', 'hex': '#F59E0B'},
    {'nome': 'Vermelho', 'hex': '#991B1B'},
    {'nome': 'Rosa', 'hex': '#F9A8D4'},
  ];

  // Acessórios
  final categoriasAcessorios = ['Todos', 'Óculos', 'Fones', 'Chapéus', 'Piercings', 'Colares', 'Outros'];

  final acessoriosGamificados = <Map<String, dynamic>>[
    // Óculos
    {'id': 'oculos_nenhum', 'nome': 'Nenhum', 'cat': 'Óculos', 'nivelMin': 1, 'xpMin': 0, 'icone': LucideIcons.ban},
    {'id': 'oculos_redondo', 'nome': 'Redondo', 'cat': 'Óculos', 'nivelMin': 1, 'xpMin': 0, 'icone': LucideIcons.glasses},
    {'id': 'oculos_quadrado', 'nome': 'Quadrado', 'cat': 'Óculos', 'nivelMin': 1, 'xpMin': 25, 'icone': LucideIcons.glasses},
    {'id': 'oculos_esportivo', 'nome': 'Esportivo', 'cat': 'Óculos', 'nivelMin': 2, 'xpMin': 100, 'icone': LucideIcons.glasses},
    {'id': 'oculos_aviador', 'nome': 'Aviador', 'cat': 'Óculos', 'nivelMin': 2, 'xpMin': 150, 'icone': LucideIcons.sun},
    {'id': 'oculos_retro', 'nome': 'Retrô', 'cat': 'Óculos', 'nivelMin': 3, 'xpMin': 250, 'icone': LucideIcons.sparkles},
    // Fones
    {'id': 'fone_nenhum', 'nome': 'Nenhum', 'cat': 'Fones', 'nivelMin': 1, 'xpMin': 0, 'icone': LucideIcons.ban},
    {'id': 'fone_over_ear', 'nome': 'Over-ear', 'cat': 'Fones', 'nivelMin': 1, 'xpMin': 0, 'icone': LucideIcons.headphones},
    {'id': 'fone_in_ear', 'nome': 'In-ear', 'cat': 'Fones', 'nivelMin': 2, 'xpMin': 100, 'icone': LucideIcons.headphones},
    {'id': 'fone_gamer', 'nome': 'Gamer', 'cat': 'Fones', 'nivelMin': 2, 'xpMin': 150, 'icone': LucideIcons.headphones},
    {'id': 'fone_sem_fio', 'nome': 'Sem fio', 'cat': 'Fones', 'nivelMin': 3, 'xpMin': 200, 'icone': LucideIcons.headphones},
    {'id': 'fone_colorido', 'nome': 'Colorido', 'cat': 'Fones', 'nivelMin': 3, 'xpMin': 300, 'icone': LucideIcons.headphones},
    // Chapéus
    {'id': 'chapeu_nenhum', 'nome': 'Nenhum', 'cat': 'Chapéus', 'nivelMin': 1, 'xpMin': 0, 'icone': LucideIcons.ban},
    {'id': 'bone_preto', 'nome': 'Boné', 'cat': 'Chapéus', 'nivelMin': 1, 'xpMin': 0, 'icone': LucideIcons.hardHat},
    {'id': 'bucket_hat', 'nome': 'Bucket', 'cat': 'Chapéus', 'nivelMin': 2, 'xpMin': 100, 'icone': LucideIcons.hardHat},
    {'id': 'touca', 'nome': 'Touca', 'cat': 'Chapéus', 'nivelMin': 2, 'xpMin': 150, 'icone': LucideIcons.hardHat},
    {'id': 'gorro', 'nome': 'Gorro', 'cat': 'Chapéus', 'nivelMin': 3, 'xpMin': 200, 'icone': LucideIcons.hardHat},
    {'id': 'chapeu_panama', 'nome': 'Chapéu', 'cat': 'Chapéus', 'nivelMin': 3, 'xpMin': 350, 'icone': LucideIcons.crown},
    // Piercings
    {'id': 'piercing_nenhum', 'nome': 'Nenhum', 'cat': 'Piercings', 'nivelMin': 1, 'xpMin': 0, 'icone': LucideIcons.ban},
    {'id': 'piercing_orelha', 'nome': 'Orelha', 'cat': 'Piercings', 'nivelMin': 1, 'xpMin': 25, 'icone': LucideIcons.sparkles},
    {'id': 'piercing_nariz', 'nome': 'Nariz', 'cat': 'Piercings', 'nivelMin': 2, 'xpMin': 100, 'icone': LucideIcons.sparkles},
    {'id': 'piercing_sobrancelha', 'nome': 'Sobrancelha', 'cat': 'Piercings', 'nivelMin': 2, 'xpMin': 150, 'icone': LucideIcons.sparkles},
    {'id': 'piercing_labio', 'nome': 'Lábio', 'cat': 'Piercings', 'nivelMin': 3, 'xpMin': 200, 'icone': LucideIcons.sparkles},
    {'id': 'piercing_multiplos', 'nome': 'Múltiplos', 'cat': 'Piercings', 'nivelMin': 3, 'xpMin': 350, 'icone': LucideIcons.sparkles},
    // Colares e outros
    {'id': 'colar_nenhum', 'nome': 'Nenhum', 'cat': 'Colares', 'nivelMin': 1, 'xpMin': 0, 'icone': LucideIcons.ban},
    {'id': 'colar_simples', 'nome': 'Colar simples', 'cat': 'Colares', 'nivelMin': 1, 'xpMin': 25, 'icone': LucideIcons.gem},
    {'id': 'colar_pingente', 'nome': 'Colar pingente', 'cat': 'Colares', 'nivelMin': 2, 'xpMin': 100, 'icone': LucideIcons.gem},
    {'id': 'corrente', 'nome': 'Corrente', 'cat': 'Colares', 'nivelMin': 2, 'xpMin': 150, 'icone': LucideIcons.gem},
    {'id': 'pulseira', 'nome': 'Pulseira', 'cat': 'Colares', 'nivelMin': 3, 'xpMin': 200, 'icone': LucideIcons.gem},
    {'id': 'relogio', 'nome': 'Relógio', 'cat': 'Colares', 'nivelMin': 3, 'xpMin': 250, 'icone': LucideIcons.watch},
  ];

  static const _primary = Color(0xFF4F46E5);

  // ============== TEXTOS POR ABA ==============
  final _titulosAba = [
    {'titulo': 'Seu avatar,', 'destaque': 'do seu jeito.', 'desc': 'Escolha um visual que te represente no MindSteps.', 'citacao': '"Pequenas escolhas também constroem grandes jornadas."'},
    {'titulo': 'Qual é o seu', 'destaque': 'estilo?', 'desc': 'Escolha um cabelo que combine com você.', 'citacao': '"Seu avatar é único, assim como você."'},
    {'titulo': 'Vista o que\ncombina', 'destaque': 'com você!', 'desc': 'Escolha um estilo que represente sua personalidade.', 'citacao': '"Estilo também é uma forma de se expressar."'},
    {'titulo': 'Os detalhes\nfazem a', 'destaque': 'diferença!', 'desc': 'Adicione acessórios para deixar seu avatar ainda mais com a sua cara.', 'citacao': '"Pequenos detalhes, grandes histórias."'},
    {'titulo': 'Finalize seu', 'destaque': 'visual!', 'desc': 'Revise e confirme seu avatar personalizado.', 'citacao': '"Cada detalhe conta na sua jornada."'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() => setState(() {}));
    if (widget.currentAvatar != null) avatarAtual = widget.currentAvatar!;
    if (widget.nivel != null) pacienteNivel = widget.nivel!;
    if (widget.xp != null) pacientePontos = widget.xp!;
    _carregarPerfil();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _carregarPerfil() async {
    setState(() => carregando = true);
    try {
      final me = await service.obterMe();
      final fotoUrl = me['fotoUrl']?.toString();
      final avatarParsed = AvatarModel.fromJson(fotoUrl);
      setState(() {
        pacienteNivel = me['nivel'] ?? 3;
        pacientePontos = me['pontos'] ?? 280;
        avatarAtual = avatarParsed;
      });
    } catch (e) {
      debugPrint('Erro ao carregar dados do avatar: $e');
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  Future<void> _salvarAvatar() async {
    setState(() => salvando = true);
    try {
      final me = await service.obterMe();
      final pacienteId = me['pacienteId']?.toString() ?? me['id']?.toString();
      final nome = me['nome']?.toString() ?? 'Paciente';
      final email = me['email']?.toString() ?? '';
      if (pacienteId != null) {
        await service.atualizarPerfil(
          pacienteId: pacienteId,
          nome: nome,
          email: email,
          fotoUrl: avatarAtual.toJson(),
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Avatar atualizado com sucesso! 🎉')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
      }
    } finally {
      if (mounted) setState(() => salvando = false);
    }
  }

  bool _itemDesbloqueado(Map<String, dynamic> acc) {
    final reqNivel = acc['nivelMin'] as int? ?? 1;
    final reqXp = acc['xpMin'] as int? ?? 0;
    return pacienteNivel >= reqNivel || pacientePontos >= reqXp;
  }

  void _toggleAcessorio(String accId, bool desbloqueado, int reqNivel, int reqXp) {
    if (!desbloqueado) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🔒 Exige Nível $reqNivel e $reqXp XP para desbloquear!'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }
    final lista = List<String>.from(avatarAtual.acessorios);
    if (lista.contains(accId)) {
      lista.remove(accId);
    } else {
      lista.add(accId);
    }
    setState(() => avatarAtual = avatarAtual.copyWith(acessorios: lista));
  }

  Color _hexToColor(String hex) {
    final clean = hex.replaceAll('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final currentTab = _tabController.index;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            const Text('Criar Meu Avatar', style: TextStyle(color: Color(0xFF0F172A), fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(
              'Passo ${currentTab + 1} de 5 • ${['Rosto', 'Cabelo', 'Roupas', 'Acessórios', 'Estilo'][currentTab]}',
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Pular', style: TextStyle(color: _primary, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Indicador de progresso
                _buildStepIndicator(currentTab),

                // Hero Section
                _buildHeroSection(currentTab),

                // Tabs
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: _primary,
                    unselectedLabelColor: const Color(0xFF64748B),
                    indicatorColor: _primary,
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                    tabs: const [
                      Tab(icon: Icon(LucideIcons.smile, size: 18), text: 'Rosto'),
                      Tab(icon: Icon(LucideIcons.scissors, size: 18), text: 'Cabelo'),
                      Tab(icon: Icon(LucideIcons.shirt, size: 18), text: 'Roupas'),
                      Tab(icon: Icon(LucideIcons.glasses, size: 18), text: 'Acessórios'),
                      Tab(icon: Icon(LucideIcons.palette, size: 18), text: 'Estilo'),
                    ],
                  ),
                ),

                // Conteúdo
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAbaRosto(),
                      _buildAbaCabelo(),
                      _buildAbaRoupas(),
                      _buildAbaAcessorios(),
                      _buildAbaEstilo(),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ============== STEP INDICATOR ==============
  Widget _buildStepIndicator(int current) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(40, 8, 40, 0),
      child: Row(
        children: List.generate(5, (i) {
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: i <= current ? _primary : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ============== HERO SECTION ==============
  Widget _buildHeroSection(int tabIndex) {
    final info = _titulosAba[tabIndex];

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          // Painel de Texto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: '${info['titulo']}\n',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), height: 1.1),
                    ),
                    TextSpan(
                      text: info['destaque'],
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _primary, height: 1.1),
                    ),
                  ]),
                ),
                const SizedBox(height: 6),
                Text(info['desc']!, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    info['citacao']!,
                    style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Color(0xFF475569)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Avatar central com fundo lilás
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 130,
                height: 130,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              AvatarWidget(avatar: avatarAtual, size: 120, showBorder: false),
              if (tabIndex == 0)
                Positioned(
                  bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1B4B),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.barChart2, color: Colors.white, size: 12),
                        const SizedBox(width: 4),
                        Text('Nível $pacienteNivel • $pacientePontos XP', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 8),

          // Presets laterais (clicáveis!)
          Column(
            children: List.generate(AvatarAssets.presetConfigs.length, (i) {
              final presetModel = AvatarAssets.presetModel(i);
              final isActive = avatarAtual.tomPele == presetModel.tomPele &&
                  avatarAtual.estiloCabelo == presetModel.estiloCabelo;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () => setState(() => avatarAtual = presetModel),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isActive ? _primary : const Color(0xFFCBD5E1),
                        width: isActive ? 2.5 : 1.5,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        AvatarAssets.presetPaths[i],
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => const Icon(Icons.person, size: 20),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ============== ABA 1: ROSTO ==============
  Widget _buildAbaRosto() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Formato do rosto
          _buildSectionHeader('Formato do rosto', 'Escolha o formato que mais combina com você'),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 0.72, crossAxisSpacing: 8, mainAxisSpacing: 8),
            itemCount: formatosRosto.length,
            itemBuilder: (context, i) {
              final fmt = formatosRosto[i];
              final sel = avatarAtual.formatoRosto == fmt['id'];
              return _buildSelectionCard(
                selected: sel,
                onTap: () => setState(() => avatarAtual = avatarAtual.copyWith(formatoRosto: fmt['id'] as String)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AvatarWidget(avatar: avatarAtual.copyWith(formatoRosto: fmt['id'] as String), size: 48, showBorder: false),
                    const SizedBox(height: 6),
                    Text(fmt['nome'] as String, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: sel ? _primary : const Color(0xFF0F172A))),
                    Text(fmt['sub'] as String, style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8))),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // Tom de pele
          _buildSectionHeader('Tom de pele', 'Escolha o tom que mais se parece com você'),
          const SizedBox(height: 10),
          _buildColorCircles(
            colors: tonsPele,
            selectedHex: avatarAtual.tomPele,
            onSelect: (hex) => setState(() => avatarAtual = avatarAtual.copyWith(tomPele: hex)),
          ),

          const SizedBox(height: 20),

          // Expressão facial
          _buildSectionHeader('Expressão facial', 'Escolha uma expressão que mais te representa'),
          const SizedBox(height: 10),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: expressoes.length,
              itemBuilder: (context, i) {
                final exp = expressoes[i];
                final sel = avatarAtual.expressao == exp['id'];
                return GestureDetector(
                  onTap: () => setState(() => avatarAtual = avatarAtual.copyWith(expressao: exp['id'])),
                  child: Container(
                    width: 78,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: sel ? const Color(0xFFEEF2FF) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: sel ? _primary : const Color(0xFFE2E8F0), width: sel ? 2 : 1),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (sel) Positioned(top: 4, right: 4, child: _checkBadge(8)),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AvatarWidget(avatar: avatarAtual.copyWith(expressao: exp['id']), size: 44, showBorder: false),
                            const SizedBox(height: 4),
                            Text(exp['nome']!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: sel ? _primary : const Color(0xFF0F172A))),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============== ABA 2: CABELO ==============
  Widget _buildAbaCabelo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Estilo de cabelo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
              GestureDetector(
                onTap: () {},
                child: const Text('Ver mais estilos  >', style: TextStyle(fontSize: 12, color: _primary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, childAspectRatio: 0.75, crossAxisSpacing: 8, mainAxisSpacing: 8),
            itemCount: estilosCabelo.length,
            itemBuilder: (context, i) {
              final est = estilosCabelo[i];
              final sel = avatarAtual.estiloCabelo == est['id'];
              final thumbPath = AvatarAssets.hairThumb(est['id']!);

              return _buildSelectionCard(
                selected: sel,
                onTap: () => setState(() => avatarAtual = avatarAtual.copyWith(estiloCabelo: est['id'])),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: AvatarItemThumb(imagePath: thumbPath, fallbackIcon: LucideIcons.scissors, selected: sel),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(est['nome']!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9, color: sel ? _primary : const Color(0xFF0F172A)), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          const Text('Cor do cabelo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
          const SizedBox(height: 10),
          _buildColorCircles(
            colors: coresCabelo,
            selectedHex: avatarAtual.corCabelo,
            onSelect: (hex) => setState(() => avatarAtual = avatarAtual.copyWith(corCabelo: hex)),
          ),

          const SizedBox(height: 16),

          // Cores especiais
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: const Row(
              children: [
                Icon(LucideIcons.palette, color: Color(0xFF94A3B8), size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cores especiais', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                      Text('Mechas, luzes e cores diferentes', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ),
                Icon(LucideIcons.chevronRight, color: Color(0xFF94A3B8), size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============== ABA 3: ROUPAS ==============
  Widget _buildAbaRoupas() {
    final roupasFiltradas = subcategoriaRoupa == 'Todos'
        ? estilosRoupa
        : estilosRoupa.where((e) => e['cat'] == subcategoriaRoupa).toList();

    return Column(
      children: [
        // Subcategory pills
        _buildSubcategoryPills(
          categorias: categoriasRoupas,
          selecionada: subcategoriaRoupa,
          onSelect: (cat) => setState(() => subcategoriaRoupa = cat),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Grid de roupas com thumbnails de imagem
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, childAspectRatio: 0.65, crossAxisSpacing: 8, mainAxisSpacing: 8),
                  itemCount: roupasFiltradas.length,
                  itemBuilder: (context, i) {
                    final roupa = roupasFiltradas[i];
                    final sel = avatarAtual.estiloRoupa == roupa['id'];
                    final thumbPath = AvatarAssets.clothThumb(roupa['id']!);

                    return _buildSelectionCard(
                      selected: sel,
                      onTap: () => setState(() => avatarAtual = avatarAtual.copyWith(estiloRoupa: roupa['id'])),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: AvatarItemThumb(imagePath: thumbPath, fallbackIcon: LucideIcons.shirt, selected: sel),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(roupa['nome']!, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 9, color: sel ? _primary : const Color(0xFF0F172A)), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),
                const Text('Cor principal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                const SizedBox(height: 10),
                _buildColorCircles(
                  colors: coresRoupa,
                  selectedHex: avatarAtual.corRoupa,
                  onSelect: (hex) => setState(() => avatarAtual = avatarAtual.copyWith(corRoupa: hex)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============== ABA 4: ACESSÓRIOS ==============
  Widget _buildAbaAcessorios() {
    // Agrupar por categoria
    final categoriasExibir = subcategoriaAcessorio == 'Todos'
        ? ['Óculos', 'Fones', 'Chapéus', 'Piercings', 'Colares']
        : [subcategoriaAcessorio];

    return Column(
      children: [
        _buildSubcategoryPills(
          categorias: categoriasAcessorios,
          selecionada: subcategoriaAcessorio,
          onSelect: (cat) => setState(() => subcategoriaAcessorio = cat),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final cat in categoriasExibir) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(cat, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                      const Text('Ver mais  >', style: TextStyle(fontSize: 12, color: _primary, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 95,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: acessoriosGamificados.where((a) => a['cat'] == cat).length,
                      itemBuilder: (context, i) {
                        final acc = acessoriosGamificados.where((a) => a['cat'] == cat).toList()[i];
                        final id = acc['id'] as String;
                        final sel = avatarAtual.acessorios.contains(id) || (id.endsWith('_nenhum') && !avatarAtual.acessorios.any((a) => acessoriosGamificados.any((x) => x['id'] == a && x['cat'] == cat)));
                        final desbloqueado = _itemDesbloqueado(acc);
                        final thumbPath = AvatarAssets.accessoryThumb(id);

                        return GestureDetector(
                          onTap: () {
                            if (id.endsWith('_nenhum')) {
                              // Remove todos dessa categoria
                              final idsCategoria = acessoriosGamificados.where((a) => a['cat'] == cat).map((a) => a['id'] as String).toList();
                              final novaLista = avatarAtual.acessorios.where((a) => !idsCategoria.contains(a)).toList();
                              setState(() => avatarAtual = avatarAtual.copyWith(acessorios: novaLista));
                            } else {
                              _toggleAcessorio(id, desbloqueado, acc['nivelMin'] as int, acc['xpMin'] as int);
                            }
                          },
                          child: Container(
                            width: 72,
                            margin: const EdgeInsets.only(right: 8),
                            child: Column(
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: sel ? const Color(0xFFEEF2FF) : Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: sel ? _primary : const Color(0xFFE2E8F0), width: sel ? 2 : 1),
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      if (sel) Positioned(top: 4, right: 4, child: _checkBadge(8)),
                                      thumbPath != null
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: Image.asset(thumbPath, width: 44, height: 44, fit: BoxFit.cover, errorBuilder: (c, e, s) => Icon(acc['icone'] as IconData, size: 24, color: desbloqueado ? const Color(0xFF475569) : const Color(0xFFCBD5E1))),
                                            )
                                          : Icon(acc['icone'] as IconData, size: 24, color: desbloqueado ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
                                      if (!desbloqueado)
                                        Positioned(bottom: 4, right: 4, child: Icon(LucideIcons.lock, size: 10, color: Colors.red.shade400)),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(acc['nome'] as String, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: desbloqueado ? const Color(0xFF0F172A) : const Color(0xFFCBD5E1)), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============== ABA 5: ESTILO ==============
  Widget _buildAbaEstilo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Resumo do seu Avatar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
          const SizedBox(height: 16),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 180,
                  height: 180,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                  ),
                ),
                AvatarWidget(avatar: avatarAtual, size: 160, showBorder: false),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildResumoItem('Rosto', avatarAtual.formatoRosto),
          _buildResumoItem('Pele', avatarAtual.tomPele),
          _buildResumoItem('Expressão', avatarAtual.expressao),
          _buildResumoItem('Cabelo', avatarAtual.estiloCabelo),
          _buildResumoItem('Cor do Cabelo', avatarAtual.corCabelo),
          _buildResumoItem('Roupa', avatarAtual.estiloRoupa),
          _buildResumoItem('Acessórios', avatarAtual.acessorios.isEmpty ? 'Nenhum' : avatarAtual.acessorios.join(', ')),
        ],
      ),
    );
  }

  Widget _buildResumoItem(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
          Text(valor, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        ],
      ),
    );
  }

  // ============== BOTTOM BAR ==============
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (_tabController.index > 0)
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _tabController.animateTo(_tabController.index - 1);
                      },
                      icon: const Icon(LucideIcons.arrowLeft, size: 18),
                      label: const Text('Voltar', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _primary,
                        side: const BorderSide(color: _primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ),
              if (_tabController.index > 0) const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: salvando
                        ? null
                        : () {
                            if (_tabController.index < 4) {
                              _tabController.animateTo(_tabController.index + 1);
                            } else {
                              _salvarAvatar();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                    ),
                    child: salvando
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_tabController.index < 4 ? 'Continuar' : 'Salvar Avatar', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(width: 8),
                              const Icon(LucideIcons.arrowRight, color: Colors.white, size: 18),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
          if (_tabController.index == 0) ...[
            const SizedBox(height: 6),
            const Text('Você pode mudar seu avatar quando quiser.', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
          ],
        ],
      ),
    );
  }

  // ============== COMPONENTES REUTILIZÁVEIS ==============

  Widget _buildSectionHeader(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
        Flexible(child: Text(subtitle, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)), textAlign: TextAlign.end)),
      ],
    );
  }

  Widget _buildSelectionCard({required bool selected, required VoidCallback onTap, required Widget child}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEEF2FF) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? _primary : const Color(0xFFE2E8F0), width: selected ? 2 : 1),
        ),
        child: Stack(
          children: [
            if (selected) Positioned(top: 6, right: 6, child: _checkBadge(10)),
            Center(child: child),
          ],
        ),
      ),
    );
  }

  Widget _checkBadge(double iconSize) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(color: _primary, shape: BoxShape.circle),
      child: Icon(LucideIcons.check, color: Colors.white, size: iconSize),
    );
  }

  Widget _buildColorCircles({
    required List<Map<String, String>> colors,
    required String selectedHex,
    required ValueChanged<String> onSelect,
  }) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: colors.map((c) {
        final sel = selectedHex == c['hex'];
        final cor = _hexToColor(c['hex']!);
        return GestureDetector(
          onTap: () => onSelect(c['hex']!),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: cor,
              shape: BoxShape.circle,
              border: Border.all(color: sel ? _primary : const Color(0xFFE2E8F0), width: sel ? 3 : 1),
            ),
            child: sel ? Icon(LucideIcons.check, color: cor.computeLuminance() > 0.5 ? _primary : Colors.white, size: 18) : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSubcategoryPills({
    required List<String> categorias,
    required String selecionada,
    required ValueChanged<String> onSelect,
  }) {
    return Container(
      height: 48,
      margin: const EdgeInsets.only(top: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categorias.length,
        itemBuilder: (context, i) {
          final cat = categorias[i];
          final sel = selecionada == cat;
          return GestureDetector(
            onTap: () => onSelect(cat),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: sel ? _primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: sel ? _primary : const Color(0xFFE2E8F0)),
              ),
              alignment: Alignment.center,
              child: Text(cat, style: TextStyle(color: sel ? Colors.white : const Color(0xFF64748B), fontWeight: sel ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
            ),
          );
        },
      ),
    );
  }
}
