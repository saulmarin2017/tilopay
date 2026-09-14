import 'app_secrets.dart';

/// Configuración global de la app (URLs, flags, timeouts).
/// Los secretos viven en [AppSecrets] (no commitear valores reales).
class AppConfig {
  AppConfig._();

  static const String appName = 'Tilopay';

  static const String appTitle = 'Tilopay Demo';

  static const String logoAsset = 'assets/images/tilopay_icon.png';

  static const String loginTagline = 'Checkout sandbox · Navasoft';

  static const String brandCredit = 'By Navasoft Soluciones';

  /// Base URL del backend (ORDS / API). Sin claves Tilopay.
  static String get apiBaseUrl => AppSecrets.apiBaseUrl;

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const bool useMockAuth = true;

  static const bool enableOfflineSync = false;
}
