# Offline / sincronización

El cobro Tilopay **no** se hace offline: hace falta red para `loginSdk` y el SDK JS.

Flag de app: `AppConfig.enableOfflineSync` (hoy `false`).

## Capas en código (si más adelante hay cola de “reintentar consulta de orden”)

| Responsabilidad | Carpeta |
|-----------------|---------|
| Persistencia local | `lib/core/database/` |
| Cola / envío | `lib/core/sync/` |
| Conectividad | `lib/core/network/` |
| Banner / feedback UI | `lib/shared/widgets/` |
