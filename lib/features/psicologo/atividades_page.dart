import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import 'services/psicologo_service.dart';
import 'criar_atividade_wizard_page.dart';

class AtividadesPage extends StatefulWidget {
  const AtividadesPage({super.key});

  @override
  State<AtividadesPage> createState() => AtividadesPageState();
}

class AtividadesPageState extends State<AtividadesPage> {
  final service = PsicologoService();

  late Future<List<dynamic>> atividadesFuture;
  List<dynamic> todosPacientes = [];
  bool carregandoPacientes = false;

  @override
  void initState() {
    super.initState();
    atividadesFuture = service.listarAtividadesDoPsicologo();
    _carregarPacientes();
  }

  Future<void> _carregarPacientes() async {
    try {
      final lista = await service.listarPacientesDoPsicologo();
      setState(() {
        todosPacientes = lista;
      });
    } catch (e) {
      debugPrint('Erro ao carregar pacientes: $e');
    }
  }

  Future<void> _recarregar() async {
    setState(() {
      atividadesFuture = service.listarAtividadesDoPsicologo();
    });
  }

  void exibirDetalhesEReenviar(BuildContext context, Map<String, dynamic> atividade) {
    String? pacienteSelecionadoId = todosPacientes.isNotEmpty ? 'todos' : null;
    DateTime? dataLimite = DateTime.now().add(const Duration(days: 7));
    bool reenviando = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 32),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Topo Detalhe
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.softGreen,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(LucideIcons.clipboardList, color: AppColors.primary, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                atividade['titulo'] ?? 'Atividade',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tipo: ${_getTipoTexto(atividade['tipo'])}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Descrição
                    const Text(
                      'Descrição da atividade',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.text),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      atividade['descricao'] ?? 'Sem descrição.',
                      style: const TextStyle(fontSize: 13, color: AppColors.muted, height: 1.4),
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: AppColors.border),
                    const SizedBox(height: 14),

                    // Seção de Reenvio / Reuso
                    const Text(
                      '🔄 Reenviar Atividade',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Selecione o paciente e configure para enviar novamente esta atividade.',
                      style: TextStyle(fontSize: 12, color: AppColors.muted),
                    ),
                    const SizedBox(height: 20),

                    // Seleção do Destinatário
                    const Text(
                      'Enviar para:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.text),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(color: const Color(0xFFF4F6F9), borderRadius: BorderRadius.circular(12)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: pacienteSelecionadoId,
                          isExpanded: true,
                          icon: const Icon(LucideIcons.chevronDown, color: AppColors.muted),
                          items: [
                            const DropdownMenuItem(
                              value: 'todos',
                              child: Text('Todos os pacientes ativos'),
                            ),
                            ...todosPacientes.map((p) => DropdownMenuItem(
                                  value: p['id']?.toString(),
                                  child: Text(p['nome']?.toString() ?? 'Paciente'),
                                )),
                          ],
                          onChanged: (val) {
                            setModalState(() => pacienteSelecionadoId = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Escolher Data Limite
                    const Text(
                      'Prazo de entrega (opcional):',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.text),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final data = await showDatePicker(
                          context: context,
                          initialDate: dataLimite ?? DateTime.now().add(const Duration(days: 7)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (data != null) {
                          setModalState(() => dataLimite = data);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(color: const Color(0xFFF4F6F9), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.calendar, color: AppColors.primary, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              dataLimite == null
                                  ? 'Sem data limite'
                                  : '${dataLimite!.day.toString().padLeft(2, '0')}/${dataLimite!.month.toString().padLeft(2, '0')}/${dataLimite!.year}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.text),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Botão Ação
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: reenviando || pacienteSelecionadoId == null
                            ? null
                            : () async {
                                setModalState(() => reenviando = true);
                                try {
                                  final String atividadeId = atividade['id'].toString();

                                  if (pacienteSelecionadoId == 'todos') {
                                    // Loop e envia para todos
                                    for (var pac in todosPacientes) {
                                      await service.enviarAtividadeParaPaciente(
                                        atividadeId: atividadeId,
                                        pacienteId: pac['id'].toString(),
                                        dataLimite: dataLimite,
                                      );
                                    }
                                  } else {
                                    // Envia para o específico
                                    await service.enviarAtividadeParaPaciente(
                                      atividadeId: atividadeId,
                                      pacienteId: pacienteSelecionadoId!,
                                      dataLimite: dataLimite,
                                    );
                                  }

                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Atividade reenviada com sucesso!')),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Erro ao reenviar: $e')),
                                    );
                                  }
                                } finally {
                                  setModalState(() => reenviando = false);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: reenviando
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Reenviar Atividade'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _getTipoTexto(dynamic tipoVal) {
    final t = tipoVal?.toString() ?? '1';
    switch (t) {
      case '1':
        return 'Reflexão';
      case '2':
        return 'Registro de pensamentos';
      case '3':
        return 'Exercício prático';
      case '4':
        return 'Check-list';
      case '5':
        return 'Áudio';
      case '6':
        return 'Leitura';
      default:
        return 'Reflexão';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: atividadesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Text(
                'Erro ao carregar atividades: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final atividades = snapshot.data ?? [];

        return RefreshIndicator(
          onRefresh: _recarregar,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Atividades',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Crie e acompanhe exercícios terapêuticos.',
                  style: TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 20),

                if (atividades.isEmpty)
                  const Text(
                    'Nenhuma atividade encontrada.',
                    style: TextStyle(color: AppColors.muted),
                  ),

                ...atividades.map((atividade) {
                  return _AtividadeCard(
                    titulo: atividade['titulo'] ?? 'Atividade',
                    descricao: atividade['descricao'] ?? 'Sem descrição',
                    tipo: _getTipoTexto(atividade['tipo']),
                    onTap: () => exibirDetalhesEReenviar(context, atividade),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void exibirDialogoCriar(BuildContext context) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CriarAtividadeWizardPage()),
    );
    if (resultado == true) {
      _recarregar();
    }
  }
}

class _AtividadeCard extends StatelessWidget {
  final String titulo;
  final String descricao;
  final String tipo;
  final VoidCallback onTap;

  const _AtividadeCard({
    required this.titulo,
    required this.descricao,
    required this.tipo,
    required this.onTap,
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
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.softGreen,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                LucideIcons.clipboardList,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    descricao,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tipo: $tipo',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
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
      ),
    );
  }
}