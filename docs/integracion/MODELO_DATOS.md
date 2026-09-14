# Modelo de datos — Tilopay

Schema: **WKSP_PRUEBAS**. DDL: [`sql/01-tablas-pagos.sql`](sql/01-tablas-pagos.sql).

| Tabla | Rol |
|-------|-----|
| `NS_PAY_CONFIG` | Un registro por ambiente (`SANDBOX` / `PROD`). Claves API, URL token, HMAC. |
| `NS_PAY_ORDEN` | Orden de cobro (`order_number`, monto, estado, auth, hash). |
| `NS_PAY_EVENTO` | Log HTTP (login, callback). El password se enmascara. |

Estados de orden: `PENDIENTE` · `PENDIENTE_HASH` · `PAGADO` · `RECHAZADO`.

`hash_ok` (V2 plugin Woo) marca `PAGADO` si el `OrderHash` coincide. Sin match queda `PENDIENTE_HASH`.

No se guarda PAN ni CVV.
