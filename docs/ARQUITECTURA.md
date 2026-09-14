# Arquitectura Flutter — Tilopay

Plantilla feature-first (mismo patrón de carpetas que Ordexia / Órdenes de Mantenimiento).

## Capas

| Capa | Ruta | Rol |
|------|------|-----|
| core | `lib/core/` | Infra: API, config, theme, services |
| data | `lib/data/` | APIs transversales (iniciar pago, consultar orden) |
| features | `lib/features/<dominio>/` | UI + models + services de un dominio |
| shared | `lib/shared/` | Widgets/helpers usados por 2+ features |
| APEX | `APEX/` | App web Oracle APEX |
| docs | `docs/` | SQL, integración, planes offline |

## Flujo de arranque

`main.dart` → `SplashScreen` → `HomeScreen`

El cobro (cuando se arme) abre un WebView: receta [`integracion/FLUTTER.md`](integracion/FLUTTER.md).

```
Flutter  --iniciar-->  ORDS/APEX  --loginSdk-->  Tilopay
                <-- { token, orderNumber, checkoutUrl }
Flutter WebView (SDK JS) → redirect callback → consultar estado
```

## Dependencias entre capas

- `features` → `core`, `shared`, `data`
- `shared` → `core` (evitar depender de features)
- `core` → **no** importa `features`

## Naming

- Archivos `snake_case.dart`
- Screens: `*_screen.dart`
- Services/APIs: `*_service.dart`, `*_api.dart`

## Secretos

1. Copiar `app_secrets.example.dart` → `app_secrets.dart`
2. Completar valores reales (host ORDS)
3. Nunca commitear `app_secrets.dart`
4. Nunca poner claves Tilopay aquí
