# Data / API

| Archivo | Uso |
|---------|-----|
| [`pay_api.dart`](pay_api.dart) | `POST /pay/iniciar` y `GET /pay/orden/:id` |
| [`pay_models.dart`](pay_models.dart) | JSON del contrato |

Base URL: `AppSecrets.apiBaseUrl` (ej. `https://<host>/ords/pruebas/pay`).

Las claves Tilopay **no** van aquí. Scripts ORDS: `docs/integracion/sql/ords/`.
