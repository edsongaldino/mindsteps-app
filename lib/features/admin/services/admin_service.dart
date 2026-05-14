import '../../../core/api/api_client.dart';

class AdminService {
  Future<List<dynamic>> listarUsuarios() async {
    final response = await ApiClient.dio.get('/Usuarios');
    return List<dynamic>.from(response.data);
  }

  Future<List<dynamic>> listarPsicologos() async {
    final response = await ApiClient.dio.get('/Psicologos');
    return List<dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> obterResumo() async {
    final usuarios = await listarUsuarios();
    final psicologos = await listarPsicologos();

    final admins = usuarios.where((u) => u['perfil']?.toString() == 'Administrador' || u['perfil'] == 1).length;
    final pacientes = usuarios.where((u) => u['perfil']?.toString() == 'Paciente' || u['perfil'] == 3).length;
    final psicologosUsuarios = usuarios.where((u) => u['perfil']?.toString() == 'Psicologo' || u['perfil'] == 2).length;

    return {
      'usuarios': usuarios.length,
      'admins': admins,
      'psicologos': psicologosUsuarios,
      'pacientes': pacientes,
      'psicologosCadastrados': psicologos.length,
    };
  }

  Future<void> criarUsuario({
    required String nome,
    required String email,
    required String senha,
    required int perfil,
  }) async {
    await ApiClient.dio.post(
      '/Usuarios',
      data: {
        'nome': nome,
        'email': email,
        'senha': senha,
        'perfil': perfil,
      },
    );
  }

  Future<void> atualizarUsuario({
    required String id,
    required String nome,
    required String email,
    required int perfil,
  }) async {
    await ApiClient.dio.put(
      '/Usuarios/$id',
      data: {
        'nome': nome,
        'email': email,
        'perfil': perfil,
      },
    );
  }

  Future<void> criarPsicologo({
    required String nome,
    required String email,
    required String senha,
    required String crp,
    String? bio,
  }) async {
    await ApiClient.dio.post(
      '/Psicologos',
      data: {
        'nome': nome,
        'email': email,
        'senha': senha,
        'crp': crp,
        'bio': bio,
      },
    );
  }

  Future<void> atualizarPsicologo({
    required String id,
    required String nome,
    required String email,
    required String crp,
    String? bio,
  }) async {
    await ApiClient.dio.put(
      '/Psicologos/$id',
      data: {
        'nome': nome,
        'email': email,
        'crp': crp,
        'bio': bio,
      },
    );
  }

  Future<void> desativarUsuario(String id) async {
    await ApiClient.dio.delete('/Usuarios/$id');
  }
}