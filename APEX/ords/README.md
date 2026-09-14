# APEX / ORDS — módulo `tilopay-module`

Workspace **WKSP_PRUEBAS**. Base path **`/tilopay/`**.

Full URL:

`https://g147092bf4447e7-fd95nrdce4pbvcwy.adb.sa-bogota-1.oraclecloudapps.com/ords/pruebas/tilopay/`

Los handlers **viven en este repo**, no en otro proyecto:

| Recurso | Script |
|---------|--------|
| POST `iniciar` | [`docs/integracion/sql/ords/03_handlers_tilopay_module.sql`](../../docs/integracion/sql/ords/03_handlers_tilopay_module.sql) |
| GET `orden/:orderNumber` | el mismo archivo |
| Contrato | [`docs/integracion/ORDS_PAY.md`](../../docs/integracion/ORDS_PAY.md) |
| Cliente Flutter | [`lib/data/api/pay_api.dart`](../../lib/data/api/pay_api.dart) |

Correr el `03_…sql` en SQL Workshop (WKSP_PRUEBAS). **No** correr `02_modulo_pay.sql` si el módulo UI ya se llama `tilopay-module`.
