# P3 — Callback Tilopay

**App:** 110 · **Página:** 3 · alias `CALLBACK`  
**Estado:** armada. Pago sandbox `NS-20260911-00000034` → `PENDIENTE_HASH`.

Receta completa: [`../docs/PAGINA-CHECKOUT.md`](../docs/PAGINA-CHECKOUT.md).

## Seguridad de página

| Campo | Valor |
|--------|--------|
| Page Access Protection | **Unrestricted** |
| Deep Linking | **Enabled** |

Tilopay agrega `code`, `order`, `auth`, `OrderHash`, etc. Hacen falta **Application Items** (nombres sin `P3_`, Unrestricted) **y** ítems de página `P3_*`.

## Ítems de página

`P3_ORDER` · `P3_CODE` · `P3_AUTH` · `P3_DESC` · `P3_ESTADO` · `ERROR` (no existe `P3_ERROR`)

Before Header llama `ns_pay_tilopay.procesar_callback`.

`P3_ESTADO = PENDIENTE_HASH` con HMAC vacío es correcto: Tilopay ya aprobó (`code=1`).

## UI de presentación (A10)

No hace falta poner cada ítem en Hidden. Se pega un recibo HTML y el CSS tapa el listado.

### Pasos en App Builder (página 3)

1. **Page 3 → Appearance → CSS Classes** → `tp-callback-page`
2. **Page 3 → Title** → vacío (el recibo ya tiene título)
3. Crear región **Static Content**
   - Title: vacío o `Resultado`
   - Sequence: **5** (arriba de Data)
   - Escape special characters = **No**
   - Source: pegar [`html/callback-region.html`](html/callback-region.html)
4. **Page 3 → JavaScript → Execute when Page Loads** → pegar [`html/callback-js.js`](html/callback-js.js)
5. Theme Custom CSS: que esté el `app_tilopay.css` actualizado (incluye `.tp-callback-page`)
6. **Región Data → Server-side Condition → Type = Never** (siempre oculta; no borres la región ni los ítems)
7. Save + Run + Ctrl+F5

No borres ítems ni Application Items (siguen haciendo falta para `?code=&order=`). Data en **Never** evita pintarlos. El error de página es el ítem `ERROR` (no `P3_ERROR`).

El JS colorea el recibo: `code=1` verde, otro código rojo.

Mock: [`mockups/callback.html`](mockups/callback.html).
