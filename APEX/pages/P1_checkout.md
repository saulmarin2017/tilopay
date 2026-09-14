# P1 — Checkout Tilopay (Home)

**App:** 110 · **Página:** 1 · ítems `P1_*`  
**Estado:** armada y cobró en sandbox (2026-09-11).

Receta completa (Before Header, File URLs, Init): [`../docs/PAGINA-CHECKOUT.md`](../docs/PAGINA-CHECKOUT.md).

## Qué pega en App Builder

| Dónde | Archivo |
|-------|---------|
| Región Static Content (Escape special characters = **No**) | [`html/checkout-region.html`](html/checkout-region.html) |
| Execute when Page Loads | [`html/checkout-js.js`](html/checkout-js.js) |
| JavaScript File URLs | `https://app.tilopay.com/sdk/v2/sdk_tpay.min.js` |
| Theme CSS | [`../shared/css/app_tilopay.css`](../shared/css/app_tilopay.css) — ver [`THEME_TILOPAY_SHELL.md`](THEME_TILOPAY_SHELL.md) |
| Icono Static File | `#APP_FILES#tilopay_icon.png` |

El HTML muestra **Tilopay Demo** + monto/orden. IDs del SDK (`tlpy_*`, `#responseTilopay`) **no** se renombran.

Mock para presentar sin APEX: [`mockups/checkout.html`](mockups/checkout.html).

## Ítems

Para **presentar**: `P1_TOKEN`, `P1_ERROR`, `P1_ORDEN_ID`, `P1_ORDER_NUMBER`, `P1_REDIRECT`, `P1_MONTO`, `P1_MONEDA` → **Hidden**. El HTML pinta monto y orden. `P1_EMAIL` / nombre pueden quedar Hidden con default.

Alias de página 1: `home` (el recibo P3 enlaza a `home`).

Before Header llama `ns_pay_tilopay.iniciar`. El `redirect` se arma con `host_url('SCRIPT') || '/callback?session='` — **no** `f?p=` (404 en esta ADB).

## Prueba sandbox

- Tarjeta `4111111111111111`, vence futura, CVV cualquiera
- Método: Tarjeta de crédito o débito
- `env=TEST` en Init
