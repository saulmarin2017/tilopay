# Tilopay en Flutter — NAVASOFT

Cómo cobrar con el mismo backend de app **110** (WKSP_PRUEBAS / `NS_PAY_TILOPAY`) desde una app Flutter.

No hay SDK nativo Tilopay. El carrusel es **JavaScript de navegador** (`sdk_tpay.min.js`). En móvil la tarjeta **no** pasa por Dart: va en un **WebView** (o una página hospedada) igual que en APEX.

Las 3 claves (`apiuser`, `password`, `key`) **nunca** van en Flutter ni en `--dart-define`. Solo un `token` de `loginSdk`, de corta vida.

Sandbox APEX ya probado (2026-09-11): `NS-20260911-00000034`, `code=1`, `auth=123456`. Receta APEX: `apex/PAGINA-CHECKOUT.md`.

---

## Arquitectura

```
Flutter  --iniciar-->  ORDS/APEX  --loginSdk-->  Tilopay
                <-- { token, orderNumber, checkoutUrl }

Flutter WebView
  HTML + sdk_tpay.min.js
  Tilopay.Init({ token, redirect })
  startPayment()          ← PAN/CVV solo aquí
  3DS (secure.tilopay.com)

Tilopay GET redirect HTTPS
  → procesar_callback (OrderHash)
  → Flutter cierra WebView y consulta estado
```

PCI: si `http.post` del número de tarjeta desde Dart, el comercio entra en alcance PCI. Con WebView + SDK, los datos salen del WebView a Tilopay (mismo modelo que app 110).

---

## Elegir camino

| Camino | Cuándo | Esfuerzo |
|--------|--------|----------|
| **A. WebView de app 110 p.1** | Demo / primer cut | Bajo: APEX ya cobra |
| **B. HTML propio en WebView** | UI nativa + mismo SDK | Medio: copiar `apex/checkout-*.html/js` |
| **C. Página hospedada Tilopay** | Casi sin JS | Medio: otra API de Tilopay |

Navasoft: hacer **A**, después **B** si GRIDXIA no debe abrir APEX.

El `redirect` que se manda a `iniciar` tiene que ser **HTTPS** que Tilopay pueda abrir. En esta ADB **no** uses `f?p=` (404). Usa friendly URL o un módulo ORDS.

---

## Paso 0 — Qué ya tiene que existir

- [x] `NS_PAY_CONFIG` SANDBOX, apiuser `BVIikv`
- [x] `NS_PAY_TILOPAY.iniciar` / `procesar_callback`
- [x] ACL WKSP_PRUEBAS → `app.tilopay.com` :443 (`sql/08-acl-tilopay.sql`)
- [x] App 110 p.1 checkout + p.3 callback (camino A)
- [ ] HMAC (`hmac_secreto`): sin eso el estado queda `PENDIENTE_HASH` (cobro OK en Tilopay)

---

## Paso 1 — Contrato JSON (backend)

Scripts: [`sql/ords/02_modulo_pay.sql`](sql/ords/02_modulo_pay.sql). Autenticación: el usuario de la app Flutter, **no** las claves Tilopay. Sandbox: módulo público.

### `POST /pay/iniciar`

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

PL/SQL (idea; el `redirect` es la URL HTTPS de callback, no una ruta Flutter):

```sql
declare
  l_id    number;
  l_ord   varchar2(64);
  l_token varchar2(4000);
  l_err   varchar2(400);
  l_url   varchar2(400);
begin
  l_url := rtrim(apex_util.host_url('SCRIPT'), '/') || '/callback';
  -- o URL ORDS pública de paso 3, p.ej. https://…/ords/pruebas/pay/retorno

  ns_pay_tilopay.iniciar(
    p_ambiente     => 'SANDBOX',
    p_monto        => :monto,
    p_moneda       => nvl(:moneda, 'CRC'),
    p_email        => :email,
    p_nombre       => :nombre,
    p_apellido     => :apellido,
    p_url_redirect => l_url,
    p_orden_id     => l_id,
    p_order_number => l_ord,
    p_token        => l_token,
    p_error        => l_err
  );

  -- responder JSON: orderNumber, token, checkoutUrl, error
end;
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

Camino **A**: `checkoutUrl` = URL de página 1 app 110 (hace falta sesión APEX o página pública de pago).  
Camino **B**: `checkoutUrl` no hace falta; Flutter carga HTML y usa `token`.

### `GET /pay/orden/:orderNumber`

```sql
select order_number, estado, monto, moneda, auth_code, code_cb, tilopay_id
  from ns_pay_orden
 where order_number = :orderNumber;
```

Estados: `PENDIENTE` → (pago) → `PENDIENTE_HASH` o `PAGADO` / `RECHAZADO`.

### Callback (Tilopay → vos, no Flutter)

Igual que página 3: leer query string (`code`, `order`, `auth`, `OrderHash`, `tpt`, `description`, `crd`) y `ns_pay_tilopay.procesar_callback`.

Si el callback es un módulo ORDS (no APEX Friendly URL) te ahorrás los Application Items `CODE`, `AUTH`, `ORDER`, etc.

URL de ejemplo (friendly, la que ya funciona):

`https://<host>/ords/r/pruebas/tilopay/callback?session=…`

