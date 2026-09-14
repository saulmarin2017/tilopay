# Recomendaciones APEX vs Flutter — Tilopay

**Grok:** leer este archivo junto con el workflow y `docs/PENDIENTES.md`.

## Qué ya hace APEX (app 110)

| Pieza | Dónde |
|-------|--------|
| Pedir token `loginSdk` | `NS_PAY_TILOPAY.iniciar` (servidor) |
| Carrusel tarjeta / SINPE | Página 1 + SDK JS |
| Recibir redirect Tilopay | Página 3 `CALLBACK` + `procesar_callback` |
| Guardar orden / eventos | `NS_PAY_ORDEN` / `NS_PAY_EVENTO` |

## Qué debe hacer Flutter

| Pieza | Cómo |
|-------|------|
| Iniciar un cobro | ORDS `POST /pay/iniciar` (sin claves Tilopay) |
| Mostrar el carrusel | WebView a p.1 (camino A) o HTML propio (camino B) |
| Saber si pagó | `GET /pay/orden/:orderNumber` **después** del callback |
| UI de resultado | Según `estado` en BD, no según `code=` en la URL |

## Qué no va en Flutter

- `apiuser` / `password` / `key` de Tilopay
- PAN / CVV por `http.post` desde Dart
- Aprobar el pago solo porque volvió un deep link

## Seeds / SQL

Los scripts en `docs/integracion/sql/` son **infraestructura de cobro**, no catálogos de negocio. No hay pantallas APEX de “alta de rutero” que reemplazar: el producto es el checkout.

Pantallas APEX de negocio (si Jonathan pide producción en GRIDXIA 4500) se documentan en `APEX/pages/` y `APEX/PENDIENTES.md`.
