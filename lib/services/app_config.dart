import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static const _apiBaseUrlFromEnv = String.fromEnvironment('API_BASE_URL', defaultValue: '');
  static const _customApiBaseUrlKey = 'customApiBaseUrl';
  static const _androidLanBaseUrl = 'http://192.168.18.117:5001/api';
  static String? _customApiBaseUrl;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString(_customApiBaseUrlKey)?.trim() ?? '';
    _customApiBaseUrl = savedUrl.isEmpty ? null : savedUrl;
  }

  static String get apiBaseUrl {
    if (_apiBaseUrlFromEnv.isNotEmpty) return _apiBaseUrlFromEnv;
    if (_customApiBaseUrl != null && _customApiBaseUrl!.isNotEmpty) {
      return _customApiBaseUrl!;
    }
    if (kIsWeb) return 'http://localhost:5001/api';

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _androidLanBaseUrl;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
        return 'http://localhost:5001/api';
      case TargetPlatform.iOS:
      case TargetPlatform.fuchsia:
        return 'http://localhost:5001/api';
    }
  }

  static String get defaultApiBaseUrl {
    if (kIsWeb) return 'http://localhost:5001/api';

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _androidLanBaseUrl;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
        return 'http://localhost:5001/api';
      case TargetPlatform.iOS:
      case TargetPlatform.fuchsia:
        return 'http://localhost:5001/api';
    }
  }

  static bool get hasCustomApiBaseUrl =>
      _customApiBaseUrl != null && _customApiBaseUrl!.isNotEmpty;

  static Future<void> setCustomApiBaseUrl(String value) async {
    final normalized = _normalizeApiUrl(value);
    final prefs = await SharedPreferences.getInstance();
    _customApiBaseUrl = normalized;
    await prefs.setString(_customApiBaseUrlKey, normalized);
  }

  static Future<void> resetCustomApiBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    _customApiBaseUrl = null;
    await prefs.remove(_customApiBaseUrlKey);
  }

  static String _normalizeApiUrl(String value) {
    var normalized = value.trim();
    if (normalized.isEmpty) return defaultApiBaseUrl;
    if (!normalized.startsWith('http://') && !normalized.startsWith('https://')) {
      normalized = 'http://$normalized';
    }
    if (!normalized.endsWith('/api')) {
      normalized = normalized.endsWith('/')
          ? '${normalized}api'
          : '$normalized/api';
    }
    return normalized;
  }

  static const pusherKey = String.fromEnvironment(
    'PUSHER_KEY',
    defaultValue: '1e3a8925dd99d50c035e',
  );
  static const pusherCluster = String.fromEnvironment(
    'PUSHER_CLUSTER',
    defaultValue: 'mt1',
  );
  static const pusherChannelPrefix = String.fromEnvironment(
    'PUSHER_CHANNEL_PREFIX',
    defaultValue: 'pedido.',
  );
  static const pusherEventName = String.fromEnvironment(
    'PUSHER_EVENT_NAME',
    defaultValue: 'pedido.estado.actualizado',
  );
}
