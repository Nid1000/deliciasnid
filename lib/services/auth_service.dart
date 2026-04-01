import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/app_user.dart';
import 'api_cliente.dart';
import 'api_endpoints.dart';
import 'session_service.dart';

class AuthService {
  final Dio _api = ApiClient().dio;
  final SessionService _session = SessionService();

  Future<AppUser> login(String email, String password) async {
    try {
      final res = await _postFirstAvailable(
        ApiEndpoints.loginCandidates,
        data: {'email': email, 'password': password},
      );

      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception('No se pudo iniciar sesión.');
      }

      final data = _normalize(res.data);
      final user = AppUser.fromApi(data);
      await _session.saveUser(user);
      return user;
    } on DioException catch (e) {
      throw Exception(_errorMessage(e, fallback: 'No se pudo iniciar sesión.'));
    }
  }

  Future<void> register({
    required String nombre,
    required String apellido,
    required String telefono,
    required String direccion,
    required String distrito,
    required String email,
    required String password,
  }) async {
    try {
      final res = await _postFirstAvailable(
        ApiEndpoints.registerCandidates,
        data: {
          'nombre': nombre,
          'apellido': apellido,
          'telefono': telefono,
          'direccion': direccion,
          'distrito': distrito,
          'email': email,
          'password': password,
        },
      );

      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception('No se pudo registrar el usuario.');
      }
    } on DioException catch (e) {
      throw Exception(
        _errorMessage(e, fallback: 'No se pudo registrar el usuario.'),
      );
    }
  }

  Future<void> logout() => _session.clear();

  Future<AppUser> fetchProfile() async {
    try {
      final res = await _api.get(ApiEndpoints.me);
      if (res.statusCode != 200) {
        throw Exception('No se pudo cargar el perfil.');
      }

      final data = _normalize(res.data);
      final currentSession = await _session.getUser();
      final profile = AppUser.fromApi({
        ...data,
        'token': currentSession?.token ?? '',
      });
      await _session.saveUser(profile);
      return profile;
    } on DioException catch (e) {
      throw Exception(_errorMessage(e, fallback: 'No se pudo cargar el perfil.'));
    }
  }

  Future<AppUser> updateProfile({
    required String nombre,
    required String apellido,
    required String telefono,
    required String direccion,
    required String distrito,
    required String numeroCasa,
  }) async {
    try {
      final res = await _api.put(
        ApiEndpoints.me,
        data: {
          'nombre': nombre,
          'apellido': apellido,
          'telefono': telefono,
          'direccion': direccion,
          'distrito': distrito,
          'numero_casa': numeroCasa,
        },
      );

      if (res.statusCode != 200) {
        throw Exception('No se pudo actualizar el perfil.');
      }

      final data = _normalize(res.data);
      final currentSession = await _session.getUser();
      final profile = AppUser.fromApi({
        ...data,
        'token': currentSession?.token ?? '',
      });
      await _session.saveUser(profile);
      return profile;
    } on DioException catch (e) {
      throw Exception(
        _errorMessage(e, fallback: 'No se pudo actualizar el perfil.'),
      );
    }
  }

  Map<String, dynamic> _normalize(dynamic body) {
    if (body is Map<String, dynamic>) return body;
    if (body is String) return jsonDecode(body) as Map<String, dynamic>;
    return {};
  }

  Future<Response<dynamic>> _postFirstAvailable(
    List<String> paths, {
    required Map<String, dynamic> data,
  }) async {
    DioException? lastError;
    for (final path in paths) {
      try {
        return await _api.post(path, data: data);
      } on DioException catch (e) {
        lastError = e;
        final statusCode = e.response?.statusCode ?? 0;
        if (statusCode == 404 || statusCode == 405) {
          continue;
        }
        rethrow;
      }
    }

    if (lastError != null) {
      throw lastError;
    }
    throw Exception('No se encontró una ruta compatible para conectar la app.');
  }

  String _errorMessage(DioException error, {required String fallback}) {
    final statusCode = error.response?.statusCode ?? 0;
    final response = error.response?.data;
    if (response is Map<String, dynamic>) {
      final message =
          response['message'] ?? response['error'] ?? response['msg'];
      if (message is String && message.trim().isNotEmpty) {
        return _friendlyAuthMessage(message, statusCode: statusCode);
      }
    }
    if (response is String && response.trim().isNotEmpty) {
      return _friendlyAuthMessage(response, statusCode: statusCode);
    }

    if (statusCode == 400 || statusCode == 401 || statusCode == 403 || statusCode == 404) {
      return 'No pudimos reconocer esta cuenta. Ingresa con un usuario registrado en la panadería.';
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'No pudimos conectarnos en este momento. Inténtalo nuevamente en un instante.';
      case DioExceptionType.connectionError:
        return 'No pudimos conectarnos en este momento. Revisa la IP configurada e inténtalo otra vez.';
      default:
        return fallback;
    }
  }

  String _friendlyAuthMessage(String message, {required int statusCode}) {
    final normalized = message.toLowerCase();
    final looksLikeInvalidUser =
        statusCode == 400 ||
        statusCode == 401 ||
        statusCode == 403 ||
        statusCode == 404 ||
        normalized.contains('credencial') ||
        normalized.contains('incorrect') ||
        normalized.contains('inválid') ||
        normalized.contains('invalid') ||
        normalized.contains('no existe') ||
        normalized.contains('no encontrado') ||
        normalized.contains('not found') ||
        normalized.contains('unauthorized');

    if (looksLikeInvalidUser) {
      return 'No pudimos reconocer esta cuenta. Ingresa con un usuario registrado en la panadería.';
    }

    return message;
  }
}
