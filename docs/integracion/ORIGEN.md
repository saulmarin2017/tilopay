# Origen de la integración

El sandbox que **ya cobró** nació en:

`C:\Users\Innovation Computers\Innovacion\NAVASOFT\proyectos\tilopay\`

Ese folder no es el repo Git. El repo de trabajo es **este**:

`C:\Users\Innovation Computers\MyFlutter\tilopay` → https://github.com/saulmarin2017/tilopay.git

## Qué se copió acá (2026-09-14)

| En Innovacion | En este repo |
|---------------|----------------|
| `sql/01-tablas-pagos.sql` | `docs/integracion/sql/01-tablas-pagos.sql` (mismo hash) |
| `sql/02-pkg-tilopay.sql` | `docs/integracion/sql/02-pkg-tilopay.sql` (mismo hash) |
| `sql/03-ns-pay-config-sandbox.sql` | `docs/integracion/sql/03-ns-pay-config-sandbox.sql` (**sin** claves; placeholders) |
| `sql/04` … `07` | `docs/integracion/sql/` |
| `sql/08-acl-tilopay.sql` | `docs/integracion/sql/08-acl-tilopay.sql` (mismo hash) |
| `apex/PAGINA-CHECKOUT.md` | `APEX/docs/PAGINA-CHECKOUT.md` (actualizado en este repo) |
| `apex/checkout-*.html/js` | `APEX/pages/html/` (layout demo; IDs Tilopay iguales) |
| `scripts/checkout-tilopay-v2.html` | `APEX/samples/checkout-tilopay-v2.html` |
| `docs/GUIA-IMPLEMENTACION.md` | `docs/integracion/GUIA-IMPLEMENTACION.md` |
| `docs/FLUTTER.md` | `docs/integracion/FLUTTER.md` |
| `docs/postman/` | `docs/integracion/postman/` (colección; **no** el `.local.json` con claves) |

**No** se copió `CREDENCIALES.local.md` ni el entorno Postman local (claves Tilopay).

## Qué es nuevo en este repo (no está en Innovacion)

- Módulo ORDS `tilopay-module` (`docs/integracion/sql/ords/03_handlers_tilopay_module.sql`)
- Cliente Flutter `lib/data/api/pay_api.dart`
- Login / checkout Flutter (branding Tilopay Demo)

La app APEX **110** vive en la ADB (WKSP_PRUEBAS), no en una carpeta. El export `f110.sql` sigue pendiente (A6).
