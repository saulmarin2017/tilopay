# Checkout + callback — app 110 Tilopay (WKSP_PRUEBAS)

Cómo quedó **2026-09-11**. El APEX vive en la ADB; esto es la receta para repetirlo.

Pago sandbox OK: orden `NS-20260911-00000034`, `code=1`, `auth=123456`, Visa.  
Estado BD: `PENDIENTE_HASH` hasta tener `hmac_secreto`.

```
Página 1 (browser)
  JS: Tilopay.Init({ token }) + startPayment()
        ↑
Before Header: NS_PAY_TILOPAY.iniciar → P1_TOKEN
        ↑
POST https://app.tilopay.com/api/v1/loginSdk
        ↓
Tilopay redirige a página 3 alias CALLBACK
  ?session=…&code=1&order=NS-…&auth=…&OrderHash=…
        ↓
Before Header p.3: NS_PAY_TILOPAY.procesar_callback
```

Checkout está en **página 1** (Home), ítems `P1_*`. No es página 2.

---

## Página 1 — File URLs

JavaScript → File URLs:

```
https://app.tilopay.com/sdk/v2/sdk_tpay.min.js
```

(o `#APP_FILES#sdk_tpay.min.js` si está en Static Application Files)

## Página 1 — Ítems

| Ítem | Tipo |
|------|------|
| `P1_TOKEN` | Hidden (no mostrar el token) |
| `P1_ERROR` | Hidden |
| `P1_ORDEN_ID` | Hidden |
| `P1_ORDER_NUMBER` | Hidden |
| `P1_REDIRECT` | Hidden (Text Field solo para depurar) |
| `P1_MONTO` | Number, default `100` |
| `P1_MONEDA` | Hidden, default `CRC` |
| `P1_EMAIL` | Text |
| `P1_NOMBRE` | Text / Hidden |
| `P1_APELLIDO` | Text / Hidden |

## Página 1 — Before Header

**No** uses `host_url('HOST')` + `get_url` (duplica `/ords/r/pruebas/tilopay`).  
**No** uses `f?p=` en esta ADB (404).  
**No** uses `get_url` (pone `CALLBACK` en mayúsculas / checksum).

```sql
declare
  l_id    number;
  l_ord   varchar2(64);
  l_token varchar2(4000);
  l_err   varchar2(400);
  l_url   varchar2(400);
begin
  l_url := rtrim(apex_util.host_url('SCRIPT'), '/')
        || '/callback'
        || '?session=' || :APP_SESSION;

  ns_pay_tilopay.iniciar(
    p_ambiente     => 'SANDBOX',
    p_monto        => nvl(to_number(:P1_MONTO), 100),
    p_moneda       => nvl(:P1_MONEDA, 'CRC'),
    p_email        => nvl(:P1_EMAIL, 'prueba@navasoftsoluciones.com'),
    p_nombre       => nvl(:P1_NOMBRE, 'Prueba'),
    p_apellido     => nvl(:P1_APELLIDO, 'Navasoft'),
    p_url_redirect => l_url,
    p_app_id       => :APP_ID,
    p_workspace    => :WORKSPACE,
    p_orden_id     => l_id,
    p_order_number => l_ord,
    p_token        => l_token,
    p_error        => l_err
  );

  :P1_ORDEN_ID     := l_id;
  :P1_ORDER_NUMBER := l_ord;
  :P1_TOKEN        := l_token;
  :P1_ERROR        := l_err;
  :P1_REDIRECT     := l_url;
end;
```

`P1_REDIRECT` bueno:

`https://…oraclecloudapps.com/ords/r/pruebas/tilopay/callback?session=…`

El `redirect` se manda a Tilopay en el **Init** (al cargar p.1). Si cambiás el Before Header, hay que **Run p.1 de nuevo** antes de pagar.

## Página 1 — HTML y JS

Región Static Content, Escape special characters = **No**. Source: `apex/checkout-region.html`.

Execute when Page Loads: `apex/checkout-js.js`.

