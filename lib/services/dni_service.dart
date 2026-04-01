import 'package:dio/dio.dart';
import 'api_cliente.dart';
import 'session_service.dart';

class DniLookupResult {
  final String nombres;
  final String apellidoPaterno;
  final String apellidoMaterno;

  const DniLookupResult({
    required this.nombres,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
  });

  String get nombreCompleto => [
        nombres,
        apellidoPaterno,
        apellidoMaterno,
      ].where((value) => value.trim().isNotEmpty).join(' ');

  factory DniLookupResult.fromMap(Map<String, dynamic> data) {
    return DniLookupResult(
      nombres: (data['first_name'] ?? '').toString(),
      apellidoPaterno: (data['first_last_name'] ?? '').toString(),
      apellidoMaterno: (data['second_last_name'] ?? '').toString(),
    );
  }
}

class DniService {
  final _api = ApiClient().dio;
  final _session = SessionService();

  Future<DniLookupResult?> consultarDni(String dni) async {
    final trimmed = dni.trim();
    if (trimmed.length != 8) return null;

    final user = await _session.getUser();
    if (user == null || user.token.trim().isEmpty) {
      return null;
    }

    try {
      final res = await _api.get(
        '/facturacion/consulta-dni',
        queryParameters: {'numero': trimmed},
      );

      final body = res.data;
      if (body is! Map<String, dynamic>) return null;
      final data = body['data'];
      if (data is! Map<String, dynamic>) return null;
      return DniLookupResult.fromMap(data);
    } on DioException {
      return null;
    }
  }
}
