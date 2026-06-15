import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import 'jogos/detetive_pensamentos_page.dart';
import 'jogos/tribunal_pensamentos_page.dart';
import 'jogos/cacador_gatilhos_page.dart';
import 'jogos/missao_coragem_page.dart';
import 'jogos/monstro_ansiedade_page.dart';
import 'jogos/ilha_emocoes_page.dart';
import 'jogos/decisao_pressao_page.dart';
import 'jogos/missao_foco_page.dart';
import 'jogos/memoria_tatica_page.dart';
import 'jogos/jogo_memoria_page.dart';
import 'jogos/investigacao_page.dart';
import 'jogos/modo_piloto_page.dart';
import 'jogos/laboratorio_mental_page.dart';
import 'jogos/mente_flexivel_page.dart';
import 'jogos/shark_mind_page.dart';
import 'jogos/universos_paralelos_page.dart';
import 'jogos/reacao_zero_page.dart';
import 'jogos/cartas_sabotadores_page.dart';
import 'jogos/escape_room_page.dart';
import 'jogos/heroi_interior_page.dart';
import 'paciente_atividades_page.dart';

class PacienteJogosPage extends StatefulWidget {
  final bool isActive;
  const PacienteJogosPage({super.key, this.isActive = false});

  @override
  State<PacienteJogosPage> createState() => _PacienteJogosPageState();
}

