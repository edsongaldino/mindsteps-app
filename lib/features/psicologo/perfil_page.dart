import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

import '../../core/auth/auth_storage.dart';
import '../../core/theme/app_theme.dart';
import '../../core/api/api_client.dart';
import '../auth/login_page.dart';
import 'services/psicologo_service.dart';

class PsicologoPerfilPage extends StatefulWidget {
  const PsicologoPerfilPage({super.key});

  @override
  State<PsicologoPerfilPage> createState() => _PsicologoPerfilPageState();
}

class _PsicologoPerfilPageState extends State<PsicologoPerfilPage> {
  final service = PsicologoService();
  late Future<Map<String, dynamic>> meFuture;
  bool _subindoFoto = false;
  String _fotoCacheBuster = '';

  @override
  void initState() {
    super.initState();
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    _fotoCacheBuster = DateTime.now().millisecondsSinceEpoch.toString();
    _carregarDados();
  }

  void _carregarDados() {
    meFuture = service.obterMe().then((dados) async {
      final Map<String, dynamic> merged = Map<String, dynamic>.from(dados);
      final psicologoId = dados['psicologoId'];
      if (psicologoId != null) {
        try {
          final res = await ApiClient.dio.get('/Psicologos/$psicologoId');
          final detail = res.data;
          merged['telefone'] = detail['telefone'] ?? '';
          merged['crp'] = detail['crp'] ?? '';
          merged['bio'] = detail['bio'] ?? '';
        } catch (e) {
          debugPrint('Erro ao carregar dados do psicologo: $e');
        }
      }
      return merged;
    });
  }

  Future<void> _alterarFoto(String usuarioId) async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (file == null) return;

