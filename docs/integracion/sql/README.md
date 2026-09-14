# SQL — backend Tilopay

Correr en **WKSP_PRUEBAS** (SQL Workshop) salvo el ACL.

| Archivo | Dónde | Estado |
|---------|--------|--------|
| [`01-tablas-pagos.sql`](01-tablas-pagos.sql) | SQL Commands WKSP_PRUEBAS | Aplicado en pruebas |
| [`02-pkg-tilopay.sql`](02-pkg-tilopay.sql) | SQL Commands WKSP_PRUEBAS | Aplicado en pruebas |
| [`08-acl-tilopay.sql`](08-acl-tilopay.sql) | Database Actions, usuario **ADMIN** | Aplicado 2026-09-11 |

No aplicar en DEV/PROD hasta que Saúl lo autorice.

Handlers ORDS: [`ords/`](ords/) — `02_modulo_pay.sql` (iniciar + orden). Pendiente de ejecutar en WKSP_PRUEBAS.
