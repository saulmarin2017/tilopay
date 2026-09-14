# ORDS — contrato de cobro (`/pay/`)

Scripts: [`sql/ords/`](sql/ords/). Schema **WKSP_PRUEBAS**. Alias `pruebas`.

Autenticación: usuario de la app Flutter, **no** las claves Tilopay. En sandbox el módulo va **público**.

Base (módulo UI `tilopay-module`):  
`https://g147092bf4447e7-fd95nrdce4pbvcwy.adb.sa-bogota-1.oraclecloudapps.com/ords/pruebas/tilopay`

El host es el de APEX (barra del browser, sin `/r/pruebas/tilopay/...`).

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

`redirect` que se manda a Tilopay = `…/ords/r/pruebas/tilopay/callback` (friendly, **no** `f?p=` ni `navasoft://`).

Llama `ns_pay_tilopay.iniciar` (token `loginSdk` en servidor). Flutter **no** recibe `apiuser` / `password` / `key`.

Camino A: `checkoutUrl` = p.1 app 110 (hace falta sesión o página pública).  
Camino B: Flutter usa `token` en HTML propio (paso 2).

## `GET /pay/orden/:orderNumber`

Campos: `orderNumber`, `estado`, `monto`, `moneda`, `authCode`, `code`, `tilopayId`.

Estados: `PENDIENTE` → `PENDIENTE_HASH` o `PAGADO` / `RECHAZADO`.

404 si no existe.

## `GET /pay/retorno` (paso 4)

Leer query (`code`, `order`, `auth`, `OrderHash`, …) y `ns_pay_tilopay.procesar_callback`.  
Opcional: 302 a `navasoft://pago?order=NS-…` **después** de procesar.
