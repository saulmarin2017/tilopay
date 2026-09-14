/// Plantilla de secretos — **commiteable**.
///
/// Copiá este archivo a `app_secrets.dart` y completá valores reales:
/// ```
/// copy lib\core\config\app_secrets.example.dart lib\core\config\app_secrets.dart
/// ```
///
/// `app_secrets.dart` está en `.gitignore` y no debe subirse al repo.
///
/// Las claves Tilopay (`apiuser`, `password`, `key`) **nunca** van aquí.
/// Solo host ORDS / OAuth de la app Flutter.
class AppSecrets {
  AppSecrets._();

  /// URL base del API (sin barra final). Módulo `/pay/` cuando exista.
  static const String apiBaseUrl =
      'https://TU_HOST/ords/pruebas/pay';

  /// Token OAuth (client_credentials), si el módulo lo pide.
  static const String oauthTokenUrl =
      'https://TU_HOST/ords/pruebas/oauth/token';

  static const String clientId = 'REEMPLAZAR_CLIENT_ID';

  static const String clientSecret = 'REEMPLAZAR_CLIENT_SECRET';
}
