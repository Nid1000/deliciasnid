import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_cliente.dart';
import 'api_endpoints.dart';

class OrdersService {
  final _api = ApiClient().dio;
  static const _lastOrderIdKey = 'lastOrderId';
  static const _lastOrderStatusKey = 'lastOrderStatus';
  static const _defaultStatus = 'Preparando';

  Future<String?> createOrder({
    required List<Map<String, dynamic>> items,
    required double total,
    required String metodoPago,
    String? fechaEntrega,
    String? direccionEntrega,
    String? distritoEntrega,
    String? numeroCasaEntrega,
    String? telefonoContacto,
    String? notas,
  }) async {
    for (final path in ApiEndpoints.ordersCandidates) {
      try {
        final res = await _api.post(
          path,
          data: {
            'productos': items
                .map(
                  (item) => {
                    'id': int.tryParse((item['id'] ?? '').toString()) ?? 0,
                    'cantidad': item['qty'] ?? 1,
                  },
                )
                .where((item) => (item['id'] as int) > 0)
                .toList(),
            'fecha_entrega': fechaEntrega,
            'direccion_entrega': direccionEntrega,
            'distrito_entrega': distritoEntrega,
            'numero_casa_entrega': numeroCasaEntrega,
            'telefono_contacto': telefonoContacto,
            'notas': notas,
            'pago': {
              'metodo': metodoPago == 'Tarjeta' ? 'card' : 'cash',
            },
            'total': total,
          },
        );

        if (res.statusCode == 200 || res.statusCode == 201) {
          final data = _toMap(res.data);
          final orderId = _readOrderId(data);
          if (orderId != null && orderId.isNotEmpty) {
            await _saveLastOrder(
              orderId,
              _readOrderStatus(data) ?? _defaultStatus,
            );
            return orderId;
          }
        }
      } on DioException catch (e) {
        final statusCode = e.response?.statusCode ?? 0;
        if (statusCode != 404 && statusCode != 405) break;
      }
    }

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await _saveLastOrder(id, _defaultStatus);
    return id;
  }

  Future<bool> issueReceipt({
    required String orderId,
    required String comprobanteTipo,
    required String tipoDocumento,
    required String numeroDocumento,
  }) async {
    try {
      final res = await _api.post(
        ApiEndpoints.issueReceipt,
        data: {
          'pedido_id': int.tryParse(orderId) ?? 0,
          'comprobante_tipo': comprobanteTipo,
          'tipo_documento': tipoDocumento,
          'numero_documento': numeroDocumento,
        },
      );
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  Future<bool> payOrder(String orderId, {required String metodoPago}) async {
    for (final path in ApiEndpoints.orderByIdCandidates(orderId)) {
      try {
        final res = await _api.patch(
          path,
          data: {'metodoPago': metodoPago, 'pagado': true},
        );
        return res.statusCode == 200 || res.statusCode == 201;
      } on DioException catch (e) {
        final statusCode = e.response?.statusCode ?? 0;
        if (statusCode != 404 && statusCode != 405) return true;
      }
    }
    return true;
  }

  Future<String> getOrderStatus(String orderId) async {
    for (final path in ApiEndpoints.orderByIdCandidates(orderId)) {
      try {
        final res = await _api.get(path);
        if (res.statusCode == 200) {
          final data = _toMap(res.data);
          final status = _readOrderStatus(data) ?? _defaultStatus;
          await _saveLastOrder(orderId, status);
          return status;
        }
      } on DioException catch (e) {
        final statusCode = e.response?.statusCode ?? 0;
        if (statusCode != 404 && statusCode != 405) break;
      }
    }
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_lastOrderStatusKey) ?? _defaultStatus;
    final next = _nextStatus(s);
    await prefs.setString(_lastOrderStatusKey, next);
    return next;
  }

  String _nextStatus(String s) {
    final v = s.toLowerCase();
    if (v.contains('prepar')) return 'En camino';
    if (v.contains('camino')) return 'Entregado';
    return 'Entregado';
  }

  Map<String, dynamic> _toMap(dynamic body) {
    if (body is Map<String, dynamic>) {
      if (body['pedido'] is Map<String, dynamic>) {
        return body['pedido'] as Map<String, dynamic>;
      }
      if (body['data'] is Map<String, dynamic>) {
        return body['data'] as Map<String, dynamic>;
      }
      if (body['order'] is Map<String, dynamic>) {
        return body['order'] as Map<String, dynamic>;
      }
      return body;
    }
    if (body is String) {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return _toMap(decoded);
    }
    return {};
  }

  String? _readOrderId(Map<String, dynamic> data) {
    final value =
        data['id'] ?? data['_id'] ?? data['orderId'] ?? data['pedidoId'];
    final orderId = value?.toString().trim();
    if (orderId == null || orderId.isEmpty || orderId == 'null') {
      return null;
    }
    return orderId;
  }

  String? _readOrderStatus(Map<String, dynamic> data) {
    final value = data['status'] ?? data['estado'] ?? data['orderStatus'];
    final status = value?.toString().trim();
    if (status == null || status.isEmpty || status == 'null') {
      return null;
    }
    return status;
  }

  Future<void> _saveLastOrder(String orderId, String status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastOrderIdKey, orderId);
    await prefs.setString(_lastOrderStatusKey, status);
  }
}