    setState(() => _subindoFoto = true);

    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.name,
        ),
      });

      final response = await ApiClient.dio.post(
        '/Usuarios/$usuarioId/foto',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto de perfil atualizada com sucesso!')),
          );
          PaintingBinding.instance.imageCache.clear();
          PaintingBinding.instance.imageCache.clearLiveImages();
          setState(() {
            _fotoCacheBuster = DateTime.now().millisecondsSinceEpoch.toString();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar foto: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _subindoFoto = false;
          _carregarDados();
        });
      }
    }
  }

  String _obterUrlCompleta(String url) {
    final baseUrl = ApiClient.dio.options.baseUrl;
    final domain = baseUrl.endsWith('/api')
        ? baseUrl.substring(0, baseUrl.length - 4)
        : baseUrl;
    final fullUrl = '$domain$url';
    if (_fotoCacheBuster.isNotEmpty) {
      return '$fullUrl?v=$_fotoCacheBuster';
    }
    return fullUrl;
  }

  Future<void> _sair(BuildContext context) async {
    await AuthStorage.limpar();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  void _abrirMeusDados(Map<String, dynamic> me) {
    final nomeController = TextEditingController(text: me['nome'] ?? '');
    final emailController = TextEditingController(text: me['email'] ?? '');
    final telefoneController = TextEditingController(text: me['telefone'] ?? '');
    final crpController = TextEditingController(text: me['crp'] ?? '');
    final bioController = TextEditingController(text: me['bio'] ?? '');
    final psicologoId = me['psicologoId'];

    bool salvandoDados = false;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Meus dados',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Align(
              alignment: Alignment.centerRight,
              child: Material(
                color: AppColors.background,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    border: Border(left: BorderSide(color: AppColors.border, width: 1)),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Editar Meus Dados',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.text,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(LucideIcons.x, color: AppColors.muted),
                                onPressed: () => Navigator.pop(ctx),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  TextField(
                                    controller: nomeController,
                                    decoration: InputDecoration(
                                      labelText: 'Nome completo',
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide.none,
                                      ),
                                      prefixIcon: const Icon(LucideIcons.user, color: AppColors.muted),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: emailController,
                                    decoration: InputDecoration(
                                      labelText: 'E-mail',
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide.none,
                                      ),
                                      prefixIcon: const Icon(LucideIcons.mail, color: AppColors.muted),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: telefoneController,
                                    keyboardType: TextInputType.phone,
                                    decoration: InputDecoration(
                                      labelText: 'Telefone',
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide.none,
                                      ),
                                      prefixIcon: const Icon(LucideIcons.phone, color: AppColors.muted),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: crpController,
                                    decoration: InputDecoration(
                                      labelText: 'CRP',
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide.none,
                                      ),
                                      prefixIcon: const Icon(LucideIcons.creditCard, color: AppColors.muted),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: bioController,
                                    maxLines: 3,
                                    decoration: InputDecoration(
                                      labelText: 'Biografia',
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide.none,
                                      ),
                                      prefixIcon: const Padding(
                                        padding: EdgeInsets.only(bottom: 30.0),
                                        child: Icon(LucideIcons.fileText, color: AppColors.muted),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: salvandoDados ? null : () => Navigator.pop(ctx),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Text('Cancelar'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: salvandoDados
                                      ? null
                                      : () async {
                                          setDialogState(() => salvandoDados = true);
                                          try {
                                            await ApiClient.dio.put(
                                              '/Psicologos/$psicologoId',
                                              data: {
                                                'nome': nomeController.text.trim(),
                                                'email': emailController.text.trim(),
                                                'telefone': telefoneController.text.trim(),
                                                'crp': crpController.text.trim(),
                                                'bio': bioController.text.trim(),
                                              },
                                            );
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Dados atualizados com sucesso.')),
                                              );
                                              setState(() {
                                                _carregarDados();
                                              });
                                            }
                                            if (ctx.mounted) {
                                              Navigator.pop(ctx);
                                            }
                                          } catch (e) {
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Erro ao salvar dados: $e')),
                                              );
                                            }
                                          } finally {
                                            setDialogState(() => salvandoDados = false);
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: salvandoDados
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                        )
                                      : const Text('Salvar'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOut)),
          child: child,
        );
      },
    );
  }

  void _mostrarPrivacidade() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Privacidade',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: AppColors.background,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              height: double.infinity,
              decoration: const BoxDecoration(
                border: Border(left: BorderSide(color: AppColors.border, width: 1)),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Privacidade',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(LucideIcons.x, color: AppColors.muted),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Seus dados estão protegidos',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'No MindSteps, levamos a sério a segurança das suas informações. Suas anotações clínicas, registros de sentimentos (RPD), e histórico de check-ins são totalmente confidenciais e acessíveis apenas a você e ao seu psicólogo responsável.',
                                style: TextStyle(fontSize: 14, color: AppColors.muted, height: 1.5),
                              ),
                              SizedBox(height: 20),
                              Text(
                                'Lei Geral de Proteção de Dados (LGPD)',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Operamos em total conformidade com a LGPD. Você pode solicitar a exportação ou exclusão dos seus dados a qualquer momento entrando em contato com nosso suporte.',
                                style: TextStyle(fontSize: 14, color: AppColors.muted, height: 1.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOut)),
          child: child,
        );
      },
    );
  }

  void _mostrarAjuda() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Ajuda',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: AppColors.background,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              height: double.infinity,
              decoration: const BoxDecoration(
                border: Border(left: BorderSide(color: AppColors.border, width: 1)),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Ajuda e Suporte',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(LucideIcons.x, color: AppColors.muted),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Suporte do Psicólogo',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Se precisar de suporte com a moderação de pacientes, atribuição de atividades cognitivas ou problemas de instabilidade na plataforma, contate-nos:',
                                style: TextStyle(fontSize: 14, color: AppColors.muted, height: 1.5),
                              ),
                              SizedBox(height: 20),
                              Row(
                                children: [
                                  Icon(LucideIcons.mail, color: AppColors.primary, size: 18),
                                  SizedBox(width: 8),
                                  Text('suporte.clinico@mindsteps.com.br', style: TextStyle(fontSize: 14, color: AppColors.text)),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(LucideIcons.phone, color: AppColors.primary, size: 18),
                                  SizedBox(width: 8),
                                  Text('(11) 98765-4321', style: TextStyle(fontSize: 14, color: AppColors.text)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOut)),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Meu Perfil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: meFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar perfil'));
          }

          final me = snapshot.data ?? {};
          final fotoUrl = me['fotoUrl'];
          final nome = me['nome'] ?? 'Psicólogo';
          final email = me['email'] ?? '';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CardPerfil(
                  nome: nome,
                  email: email,
                  fotoUrl: fotoUrl != null && fotoUrl.toString().isNotEmpty
                      ? _obterUrlCompleta(fotoUrl.toString())
                      : null,
                  onPickFoto: () {
                    final uId = me['usuarioId'];
                    if (uId != null) {
                      _alterarFoto(uId.toString());
                    }
                  },
                  carregando: _subindoFoto,
                ),
                const SizedBox(height: 20),
                _OpcaoPerfil(
                  titulo: 'Meus dados',
                  icone: LucideIcons.user,
                  onTap: () => _abrirMeusDados(me),
                ),
                _OpcaoPerfil(
                  titulo: 'Privacidade',
                  icone: LucideIcons.lock,
                  onTap: _mostrarPrivacidade,
                ),
                _OpcaoPerfil(
                  titulo: 'Ajuda',
                  icone: LucideIcons.circleQuestionMark,
                  onTap: _mostrarAjuda,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _sair(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFE5E5),
                      foregroundColor: AppColors.danger,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: const Icon(LucideIcons.logOut),
                    label: const Text('Sair da conta', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CardPerfil extends StatelessWidget {
  final String nome;
  final String email;
  final String? fotoUrl;
  final VoidCallback onPickFoto;
  final bool carregando;

  const _CardPerfil({
    required this.nome,
    required this.email,
    this.fotoUrl,
    required this.onPickFoto,
    required this.carregando,
  });



  @override
  Widget build(BuildContext context) {
    final inicial = nome.isNotEmpty ? nome.substring(0, 1) : '?';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.softGreen,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  image: fotoUrl != null && fotoUrl!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(fotoUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                alignment: Alignment.center,
                child: fotoUrl != null && fotoUrl!.isNotEmpty
                    ? null
                    : Text(
                        inicial,
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: onPickFoto,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: carregando
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(LucideIcons.camera, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            nome,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _OpcaoPerfil extends StatelessWidget {
  final String titulo;
  final IconData icone;
  final VoidCallback? onTap;

  const _OpcaoPerfil({
    required this.titulo,
    required this.icone,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icone, color: AppColors.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                titulo,
                style: const TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const Icon(
              LucideIcons.chevronRight,
              color: AppColors.muted,
            ),
          ],
        ),
      ),
    );
  }
}
