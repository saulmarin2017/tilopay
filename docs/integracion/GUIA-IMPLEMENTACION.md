# Guía de implementación — Tilopay en APEX

**Proyecto:** `NAVASOFT/proyectos/tilopay/`  
**Origen:** `NAVASOFT/casos/2-CASO-20260819-pasarela-pagos-tilopay` (investigación, cerrado)  
**SDK a usar:** **V2** (`https://app.tilopay.com/sdk/v2/sdk_tpay.min.js`)  
El PDF histórico (`/sdk/v1/sdk.min.js`) no se usa.

---

## 1. Cuentas y credenciales

| Qué | Dónde |
|-----|--------|
| Alta comercio | [start.tilopay.com](https://start.tilopay.com) — dicen aprobación ~48 h |
| Sandbox developer | [tilopay.com/developers](https://tilopay.com/developers) |
| Admin / credenciales | [admin.tilopay.com/admin/checkout](https://admin.tilopay.com/admin/checkout) |
| API documentada | [Postman Tilopay](https://documenter.getpostman.com/view/12758640/TVKA5KUT) |
| Soporte | soporte@tilopay.com · [soporte.tilopay.com](https://soporte.tilopay.com) |

Tres secretos (los tres van **solo al servidor**):

| Campo | Nombre Tilopay | Ejemplo de forma |
|-------|----------------|------------------|
| API Key | Integration key / `tpay_key` | `0000-0000-0000-0000-0000` |
| API User | Integration user | texto corto |
| API Password | Integration password | texto corto |

Tilopay publica credenciales de **prueba WooCommerce** (no son de Navasoft; sirven para validar el plugin, no para nuestro APEX):

- Key `6609-5850-8330-8034-3464` · User `lSrT45` · Password `Zlb8H9`

Para Navasoft hay que generar **las nuestras** en el admin.

---

## 2. Flujo (carrusel)

```
1. APEX crea fila NS_PAY_ORDEN (PENDIENTE) y un orderNumber único.
2. PL/SQL llama GetTokenSdk (API Key + User + Password) → token de sesión.
3. La página APEX carga el SDK V2 y hace Tilopay.Init({ token, amount, orderNumber, redirect, ... }).
4. Init devuelve methods[] + cards[]  →  eso se pinta como carrusel.
5. Cliente elige método:
     - tarjeta  →  Tilopay.startPayment()  (+ 3DS en #responseTilopay)
     - SINPE    →  Tilopay.getSinpeMovil() y se muestran teléfono / monto / código
6. Tilopay redirige a `redirect` con query:
     code, auth, OrderHash, tpt, order, description, crd, selected_method
7. Página callback APEX llama NS_PAY_TILOPAY.procesar_callback.
8. Se valida OrderHash (HMAC 64). Si code=1 y hash ok → PAGADO.
```

Hosts que deben poder resolverse desde el browser y, el API, desde ADB:

- `app.tilopay.com`
- `secure.tilopay.com` / `securepayment.tilopay.com`

---

## 3. SDK V2 — contrato

Script:

```html
<script src="https://app.tilopay.com/sdk/v2/sdk_tpay.min.js"></script>
```

HTML obligatorio (IDs fijos de Tilopay; no renombrar):

- Contenedor `.payFormTilopay`
- `#tlpy_payment_method` · `#tlpy_saved_cards`
- `#tlpy_cc_number` · `#tlpy_cc_expiration_date` · `#tlpy_cvv`
- `#tlpy_phone_number` (Yappy)
- `#tlpy_card_payment_div` / `#tlpy_yappy_payment_div`
- `#responseTilopay` (iframe 3DS)

### `Tilopay.Init({...})` — parámetros

| Parámetro | Obligatorio | Notas |
|-----------|-------------|--------|
| `token` | Sí | Sale de **GetTokenSdk** (servidor). Nunca de las 3 claves. |
| `currency` | Sí | `CRC` o `USD` (ISO 4217, 3) |
| `language` | Sí | `es` / `en` |
| `amount` | Sí | Decimal 12,2 |
| `billToEmail` | Sí | También sirve para listar tarjetas guardadas |
| `orderNumber` | Sí | Único. No se reutiliza |
| `billToFirstName` / `billToLastName` / `billToAddress` | Sí | |
| `capture` | Sí | `1` captura ya · `0` solo autoriza (máx. 7 días) |
| `redirect` | Sí | URL absoluta HTTPS del callback APEX |
| `subscription` | Sí | `1` guarda tarjeta · `0` no |
| `hashVersion` | V2 | Enviar `"V2"` |
| `typeDni` + `dni` | Si SINPE | Ver tabla de identificaciones |
| `phoneYappy` | Si Yappy | |
| `returnData` | No | Base64 de parámetros propios (vuelven en el callback) |

Respuesta típica de Init:

```json
{
  "message": "Success",
  "environment": "PROD",
  "methods": [
    {"id":"452:3:15","name":"Tarjeta Crédito / Débito","type":"card"},
    {"id":"587:4:17","name":"Sinpe Móvil","type":"sinpemovil"}
  ],
  "cards": []
}
```

### Otras funciones

| Función | Uso |
|---------|-----|
| `Tilopay.startPayment()` | Cobra. Sin parámetros. |
| `Tilopay.getSinpeMovil()` | `{ code, amount, number }` para pintar instrucciones |
| `Tilopay.getCardType()` | visa / mastercard / amex |
| `Tilopay.updateOptions({...})` | Cambia dni, capture, redirect, etc. antes de pagar |
| `Tilopay.InitTokenize({...})` | Guarda tarjeta: cobra ~$1 y reversa |

Identificaciones SINPE: 1 cédula · 2 jurídica · 3 gobierno · 4 autónoma · 5 extranjero · 6 DIMEX · 7 DIDI.

---

## 4. Callback (query string)

Documentado por el plugin oficial WooCommerce. Tilopay pega esto en `redirect`:

| Parámetro | Significado |
|-----------|-------------|
| `order` | Nuestro `orderNumber` |
| `tpt` | Id interno Tilopay |
| `code` | `1` = aprobado. `Pending` = SINPE/en espera. Otro = rechazo |
| `auth` | Código autorización (≥ 6) |
| `OrderHash` | HMAC hex 64. **Validar siempre** |
| `description` | Texto del resultado |
| `crd` | Token de tarjeta (si subscription / tokenize) |
| `selected_method` | Ej. `SINPEMOVIL` |

Regla: `code=1` **y** `OrderHash` válido **y** `auth` presente → marcar PAGADO.  
Nunca marcar pagado solo porque llegó `code=1`.

Fórmula exacta del HMAC: está en el plugin (`computed_customer_hash`). Hay que copiarla de Postman / soporte Tilopay a `NS_PAY_TILOPAY.validar_hash` cuando tengamos la cuenta. Hasta entonces el paquete deja el hash registrado y **no** aprueba en automático si el secreto no está configurado.

---

## 5. GetTokenSdk (servidor)

Único punto donde viajan Key + User + Password.

- Método y URL exactos: **confirmar en la colección Postman** (paso bloqueante).
- Llamar con `APEX_WEB_SERVICE.MAKE_REST_REQUEST` (HTTPS, JSON o form según docs).
- Guardar request/response en `NS_PAY_EVENTO` (sin password en claro: enmascarar).
- El token que vuelve es de **una orden / una sesión**. No reutilizar entre clientes.

Constante en el paquete: `c_url_get_token`. Hoy es placeholder.

---

## 6. Piezas APEX (propuesta)

Cuando Jonathan confirme la app (propuesta: GRIDXIA 4500):

| Pieza | Rol |
|-------|-----|
| Página **Checkout** | Región HTML estática = markup Tilopay + JS V2. Proceso *Before Header* o Ajax: `NS_PAY_TILOPAY.iniciar` → item `Pxx_TOKEN` |
| Página **Callback** | *Before Header* lee `code`, `auth`, `OrderHash`, `tpt`, `order` y llama `procesar_callback`. Luego redirige a “gracias” o “falló” |
| Items | `Pxx_ORDEN_ID`, `Pxx_TOKEN`, `Pxx_MONTO`, `Pxx_MONEDA`, `Pxx_EMAIL` |
| Credenciales | Tabla `NS_PAY_CONFIG` o *Application Settings* (nunca items públicos) |

Demo fuera de APEX (para probar el SDK en un browser): `scripts/checkout-tilopay-v2.html`.

---

## 7. ACL / red

ADB tiene que abrir HTTPS saliente a:

- `app.tilopay.com`
- `secure.tilopay.com`

`APEX_WEB_SERVICE.MAKE_REST_REQUEST` en ADB suele salir con el ACL del engine APEX (en WKSP_PRUEBAS llegó a Tilopay: HTTP 401, no ORA-24247).

`UTL_HTTP` desde **WKSP_PRUEBAS** sí exige ACE propio: 2026-09-11 → `ORA-24247`. Script: `sql/08-acl-tilopay.sql` (correr como **ADMIN**).

---

## 8. PCI (no negociable)

El SDK V2 usa `<input>` nuestros para PAN/CVV. Eso **no** es SAQ A.

- No loguear `tlpy_cc_number` ni CVV.
- No mandar PAN a PL/SQL.
- HTTPS en toda la app.
- Cuando haya volumen real: conversar con Tilopay si ofrecen hosted fields (menor scope). Hasta entonces: SAQ A-EP + 3DS (el SDK ya mete 3DS en `#responseTilopay`).

---

## 9. Pruebas (sandbox)

1. Orden CRC 100.00, captura = 1, tarjeta de prueba que dé Tilopay.
2. Misma orden, método SINPE: deben verse teléfono + código + monto exacto.
3. Callback con `OrderHash` adulterado → debe quedar RECHAZADO / PENDIENTE_HASH, no PAGADO.
4. `orderNumber` repetido → error de Tilopay; no pisar la fila anterior.
5. Cancelación del usuario → estado CANCELADO.

---

## 10. Scripts de este caso

| Archivo | Qué hace | ¿Correr ahora? |
|---------|----------|----------------|
| `sql/01-tablas-pagos.sql` | `NS_PAY_CONFIG`, `NS_PAY_ORDEN`, `NS_PAY_EVENTO` | No, hasta confirmar esquema |
| `sql/02-pkg-tilopay.sql` | Paquete iniciar / callback / token | No, hasta tener URL GetTokenSdk |
| `scripts/checkout-tilopay-v2.html` | Demo local del carrusel | Sí, en browser, con token de prueba |

Ambiente: **DEV**. Nunca PROD en este caso hasta sandbox OK.
