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

    int totalAtividades = 0;
    int totalConcluidas = 0;

    for (var a in atividades) {
      final status = a['status'];
      totalAtividades++;
      if (status == 2 ||
          status?.toString().toLowerCase() == 'concluida' ||
          status?.toString().toLowerCase() == 'concluído') {
        totalConcluidas++;
      }
    }

    final pendencias = totalAtividades - totalConcluidas;
    final adesaoMedia =
        totalAtividades > 0 ? (totalConcluidas / totalAtividades * 100).round() : 0;

    return {
      'pacientesAtivos': pacientes.length,
      'atividadesEnviadas': totalAtividades,
      'pendencias': pendencias,
      'adesaoMedia': adesaoMedia,
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

  Future<void> criarPaciente({
    required String nome,
    required String email,
    required String senha,
    DateTime? dataNascimento,
    String? genero,
  }) async {
    final psicologoId = await obterPsicologoId();

    await ApiClient.dio.post(
      '/Pacientes',
      data: {
        'psicologoId': psicologoId,
        'nome': nome,
        'email': email,
        'senha': senha,
        'dataNascimento': dataNascimento?.toIso8601String(),
        'genero': genero,
      },
    );
  }

  Future<void> atualizarPaciente({
    required String id,
    required String nome,
    required String email,
    DateTime? dataNascimento,
    String? genero,
  }) async {
    await ApiClient.dio.put(
      '/Pacientes/$id',
      data: {
        'nome': nome,
        'email': email,
        'dataNascimento': dataNascimento?.toIso8601String(),
        'genero': genero,
      },
    );
  }

  Future<void> desativarPaciente(String id) async {
    await ApiClient.dio.delete('/Pacientes/$id');
  }
}