import 'package:flutter/material.dart';
import '../models/avatar_model.dart';

/// Configurações dos 3 presets de avatar com suas imagens correspondentes.
class _AvatarPreset {
  final AvatarModel model;
  final String imagePath;
  const _AvatarPreset(this.model, this.imagePath);
}

/// Mapeamento de configurações do avatar para imagens pré-renderizadas.
class AvatarAssets {
  static const _base = 'assets/avatar';

  /// Os 3 presets disponíveis (com modelo + imagem)
  static final presetConfigs = [
    _AvatarPreset(
      const AvatarModel(tomPele: '#F5D0A9', estiloCabelo: 'curto_ondulado', corCabelo: '#2C1B18', estiloRoupa: 'moletom_mindsteps', corRoupa: '#1F2937', expressao: 'alegre'),
      '$_base/preview/avatar_default.jpg',
    ),
    _AvatarPreset(
      const AvatarModel(tomPele: '#FFDFD3', estiloCabelo: 'longo_liso', corCabelo: '#E5B869', estiloRoupa: 'moletom_basico', corRoupa: '#8B5CF6', expressao: 'calmo'),
      '$_base/preview/avatar_preset_1.jpg',
    ),
    _AvatarPreset(
      const AvatarModel(tomPele: '#583617', estiloCabelo: 'crespo', corCabelo: '#1F2937', estiloRoupa: 'moletom_casual', corRoupa: '#10B981', expressao: 'confiante'),
      '$_base/preview/avatar_preset_2.jpg',
    ),
  ];

  /// Caminhos das imagens de preset (para exibição rápida)
  static List<String> get presetPaths => presetConfigs.map((p) => p.imagePath).toList();

  /// Retorna o AvatarModel do preset pelo índice
  static AvatarModel presetModel(int index) => presetConfigs[index].model;

  /// Determina qual imagem de preview usar baseado no modelo atual.
  /// Verifica se o modelo bate com algum preset, senão usa o default.
  static String previewPath(AvatarModel avatar) {
    // Verifica match com presets por tom de pele + cabelo
    for (final preset in presetConfigs) {
      if (avatar.tomPele == preset.model.tomPele &&
          avatar.estiloCabelo == preset.model.estiloCabelo) {
        return preset.imagePath;
      }
    }
    // Match parcial por tom de pele
    for (final preset in presetConfigs) {
      if (avatar.tomPele == preset.model.tomPele) {
        return preset.imagePath;
      }
    }
    return presetConfigs.first.imagePath;
  }

  /// Thumbnails de cabelo
  static String? hairThumb(String estiloId) {
    const map = {
      'curto_liso': '$_base/hair/curto_liso.jpg',
      'curto_ondulado': '$_base/hair/curto_ondulado.jpg',
    };
    return map[estiloId];
  }

  /// Thumbnails de roupa
  static String? clothThumb(String estiloId) {
    const map = {
      'moletom_mindsteps': '$_base/clothes/moletom_mindsteps.jpg',
      'jaqueta_puffer': '$_base/clothes/jaqueta_puffer.jpg',
      'jaqueta_college': '$_base/clothes/jaqueta_college.jpg',
      'camiseta_basica': '$_base/clothes/camiseta_basica.jpg',
    };
    return map[estiloId];
  }

  /// Thumbnails de acessório
  static String? accessoryThumb(String accId) {
    const map = {
      'oculos_redondo': '$_base/accessories/oculos_redondo.jpg',
      'fone_over_ear': '$_base/accessories/fone_over_ear.jpg',
      'bone_preto': '$_base/accessories/bone_preto.jpg',
    };
    return map[accId];
  }
}

/// Widget principal que exibe o avatar 3D pré-renderizado.
/// Troca a imagem dinamicamente com base na configuração do AvatarModel.
/// Aplica filtros de cor para simular mudanças de tom de pele e expressão.
class AvatarWidget extends StatelessWidget {
  final AvatarModel avatar;
  final double size;
  final bool showBorder;

  const AvatarWidget({
    super.key,
    required this.avatar,
    this.size = 60.0,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = AvatarAssets.previewPath(avatar);

    // Calcula a cor de tint do tom de pele selecionado para dar feedback visual
    final skinColor = _hexToColor(avatar.tomPele);
    final skinBlend = skinColor.withValues(alpha: 0.15); // Tint sutil

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: showBorder
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: ClipOval(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Imagem base do avatar
            Image.asset(
              imagePath,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: size,
                  height: size,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Icon(Icons.person, size: size * 0.5, color: const Color(0xFF4F46E5)),
                );
              },
            ),

            // Overlay de tom de pele (feedback visual sutil)
            Container(
              decoration: BoxDecoration(
                color: skinBlend,
                shape: BoxShape.circle,
              ),
            ),

            // Indicador de expressão (emoji sutil no canto inferior)
            if (size >= 80)
              Positioned(
                bottom: size * 0.02,
                right: size * 0.02,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)],
                  ),
                  child: Text(
                    _expressionEmoji(avatar.expressao),
                    style: TextStyle(fontSize: size * 0.1),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _expressionEmoji(String expressao) {
    switch (expressao) {
      case 'alegre': return '😄';
      case 'confiante': return '😎';
      case 'determinado': return '💪';
      case 'sorrindo': return '😌';
      default: return '😊';
    }
  }

  Color _hexToColor(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return const Color(0xFFF5D0A9);
    }
  }
}

/// Widget auxiliar para exibir uma thumbnail de item (roupa, acessório, cabelo)
/// a partir de um asset de imagem, com fallback para ícone.
class AvatarItemThumb extends StatelessWidget {
  final String? imagePath;
  final IconData fallbackIcon;
  final double size;
  final bool selected;

  const AvatarItemThumb({
    super.key,
    this.imagePath,
    required this.fallbackIcon,
    this.size = 60,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          imagePath!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _fallback(),
        ),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        fallbackIcon,
        size: size * 0.4,
        color: selected ? const Color(0xFF4F46E5) : const Color(0xFF94A3B8),
      ),
    );
  }
}