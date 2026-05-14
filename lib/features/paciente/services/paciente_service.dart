import '../../../core/api/api_client.dart';

class PacienteService {
  Future<Map<String, dynamic>> obterMe() async {
    final response = await ApiClient.dio.get('/Auth/me');
    return Map<String, dynamic>.from(response.data);
  }

  Future<String> obterPacienteId() async {
    final me = await obterMe();

    final pacienteId = me['pacienteId'];

    if (pacienteId == null || pacienteId.toString().isEmpty) {
      throw Exception('PacienteId não encontrado para o usuário logado.');
    }

    return pacienteId.toString();
  }

  Future<List<dynamic>> listarMinhasAtividades() async {
    final pacienteId = await obterPacienteId();

    final response = await ApiClient.dio.get(
      '/Atividades/paciente/$pacienteId',
    );

    return List<dynamic>.from(response.data);
  }

  Future<List<dynamic>> listarMeusCheckins() async {
    final pacienteId = await obterPacienteId();

    final response = await ApiClient.dio.get(
      '/CheckInsEmocionais/paciente/$pacienteId',
    );

    return List<dynamic>.from(response.data);
  }

  Future<bool> verificarCheckinHoje() async {
    final pacienteId = await obterPacienteId();

    final response = await ApiClient.dio.get(
      '/CheckInsEmocionais/status-hoje/$pacienteId',
    );

    return response.data['jaFez'] ?? false;
  }

  Future<List<dynamic>> listarMeusRegistrosPensamentos() async {
    final pacienteId = await obterPacienteId();

    final response = await ApiClient.dio.get(
      '/RegistrosPensamentos/paciente/$pacienteId',
    );

    return List<dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> obterResumoHome() async {
    final atividades = await listarMinhasAtividades();
    final checkins = await listarMeusCheckins();
    final registros = await listarMeusRegistrosPensamentos();

    final concluidas = atividades.where((x) {
      final status = x['status'];

      return status == 2 ||
          status?.toString() == 'Concluida' ||
          status?.toString() == 'Concluído';
    }).length;

    String humorMedio = '-';
    if (checkins.isNotEmpty) {
      final soma = checkins.fold<int>(0, (sum, item) => sum + (item['humor'] as int));
      final media = soma / checkins.length;

      if (media >= 4) {
        humorMedio = 'Ótimo';
      } else if (media >= 3) {
        humorMedio = 'Bom';
      } else if (media >= 2) {
        humorMedio = 'Regular';
      } else {
        humorMedio = 'Ruim';
      }
    }

    return {
      'atividades': atividades.length,
      'concluidas': concluidas,
      'checkins': checkins.length,
      'registros': registros.length,
      'humorMedio': humorMedio,
    };
  }

  Future<void> responderAtividade({
    required String atividadePacienteId,
    required String respostaTexto,
    required int notaHumor,
    }) async {
    await ApiClient.dio.patch(
        '/Atividades/responder',
        data: {
        'atividadePacienteId': atividadePacienteId,
        'respostaTexto': respostaTexto,
        'notaHumor': notaHumor,
        },
    );
   }

  Future<void> criarCheckin({
    required int humor,
    required int intensidade,
    required String emocaoPrincipal,
    String? observacao,
    }) async {
    final pacienteId = await obterPacienteId();

    await ApiClient.dio.post(
        '/CheckInsEmocionais',
        data: {
        'pacienteId': pacienteId,
        'humor': humor,
        'intensidade': intensidade,
        'emocaoPrincipal': emocaoPrincipal,
        'observacao': observacao,
        },
    );
   }

  Future<void> criarRegistroPensamento({
    required String situacao,
    required String pensamentoAutomatico,
    required String emocao,
    required int intensidadeEmocao,
    String? evidenciasAFavor,
    String? evidenciasContra,
    String? pensamentoAlternativo,
    int? intensidadeFinal,
  }) async {
    final pacienteId = await obterPacienteId();

    await ApiClient.dio.post(
      '/RegistrosPensamentos',
      data: {
        'pacienteId': pacienteId,
        'situacao': situacao,
        'pensamentoAutomatico': pensamentoAutomatico,
        'emocao': emocao,
        'intensidadeEmocao': intensidadeEmocao,
        'evidenciasAFavor': evidenciasAFavor,
        'evidenciasContra': evidenciasContra,
        'pensamentoAlternativo': pensamentoAlternativo,
        'intensidadeFinal': intensidadeFinal,
      },
    );
  }
}