# SQL — backend Tilopay

Correr en **WKSP_PRUEBAS** (SQL Workshop) salvo el ACL.

Origen: `Innovacion/NAVASOFT/proyectos/tilopay/sql/` (copiado a este repo).

| Archivo | Dónde | Estado |
|---------|--------|--------|
| [`01-tablas-pagos.sql`](01-tablas-pagos.sql) | SQL Commands WKSP_PRUEBAS | Aplicado en pruebas |
| [`02-pkg-tilopay.sql`](02-pkg-tilopay.sql) | SQL Commands WKSP_PRUEBAS | Aplicado en pruebas |
| [`03-ns-pay-config-sandbox.sql`](03-ns-pay-config-sandbox.sql) | SQL Commands | Plantilla **sin** claves |
| [`04-prueba-login-sdk.sql`](04-prueba-login-sdk.sql) | SQL Commands | Diagnóstico |
| [`05-diagnostico-login-401.sql`](05-diagnostico-login-401.sql) | SQL Commands | Diagnóstico |
| [`06-utl-http-login.sql`](06-utl-http-login.sql) | SQL Commands | Diagnóstico |
| [`07-prueba-user-Il-vs-Ii.sql`](07-prueba-user-Il-vs-Ii.sql) | SQL Commands | Diagnóstico |
| [`08-acl-tilopay.sql`](08-acl-tilopay.sql) | Database Actions, usuario **ADMIN** | Aplicado 2026-09-11 |

No aplicar en DEV/PROD hasta que Saúl lo autorice.

Handlers ORDS: [`ords/`](ords/) — `02_modulo_pay.sql` (iniciar + orden). Pendiente de ejecutar en WKSP_PRUEBAS.