Para Flutter conviene un ORDS **sin** `session=` de APEX, p.ej.:

`https://<host>/ords/pruebas/pay/retorno`

y opcionalmente redirigir a `navasoft://pago?order=NS-…`.

---

## Paso 2 — Camino A (WebView de app 110)

La página 1 de APEX ya hace Init + carrusel. Flutter solo la abre.

1. App Flutter: `webview_flutter` (y `webview_flutter_android` / `wkwebview`).
2. `JavaScriptMode.unrestricted`.
3. Permitir ventanas / 3DS (`setOnConsoleMessage` útil en debug).
4. Cargar `checkoutUrl` de `POST /pay/iniciar` **o** la URL de p.1 si ya hay sesión.
5. `NavigationDelegate`: si la URL contiene `/callback` o `code=`, cerrar WebView y `GET /pay/orden/…`.

```dart
controller.setNavigationDelegate(NavigationDelegate(
  onNavigationRequest: (req) {
    final u = Uri.parse(req.url);
    if (u.path.contains('/callback') || u.queryParameters.containsKey('code')) {
      onVolvioDeTilopay(u.queryParameters['order']);
      return NavigationDecision.prevent;
    }
    return NavigationDecision.navigate;
  },
));
```

Limitación A: hace falta que p.1 sea alcanzable (login APEX, o página de pago **pública** + Deep Linking). Para una app de clientes, no es ideal dejar el builder; por eso el paso 3 (camino B) o una página APEX solo-pago, Authentication = Page Is Public.

3DS: `#responseTilopay` tiene que poder salir del `<form>` (el JS de `apex/checkout-js.js` ya lo mueve a `document.body`).

---

## Paso 3 — Camino B (HTML en el WebView)

1. Copiá `apex/checkout-region.html` + `apex/checkout-js.js` a `assets/tilopay/` (o servilos por HTTPS).
2. Cargá el SDK: `https://app.tilopay.com/sdk/v2/sdk_tpay.min.js`.
3. Sustituí `$v("P1_TOKEN")` por valores que Flutter inyecta:

```dart
await controller.runJavaScript(
  'window.__TILOPAY_TOKEN = ${jsonEncode(sesion.token)};'
  'window.__TILOPAY_ORDER = ${jsonEncode(sesion.orderNumber)};'
  'window.__TILOPAY_REDIRECT = ${jsonEncode(sesion.redirect)};',
);
```

4. En el JS, `token: window.__TILOPAY_TOKEN` (no ítems APEX).
5. `redirect` = URL HTTPS del paso 1 (ORDS retorno), no un `navasoft://` crudo: Tilopay tiene que poder hacer GET.
6. Tras el GET, ORDS puede `302` a `navasoft://pago?order=NS-…`.

Android: intent-filter `navasoft` / App Links.  
iOS: Associated Domains.

ACL: el WebView no usa el ACL de Oracle. El ACL sigue haciendo falta para `iniciar` (loginSdk desde la ADB).

---

## Paso 4 — Deep link (opcional)

| Plataforma | Qué registrar |
|------------|----------------|
| Android | `<intent-filter>` `https://tudominio/pago` o scheme `navasoft` |
| iOS | `applinks:tudominio` o URL scheme |

El servidor **primero** corre `procesar_callback`; **después** redirige a la app. No dejes que Flutter “apruebe” el pago solo porque volvió el deep link.

---

## Paso 5 — Qué mostrar en la app

| `estado` en `NS_PAY_ORDEN` | UI Flutter |
|----------------------------|------------|
| `PENDIENTE` | Sigue en el WebView / no pagó |
| `PENDIENTE_HASH` | “Pago recibido (validación hash pendiente)” — sandbox actual |
| `PAGADO` | Comprobante (hace falta HMAC) |
| `RECHAZADO` | Reintentar |

No uses solo `code=1` en la URL del WebView como prueba de cobro: validá en BD.

---

## Paso 6 — Prueba sandbox

Misma tarjeta que APEX:

- Número `4111111111111111`
- Vence futura (`12/28`), CVV cualquiera
- Método: Tarjeta de crédito o débito

`env=TEST` en `Init`. Si ves `PROD`, no uses esa tarjeta.

---

## Qué no hacer

- Claves Tilopay en el APK / IPA / Git.
- `http.post` del PAN desde Dart.
- `redirect` = `f?p=110:3:…` (404 en esta ADB).
- `redirect` = `navasoft://…` directo (Tilopay no abre custom schemes).
- Confiar en el deep link sin `procesar_callback`.
- Esperar un plugin `tilopay` en pub.dev: el camino público es JS SDK o página hospedada.

---

## Orden de implementación

1. ORDS `POST /pay/iniciar` y `GET /pay/orden/:id` (reusa el paquete).
2. Flutter camino **A**: WebView a p.1; interceptar `/callback`.
3. Página de pago APEX pública **o** camino **B** (HTML + token).
4. ORDS `/pay/retorno` sin Application Items; App Link.
5. HMAC cuando Tilopay dé el secreto → estado `PAGADO`.

Detalle APEX (ítems, Unrestricted, Application Items): `apex/PAGINA-CHECKOUT.md`.
