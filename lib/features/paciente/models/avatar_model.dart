import 'dart:convert';

class AvatarModel {
  final String tomPele; // Hex: ex '#F5D0A9'
  final String formatoRosto; // 'oval', 'redondo', 'quadrado', 'fino'
  final String estiloCabelo; // 'curto', 'cacheado', 'black_power', 'coque', 'ondulado', 'raspado', 'topete', 'trancas', 'afro_mule', 'chanel', 'franja_lateral', 'espetado', 'maria_chiquinha', 'mohicano', 'careca_barba'
  final String corCabelo; // Hex: ex '#2C1B18'
  final String expressao; // 'alegre', 'confiante', 'calmo', 'determinado', 'sorrindo'
  final String estiloRoupa; // 'casual', 'moletom', 'heroi', 'social', 'esportiva'
  final String corRoupa; // Hex: ex '#4F46E5'
  final List<String> acessorios; // ['oculos_grau', 'fone_gamer', 'coroa', ...]

  const AvatarModel({
    this.tomPele = '#F5D0A9',
    this.formatoRosto = 'oval',
    this.estiloCabelo = 'curto',
    this.corCabelo = '#2C1B18',
    this.expressao = 'alegre',
    this.estiloRoupa = 'casual',
    this.corRoupa = '#4F46E5',
    this.acessorios = const [],
  });

  // Getter para compatibilidade legada com código que lê acessorio único
  String get acessorio => acessorios.isNotEmpty ? acessorios.first : 'nenhum';

  AvatarModel copyWith({
    String? tomPele,
    String? formatoRosto,
    String? estiloCabelo,
    String? corCabelo,
    String? expressao,
    String? estiloRoupa,
    String? corRoupa,
    List<String>? acessorios,
  }) {
    return AvatarModel(
      tomPele: tomPele ?? this.tomPele,
      formatoRosto: formatoRosto ?? this.formatoRosto,
      estiloCabelo: estiloCabelo ?? this.estiloCabelo,
      corCabelo: corCabelo ?? this.corCabelo,
      expressao: expressao ?? this.expressao,
      estiloRoupa: estiloRoupa ?? this.estiloRoupa,
      corRoupa: corRoupa ?? this.corRoupa,
      acessorios: acessorios ?? this.acessorios,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tomPele': tomPele,
      'formatoRosto': formatoRosto,
      'estiloCabelo': estiloCabelo,
      'corCabelo': corCabelo,
      'expressao': expressao,
      'estiloRoupa': estiloRoupa,
      'corRoupa': corRoupa,
      'acessorios': acessorios,
      'acessorio': acessorio,
    };
  }

  factory AvatarModel.fromMap(Map<String, dynamic> map) {
    List<String> listAcessorios = [];
    if (map['acessorios'] is List) {
      listAcessorios = (map['acessorios'] as List).map((e) => e.toString()).where((e) => e != 'nenhum').toList();
    } else if (map['acessorio'] != null) {
      final accStr = map['acessorio'].toString();
      if (accStr != 'nenhum' && accStr.isNotEmpty) {
        listAcessorios = [accStr];
      }
    }

    return AvatarModel(
      tomPele: map['tomPele']?.toString() ?? '#F5D0A9',
      formatoRosto: map['formatoRosto']?.toString() ?? 'oval',
      estiloCabelo: map['estiloCabelo']?.toString() ?? 'curto',
      corCabelo: map['corCabelo']?.toString() ?? '#2C1B18',
      expressao: map['expressao']?.toString() ?? 'alegre',
      estiloRoupa: map['estiloRoupa']?.toString() ?? 'casual',
      corRoupa: map['corRoupa']?.toString() ?? '#4F46E5',
      acessorios: listAcessorios,
    );
  }

  String toJson() => 'avatar:${jsonEncode(toMap())}';

  factory AvatarModel.fromJson(String? source) {
    if (source == null || source.isEmpty) return const AvatarModel();
    try {
      var jsonStr = source;
      if (jsonStr.startsWith('avatar:')) {
        jsonStr = jsonStr.substring(7);
      }
      final decoded = jsonDecode(jsonStr);
      if (decoded is Map<String, dynamic>) {
        return AvatarModel.fromMap(decoded);
      }
    } catch (_) {}
    return const AvatarModel();
  }

  static AvatarModel padrao() => const AvatarModel();
}
