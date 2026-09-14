# Integración backend

Documentar aquí contratos de API, ORDS, handlers y SQL.

El backend de cobro ya corre en **WKSP_PRUEBAS** (app APEX 110, paquete `NS_PAY_TILOPAY`). Este folder es la copia de trabajo para Flutter.

## Contenido

| Doc | Qué |
|-----|-----|
| [`FLUTTER.md`](FLUTTER.md) | Receta WebView + ORDS (sin claves en la app) |
| [`ORDS_PAY.md`](ORDS_PAY.md) | Contrato `POST /pay/iniciar` y `GET /pay/orden/:id` |
| [`RECOMENDACIONES_APEX.md`](RECOMENDACIONES_APEX.md) | Qué vive en APEX vs Flutter |
| [`MODELO_DATOS.md`](MODELO_DATOS.md) | `NS_PAY_CONFIG` / `ORDEN` / `EVENTO` |
| `sql/` | DDL, paquete, ACL |
| `sql/ords/` | Handlers ORDS (cuando se armen) |

## Estructura

```
docs/integracion/
  README.md
  FLUTTER.md
  ORDS_PAY.md
  RECOMENDACIONES_APEX.md
  MODELO_DATOS.md
  sql/
    01-tablas-pagos.sql
    02-pkg-tilopay.sql
    08-acl-tilopay.sql
    ords/
```
