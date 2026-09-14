# ORDS — contrato de cobro (`/pay/`)

Aún **no** está desplegado. Receta de idea: [`FLUTTER.md`](FLUTTER.md).  
Reusa `NS_PAY_TILOPAY` en WKSP_PRUEBAS. Autenticación: usuario de la app Flutter, **no** las claves Tilopay.

Scripts (cuando se escriban): `sql/ords/`.

## `POST /pay/iniciar`

Body:

```json
{
  "monto": 100,
  "moneda": "CRC",
  "email": "cliente@correo.com",
  "nombre": "Saul",
  "apellido": "Marin"
}
```

Respuesta 200:

```json
{
  "orderNumber": "NS-20260911-00000035",
  "token": "…",
  "checkoutUrl": "https://…/ords/r/pruebas/tilopay/home",
  "error": null
}
```

`redirect` que se manda a Tilopay = URL **HTTPS** de callback (friendly o ORDS), no `f?p=` ni `navasoft://`.

## `GET /pay/orden/:orderNumber`

Campos: `order_number`, `estado`, `monto`, `moneda`, `auth_code`, `code_cb`, `tilopay_id`.

Estados: `PENDIENTE` → `PENDIENTE_HASH` o `PAGADO` / `RECHAZADO`.

## `GET /pay/retorno` (callback Tilopay → servidor)

Leer query (`code`, `order`, `auth`, `OrderHash`, …) y `ns_pay_tilopay.procesar_callback`.  
Opcional: 302 a `navasoft://pago?order=NS-…` **después** de procesar.
