import '../../../core/api/api_client.dart';

class PsicologoService {
  Future<Map<String, dynamic>> obterMe() async {
    final response = await ApiClient.dio.get('/Auth/me');
    return Map<String, dynamic>.from(response.data);
  }

  Future<String> obterPsicologoId() async {
    final me = await obterMe();
    final psicologoId = me['psicologoId'];

    if (psicologoId == null || psicologoId.toString().isEmpty) {
      throw Exception('PsicologoId não encontrado para o usuário logado.');
    }

    return psicologoId.toString();
  }

  Future<List<dynamic>> listarPacientesDoPsicologo() async {
    final psicologoId = await obterPsicologoId();

    final response = await ApiClient.dio.get(
      '/Pacientes/psicologo/$psicologoId',
    );

    return List<dynamic>.from(response.data);
  }

  Future<List<dynamic>> listarAtividadesDoPsicologo() async {
    final psicologoId = await obterPsicologoId();

    final response = await ApiClient.dio.get(
      '/Atividades/psicologo/$psicologoId',
    );

    return List<dynamic>.from(response.data);
  }

  Future<dynamic> obterPacientePorId(String pacienteId) async {
    final response = await ApiClient.dio.get('/Pacientes/$pacienteId');
    return response.data;
  }

  Future<List<dynamic>> listarCheckinsPaciente(String pacienteId) async {
    final response = await ApiClient.dio.get(
      '/CheckInsEmocionais/paciente/$pacienteId',
    );

    return List<dynamic>.from(response.data);
  }

  Future<List<dynamic>> listarRegistrosPensamentosPaciente(
    String pacienteId,
  ) async {
    final response = await ApiClient.dio.get(
      '/RegistrosPensamentos/paciente/$pacienteId',
    );

    return List<dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> obterResumoDashboard() async {
    final pacientes = await listarPacientesDoPsicologo();
    final atividades = await listarAtividadesDoPsicologo();

    return {
      'pacientesAtivos': pacientes.length,
      'atividadesEnviadas': atividades.length,
      'pendencias': 0,
      'adesaoMedia': 85,
    };
  }

  Future<void> criarAtividade({
    required String titulo,
    required String descricao,
    required int tipo,
    String? conteudo,
  }) async {
    final psicologoId = await obterPsicologoId();

    await ApiClient.dio.post(
      '/Atividades',
      data: {
        'psicologoId': psicologoId,
        'titulo': titulo,
        'descricao': descricao,
        'tipo': tipo,
        'conteudo': conteudo,
        'ativo': true,
      },
    );
  }

  Future<void> enviarAtividadeParaPaciente({
    required String atividadeId,
    required String pacienteId,
    DateTime? dataLimite,
  }) async {
    await ApiClient.dio.post(
      '/Atividades/enviar',
      data: {
        'atividadeId': atividadeId,
        'pacienteId': pacienteId,
        'dataLimite': dataLimite?.toIso8601String(),
      },
    );
  }
}