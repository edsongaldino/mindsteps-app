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
}