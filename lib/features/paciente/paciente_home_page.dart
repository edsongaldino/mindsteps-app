import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import 'paciente_atividades_page.dart';
import 'paciente_checkin_page.dart';
import 'paciente_evolucao_page.dart';
import 'paciente_perfil_page.dart';
import 'paciente_registro_pensamento_page.dart';
import 'services/paciente_service.dart';

class PacienteHomePage extends StatefulWidget {
  const PacienteHomePage({super.key});

  @override
  State<PacienteHomePage> createState() => PacienteHomePageState();
}

class PacienteHomePageState extends State<PacienteHomePage> {
  int paginaAtual = 0;

  void mudarPagina(int index) {
    setState(() => paginaAtual = index);
  }

  List<Widget> get _paginas => [
    _DashboardPaciente(isActive: paginaAtual == 0),
    PacienteAtividadesPage(isActive: paginaAtual == 1),
    const PacienteCheckinPage(),
    PacienteEvolucaoPage(isActive: paginaAtual == 3),
    const PacientePerfilPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: IndexedStack(
          index: paginaAtual,
          children: _paginas,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: paginaAtual,
        onDestinationSelected: (index) {
          setState(() => paginaAtual = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(LucideIcons.house),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.clipboardList),
            label: 'Atividades',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.heartPulse),
            label: 'Check-in',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.chartNoAxesColumn),
            label: 'Evolução',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.user),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class _DashboardPaciente extends StatefulWidget {
  final bool isActive;
  const _DashboardPaciente({this.isActive = false});

  @override
  State<_DashboardPaciente> createState() => _DashboardPacienteState();
}

class _DashboardPacienteState extends State<_DashboardPaciente> {
  @override
  void didUpdateWidget(covariant _DashboardPaciente oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _recarregar();
    }
  }
  final service = PacienteService();

  late Future<Map<String, dynamic>> resumoFuture;

  @override
  void initState() {
    super.initState();
    resumoFuture = service.obterResumoHome();
    _verificarCheckinHoje();
  }

  Future<void> _verificarCheckinHoje() async {
    try {
      final jaFez = await service.verificarCheckinHoje();
      if (!jaFez && mounted) {
        // Redireciona para a página de check-in (índice 2)
        final state = context.findAncestorStateOfType<PacienteHomePageState>();
        state?.mudarPagina(2);
      }
    } catch (e) {
      debugPrint('Erro ao verificar check-in hoje: $e');
    }
  }

