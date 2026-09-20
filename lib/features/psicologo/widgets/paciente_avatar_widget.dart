import 'package:flutter/material.dart';

import '../../../core/api/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../paciente/models/avatar_model.dart';
import '../../paciente/widgets/avatar_widget.dart';

/// Widget para exibir o avatar ou foto do paciente de forma padronizada.
/// Suporta:
/// 1. Avatar 3D customizado salvo como 'avatar:{...}' ou JSON com atributos
/// 2. Foto de perfil via URL externa (HTTP/HTTPS) ou caminho relativo da API
/// 3. Fallback elegante para inicial do nome caso não possua foto/avatar
class PacienteAvatarWidget extends StatelessWidget {
  final String? fotoUrl;
  final String nome;
  final double radius;
  final bool showBorder;

  const PacienteAvatarWidget({
    super.key,
    required this.fotoUrl,
    required this.nome,
    this.radius = 24.0,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    final inicial = nome.trim().isNotEmpty
        ? nome.trim().characters.first.toUpperCase()
        : '?';

    // 1. Avatar 3D customizado do app
    if (_isAvatar(fotoUrl)) {
      final avatarModel = AvatarModel.fromJson(fotoUrl);
      return SizedBox(
        width: size,
        height: size,
        child: AvatarWidget(
          avatar: avatarModel,
          size: size,
          showBorder: showBorder,
        ),
      );
    }

    // 2. Foto via URL de internet (HTTP / HTTPS / path relativo da API)
    final imageUrl = _obterUrlCompleta(fotoUrl);
    if (imageUrl != null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.softGreen,
          border: showBorder ? Border.all(color: Colors.white, width: 2) : null,
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
          child: Image.network(
            imageUrl,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildFallback(inicial, size);
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: size,
                height: size,
                color: AppColors.softGreen,
                alignment: Alignment.center,
                child: SizedBox(
                  width: size * 0.4,
                  height: size * 0.4,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.secondary,
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    // 3. Fallback com inicial do nome
    return _buildFallback(inicial, size);
  }

  Widget _buildFallback(String inicial, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.softGreen,
        shape: BoxShape.circle,
        border: showBorder ? Border.all(color: Colors.white, width: 2) : null,
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
      alignment: Alignment.center,
      child: Text(
        inicial,
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.42,
        ),
      ),
    );
  }

  static bool _isAvatar(String? url) {
    if (url == null || url.trim().isEmpty) return false;
    final trimmed = url.trim();
    return trimmed.startsWith('avatar:') ||
        (trimmed.startsWith('{') && trimmed.contains('"tomPele"'));
  }

  static String? _obterUrlCompleta(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    final trimmed = url.trim();
    if (_isAvatar(trimmed)) return null;

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    try {
      final baseUrl = ApiClient.dio.options.baseUrl;
      final domain = baseUrl.endsWith('/api')
          ? baseUrl.substring(0, baseUrl.length - 4)
          : baseUrl;
      final path = trimmed.startsWith('/') ? trimmed : '/$trimmed';
      return '$domain$path';
    } catch (_) {
      return trimmed;
    }
  }
}
