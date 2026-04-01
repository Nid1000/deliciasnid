import 'app_config.dart';

class ApiEndpoints {
  static String get baseUrl => AppConfig.apiBaseUrl;
  static String get uploadsBaseUrl => baseUrl.replaceFirst('/api', '');

  static const login = '/auth/login';
  static const register = '/auth/register';
  static const me = '/usuarios/perfil';
  static const products = '/productos';
  static const receipts = '/facturacion/mis-comprobantes';
  static const issueReceipt = '/facturacion/emitir';
  static const pendingNotifications = '/notificaciones/pendientes';
  static const markNotificationsShown = '/notificaciones/marcar-mostradas';

  static const orders = '/pedidos';
  static const myOrders = '/pedidos/mis-pedidos';
  static String orderById(String id) => '/pedidos/$id';
  static String orderTracking(String id) => '/pedidos/$id';
  static String orderEvents(String id) => '/pedidos/$id';

  static const loginCandidates = ['/auth/login', '/login'];
  static const registerCandidates = ['/auth/register', '/register'];
  static const ordersCandidates = ['/pedidos/mis-pedidos', '/pedidos', '/orders'];
  static List<String> orderByIdCandidates(String id) => [
    '/pedidos/$id',
    '/orders/$id',
  ];
  static List<String> orderTrackingCandidates(String id) => [
    '/pedidos/$id/tracking',
    '/orders/$id/tracking',
    '/pedidos/$id',
    '/orders/$id',
  ];
}