  Future<void> _recarregar() async {
    setState(() {
      resumoFuture = service.obterResumoHome();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: resumoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Text(
                'Erro ao carregar dados: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final resumo = snapshot.data ?? {};

        return RefreshIndicator(
          onRefresh: _recarregar,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TopoPaciente(
                  nome: resumo['nome'] ?? '',
                  notificacoes: resumo['notificacoes'] ?? [],
                  onRefresh: _recarregar,
                ),
                const SizedBox(height: 22),
                _CardGamificacao(
                  pontos: resumo['pontos'] ?? 0,
                  nivel: resumo['nivel'] ?? 1,
                ),
                const SizedBox(height: 22),
                _CardMensagemDia(
                  mensagem: resumo['mensagemMotivacional'],
                  onMarcarComoLida: () async {
                    try {
                      final msg = resumo['mensagemMotivacional'];
                      if (msg != null && msg['id'] != null) {
                        await service.marcarMensagemComoLida(msg['id'].toString());
                        _recarregar();
                      }
                    } catch (e) {
                      debugPrint('Erro ao marcar mensagem como lida: $e');
                    }
                  },
                ),
                const SizedBox(height: 22),

                _GridResumoPaciente(
                  atividades: resumo['atividades'] ?? 0,
                  concluidas: resumo['concluidas'] ?? 0,
                  checkins: resumo['checkins'] ?? 0,
                  humorMedio: resumo['humorMedio'] ?? '-',
                ),

                const SizedBox(height: 22),
                const _CardAtividadeHoje(),
                const SizedBox(height: 18),
                _BotaoPrincipal(
                  texto: 'Registrar pensamento (TCC)',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PacienteRegistroPensamentoPage(),
                      ),
                    ).then((_) => _recarregar());
                  },
                  cor: AppColors.softPurple,
                ),
                const SizedBox(height: 12),
                _BotaoPrincipal(
                  texto: 'Fazer check-in agora',
                  onPressed: () {
                    final state = context.findAncestorStateOfType<PacienteHomePageState>();
                    state?.mudarPagina(2);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TopoPaciente extends StatelessWidget {
  final String nome;
  final List<dynamic> notificacoes;
  final VoidCallback onRefresh;

  const _TopoPaciente({
    required this.nome,
    required this.notificacoes,
    required this.onRefresh,
  });

  void _mostrarNotificacoes(BuildContext context) {
    final homeState = context.findAncestorStateOfType<PacienteHomePageState>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Notificações',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, color: AppColors.muted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (notificacoes.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.0),
                  child: Center(
                    child: Text(
                      'Nenhuma notificação nova no momento.',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: notificacoes.length,
                    itemBuilder: (context, index) {
                      final item = notificacoes[index];
                      final isMessage = item['tipo'] == 'message';
                      
                      final action = () async {
                        Navigator.pop(context);
                        if (isMessage) {
                          // Mark as read and reload
                          await PacienteService().marcarMensagemComoLida(item['id']);
                        } else {
                          // Direct to activities tab
                          homeState?.mudarPagina(1);
                        }
                        onRefresh();
                      };

                      return GestureDetector(
                        onTap: action,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isMessage ? AppColors.softPurple : AppColors.softGreen,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  isMessage ? LucideIcons.messageSquare : LucideIcons.clipboardCheck,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['titulo'] ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.text,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['conteudo'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.primary),
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nome.isNotEmpty ? 'Olá, $nome!' : 'Olá!',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Como você está se sentindo hoje?',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () => _mostrarNotificacoes(context),
              icon: const Icon(
                LucideIcons.bell,
                color: AppColors.text,
                size: 26,
              ),
            ),
            if (notificacoes.isNotEmpty)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '${notificacoes.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _CardGamificacao extends StatelessWidget {
  final int pontos;
  final int nivel;

  const _CardGamificacao({
    required this.pontos,
    required this.nivel,
  });

  @override
  Widget build(BuildContext context) {
    final pontosNoNivel = pontos % 100;
    final progresso = pontosNoNivel / 100.0;
    final pontosParaProximoNivel = 100 - pontosNoNivel;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF8E2DE2),
            Color(0xFF4A00E0),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A00E0).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.star,
                      color: Colors.amber,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Nível $nivel',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              Text(
                '$pontos XP',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progresso,
              backgroundColor: Colors.white.withOpacity(0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Faltam $pontosParaProximoNivel XP para o Nível ${nivel + 1} 🚀',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardMensagemDia extends StatelessWidget {
  final Map<String, dynamic>? mensagem;
  final VoidCallback? onMarcarComoLida;

  const _CardMensagemDia({this.mensagem, this.onMarcarComoLida});

  @override
  Widget build(BuildContext context) {
    final temMensagem = mensagem != null;
    final conteudo = temMensagem
        ? mensagem!['conteudo'] ?? ''
        : 'Hoje você não precisa resolver tudo.';
    final titulo = temMensagem
        ? 'Recado da Dra. ${mensagem!['psicologoNome'] ?? 'Psicóloga'}'
        : 'Um passo de cada vez.';
    final lida = temMensagem ? (mensagem!['lida'] ?? true) : true;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: temMensagem && !lida ? AppColors.softPurple : AppColors.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                temMensagem ? LucideIcons.messageSquareQuote : LucideIcons.sparkles,
                color: temMensagem && !lida ? AppColors.primary : Colors.white,
                size: 30,
              ),
              if (temMensagem && !lida)
                GestureDetector(
                  onTap: onMarcarComoLida,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(LucideIcons.check, color: Colors.white, size: 12),
                        SizedBox(width: 4),
                        Text(
                          'Marcar como lida',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            titulo,
            style: TextStyle(
              color: temMensagem && !lida ? AppColors.text : Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            conteudo,
            style: TextStyle(
              color: temMensagem && !lida ? AppColors.text.withOpacity(0.8) : Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _GridResumoPaciente extends StatelessWidget {
  final int atividades;
  final int concluidas;
  final int checkins;
  final String humorMedio;

  const _GridResumoPaciente({
    required this.atividades,
    required this.concluidas,
    required this.checkins,
    required this.humorMedio,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.25,
      children: [
        _CardResumoPaciente(
          valor: '$atividades',
          titulo: 'Atividades',
          icone: LucideIcons.clipboardList,
          cor: AppColors.softGreen,
        ),
        _CardResumoPaciente(
          valor: '$concluidas',
          titulo: 'Concluídas',
          icone: LucideIcons.circleCheck,
          cor: AppColors.softBlue,
        ),
        _CardResumoPaciente(
          valor: '$checkins',
          titulo: 'Check-ins',
          icone: LucideIcons.heartPulse,
          cor: AppColors.softOrange,
        ),
        _CardResumoPaciente(
          valor: humorMedio,
          titulo: 'Humor médio',
          icone: LucideIcons.smile,
          cor: AppColors.softPurple,
        ),
      ],
    );
  }
}

class _CardResumoPaciente extends StatelessWidget {
  final String valor;
  final String titulo;
  final IconData icone;
  final Color cor;

  const _CardResumoPaciente({
    required this.valor,
    required this.titulo,
    required this.icone,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: cor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icone,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardAtividadeHoje extends StatelessWidget {
  const _CardAtividadeHoje();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.softGreen,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              LucideIcons.bookOpen,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Atividade de hoje',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Continue avançando no seu processo.',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            LucideIcons.chevronRight,
            color: AppColors.muted,
          ),
        ],
      ),
    );
  }
}

class _BotaoPrincipal extends StatelessWidget {
  final String texto;
  final VoidCallback onPressed;
  final Color? cor;

  const _BotaoPrincipal({
    required this.texto,
    required this.onPressed,
    this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: cor != null
            ? ElevatedButton.styleFrom(
                backgroundColor: cor,
                foregroundColor: AppColors.primary,
                elevation: 0,
              )
            : null,
        child: Text(texto),
      ),
    );
  }
}