El JS mueve `#responseTilopay` a `document.body` (el 3DS no puede hacer `.submit()` de un form anidado en `wwvFlowForm`).

Tarjeta de prueba: `4111111111111111`, vence futuro, CVV cualquiera. Método: Tarjeta de Crédito o Débito.

---

## Página 3 — Callback

| Campo | Valor |
|--------|--------|
| Page | **3** |
| Name | callback |
| Alias | `CALLBACK` (APEX lo deja en mayúsculas; la URL se arma con `/callback` minúsculas) |
| Security → Page Access Protection | **Unrestricted** |
| Deep Linking | **Enabled** |

Tilopay agrega `code`, `order`, `auth`, `last-digits`, etc. APEX Friendly URLs busca ítems con esos nombres. Los de página 3 **tienen** que ser `P3_*`, así que hacen falta **las dos** listas.

### Application Items (Shared Components)

Session State Protection **Unrestricted**. Nombres **sin** `P3_`:

`CODE` `DESCRIPTION` `AUTH` `ORDER` `TPT` `CRD` `PADDED` `BRAND`  
`LAST_DIGITS` `GATEWAY_TRANSACTION` `TILOPAY_TRANSACTION`  
`ORDERHASH` `RETURNDATA` `INTERNALORDERHASH`

### Page Items (página 3, Display Only)

`P3_ORDER` `P3_CODE` `P3_AUTH` `P3_DESC` `P3_ESTADO` `ERROR` (el ítem de error en app 110 se llama `ERROR`, no `P3_ERROR`)

### Before Header página 3

Nombre libre (`Procesar retorno Tilopay`):

```sql
declare
  l_qs    varchar2(4000);
  l_order varchar2(64);
  l_code  varchar2(20);
  l_auth  varchar2(40);
  l_hash  varchar2(80);
  l_tpt   varchar2(80);
  l_desc  varchar2(400);
  l_crd   varchar2(120);
  l_est   varchar2(20);
  l_err   varchar2(400);

  function qparam (p_qs varchar2, p_name varchar2) return varchar2 is
    l varchar2(4000);
  begin
    l := regexp_substr(p_qs, '(^|&)' || p_name || '=([^&]*)', 1, 1, 'i', 2);
    return utl_url.unescape(replace(nvl(l, ''), '+', ' '));
  end;
begin
  l_qs    := owa_util.get_cgi_env('QUERY_STRING');
  l_order := qparam(l_qs, 'order');
  l_code  := qparam(l_qs, 'code');
  l_auth  := qparam(l_qs, 'auth');
  l_hash  := qparam(l_qs, 'OrderHash');
  l_tpt   := qparam(l_qs, 'tpt');
  l_desc  := qparam(l_qs, 'description');
  l_crd   := qparam(l_qs, 'crd');

  :P3_ORDER := l_order;
  :P3_CODE  := l_code;
  :P3_AUTH  := l_auth;
  :P3_DESC  := l_desc;

  if l_order is not null then
    ns_pay_tilopay.procesar_callback(
      p_order_number => l_order,
      p_code         => l_code,
      p_auth         => l_auth,
      p_order_hash   => l_hash,
      p_tpt          => l_tpt,
      p_descripcion  => l_desc,
      p_crd          => l_crd,
      p_estado       => l_est,
      p_error        => l_err
    );
    :P3_ESTADO := l_est;
    :ERROR     := l_err;
  else
    :ERROR := 'Sin order en la URL';
  end if;
end;
```

`P3_ESTADO = PENDIENTE_HASH` con HMAC vacío es correcto: Tilopay ya aprobó (`code=1`).

---

## ACL (Database Actions, usuario ADMIN)

No corre en SQL Workshop de WKSP_PRUEBAS (`PLS-00201`). Script: `sql/08-acl-tilopay.sql`.  
`resolve` **sin** puerto; `connect` en 443. Hosts: `app.tilopay.com`, `secure.tilopay.com`, `securepayment.tilopay.com`.

## apiuser

`BVIikv` (I mayúscula + **i** minúscula). No `BVlikv` ni `BVIlkv`.
