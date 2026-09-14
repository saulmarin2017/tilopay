# ORDS — handlers `/pay/`

Contrato: [`../../ORDS_PAY.md`](../../ORDS_PAY.md).

| Archivo | Qué hace |
|---------|----------|
| [`01_enable_schema.sql`](01_enable_schema.sql) | Solo si REST no está habilitado (APEX suele tenerlo) |
| [`02_modulo_pay.sql`](02_modulo_pay.sql) | Alternativa: módulo `pay` en `/pay/` (no usar si ya creaste `tilopay-module`) |
| [`03_handlers_tilopay_module.sql`](03_handlers_tilopay_module.sql) | **Este:** templates de `tilopay-module` (`/tilopay/iniciar`, `/tilopay/orden/:id`) |
| `05_handler_retorno.sql` | Pendiente (paso 4) |

**Correr (módulo que ya existe en SQL Workshop):** `03_handlers_tilopay_module.sql`  
Schema **WKSP_PRUEBAS**. No uses `02_modulo_pay.sql` si el módulo se llama `tilopay-module`.

Público en sandbox. No lleva claves Tilopay.

Prueba:

```bash
curl -s -X POST "https://g147092bf4447e7-fd95nrdce4pbvcwy.adb.sa-bogota-1.oraclecloudapps.com/ords/pruebas/tilopay/iniciar" ^
  -H "Content-Type: application/json" ^
  -d "{\"monto\":100,\"moneda\":\"CRC\",\"email\":\"saul.marin@navasoftsoluciones.com\",\"nombre\":\"SAUL\",\"apellido\":\"MARIN\"}"
```

El `<host>` es el mismo que APEX (`…oraclecloudapps.com`).
