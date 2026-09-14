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

  /// Credenciales de demo (solo si [useMockAuth]). No son claves Tilopay.
  static const String mockUser = 'saul.marin';
  static const String mockPassword = '1234';

  static const bool enableOfflineSync = false;
}