class _PacienteJogosPageState extends State<PacienteJogosPage> {
  final List<Map<String, dynamic>> jogosList = [
    {
      'id': 'decisao_pressao',
      'titulo': 'Decisão Sob Pressão',
      'subtitulo': 'Evitar reações emocionais impulsivas',
      'icone': LucideIcons.hourglass,
      'corFundo': const Color(0xFF0F2C59),
      'builder': (context) => const DecisaoSobPressaoPage(),
    },
    {
      'id': 'missao_foco',
      'titulo': 'Missão Foco',
      'subtitulo': 'Ignorar distrações e focar no alvo',
      'icone': LucideIcons.target,
      'corFundo': const Color(0xFF1B365D),
      'builder': (context) => const MissaoFocoPage(),
    },
    {
      'id': 'memoria_tatica',
      'titulo': 'Memória Tática',
      'subtitulo': 'Observe e identifique o objeto que desapareceu',
      'icone': LucideIcons.folderHeart,
      'corFundo': const Color(0xFF0F4C5C),
      'builder': (context) => const MemoriaTaticaPage(),
    },
    {
      'id': 'investigacao',
      'titulo': 'Investigação',
      'subtitulo': 'Responder com base em depoimentos',
      'icone': LucideIcons.searchCode,
      'corFundo': const Color(0xFF5C3D2E),
      'builder': (context) => const InvestigacaoPage(),
    },
    {
      'id': 'modo_piloto',
      'titulo': 'Modo Piloto',
      'subtitulo': 'Seguir o checklist de desaceleração',
      'icone': LucideIcons.shieldCheck,
      'corFundo': const Color(0xFF3F37C9),
      'builder': (context) => const ModoPilotoPage(),
    },
    {
      'id': 'laboratorio_mental',
      'titulo': 'Laboratório Mental',
      'subtitulo': 'Modificar letras para formar palavras',
      'icone': LucideIcons.flaskConical,
      'corFundo': const Color(0xFF4CC9F0),
      'builder': (context) => const LaboratorioMentalPage(),
    },
    {
      'id': 'mente_flexivel',
      'titulo': 'Mente Flexível',
      'subtitulo': 'Seguir regras que mudam de repente',
      'icone': LucideIcons.shuffle,
      'corFundo': const Color(0xFF7209B7),
      'builder': (context) => const MenteFlexivelPage(),
    },
    {
      'id': 'shark_mind',
      'titulo': 'Shark Mind',
      'subtitulo': 'Gravar pitch criativo de vendas',
      'icone': LucideIcons.speech,
      'corFundo': const Color(0xFFF77F00),
      'builder': (context) => const SharkMindPage(),
    },
    {
      'id': 'universos_paralelos',
      'titulo': 'Universos Paralelos',
      'subtitulo': 'Criar respostas para cenários E se...',
      'icone': LucideIcons.globe,
      'corFundo': const Color(0xFFD62828),
      'builder': (context) => const UniversosParalelosPage(),
    },
    {
      'id': 'reacao_zero',
      'titulo': 'Reação Zero',
      'subtitulo': 'Reagir ou congelar conforme o sinal',
      'icone': LucideIcons.zap,
      'corFundo': const Color(0xFF00F5D4),
      'builder': (context) => const ReacaoZeroPage(),
    },
    {
      'id': 'detetive_pensamentos',
      'titulo': 'Detetive dos Pensamentos',
      'subtitulo': 'Identificar e reestruturar pensamentos',
      'icone': LucideIcons.search,
      'corFundo': const Color(0xFF0D9488),
      'builder': (context) => const DetetivePensamentosPage(),
    },
    {
      'id': 'tribunal_pensamentos',
      'titulo': 'Tribunal dos Pensamentos',
      'subtitulo': 'Julgar pensamentos com base em evidências',
      'icone': LucideIcons.scale,
      'corFundo': const Color(0xFF4F46E5),
      'builder': (context) => const TribunalPensamentosPage(),
    },
    {
      'id': 'cacador_gatilhos',
      'titulo': 'Caçador de Gatilhos',
      'subtitulo': 'Identificar gatilhos situacionais e físicos',
      'icone': LucideIcons.radar,
      'corFundo': const Color(0xFFE11D48),
      'builder': (context) => const CacadorGatilhosPage(),
    },
    {
      'id': 'missao_coragem',
      'titulo': 'Missão Coragem',
      'subtitulo': 'Enfrentar medos através de exposição',
      'icone': LucideIcons.shieldAlert,
      'corFundo': const Color(0xFFD97706),
      'builder': (context) => const MissaoCoragemPage(),
    },
    {
      'id': 'monstro_ansiedade',
      'titulo': 'O Monstro da Ansiedade',
      'subtitulo': 'Externalizar e desenhar sua ansiedade',
      'icone': LucideIcons.ghost,
      'corFundo': const Color(0xFF7C3AED),
      'builder': (context) => const MonstroAnsiedadePage(),
    },
    {
      'id': 'ilha_emocoes',
      'titulo': 'Ilha das Emoções',
      'subtitulo': 'Classificar sentimentos navegando em ilhas',
      'icone': LucideIcons.palmtree,
      'corFundo': const Color(0xFF059669),
      'builder': (context) => const IlhaEmocoesPage(),
    },
    {
      'id': 'cartas_sabotadores',
      'titulo': 'Cartas dos Sabotadores',
      'subtitulo': 'Identificar pensamentos e condutas sabotadoras',
      'icone': LucideIcons.copy,
      'corFundo': const Color(0xFFDB2777),
      'builder': (context) => const CartasSabotadoresPage(),
    },
    {
      'id': 'escape_room',
      'titulo': 'Escape Room Terapêutico',
      'subtitulo': 'Decifrar distorções cognitivas em enigmas',
      'icone': LucideIcons.doorOpen,
      'corFundo': const Color(0xFF4B5563),
      'builder': (context) => const EscapeRoomPage(),
    },
    {
      'id': 'heroi_interior',
      'titulo': 'Jornada do Herói Interior',
      'subtitulo': 'Traçar metas e virtudes em uma jornada',
      'icone': LucideIcons.compass,
      'corFundo': const Color(0xFF2563EB),
      'builder': (context) => const HeroiInteriorPage(),
    },
    {
      'id': 'jogo_memoria',
      'titulo': 'Jogo de Memória',
      'subtitulo': 'Encontre todos os pares de cartas e emoções',
      'icone': LucideIcons.grid,
      'corFundo': const Color(0xFF0F766E),
      'builder': (context) => const JogoMemoriaPage(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Jogos Terapêuticos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              itemCount: jogosList.length,
              itemBuilder: (context, index) {
                final jogo = jogosList[index];
                return _buildJogoCard(
                  titulo: jogo['titulo'],
                  subtitulo: jogo['subtitulo'],
                  icone: jogo['icone'],
                  corFundo: jogo['corFundo'],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: jogo['builder']),
                    );
                  },
                );
              },
            ),
          ),
          _buildPrescriptionBar(),
        ],
      ),
    );
  }

  Widget _buildJogoCard({
    required String titulo,
    required String subtitulo,
    required IconData icone,
    required Color corFundo,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: corFundo,
            shape: BoxShape.circle,
          ),
          child: Icon(icone, color: AppColors.primary, size: 24),
        ),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.text),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            subtitulo,
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ),
        trailing: const Icon(LucideIcons.chevronRight, color: AppColors.muted),
        onTap: onTap,
      ),
    );
  }

  Widget _buildPrescriptionBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            const Icon(LucideIcons.lightbulb, color: Colors.amber, size: 24),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Prescrição Terapêutica: seu psicólogo indicou jogos específicos para você!',
                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500, height: 1.3),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PacienteAtividadesPage()),
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.15),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Ver', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
