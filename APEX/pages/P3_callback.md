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

`P3_ORDER` · `P3_CODE` · `P3_AUTH` · `P3_DESC` · `P3_ESTADO` · `P3_ERROR`

Before Header llama `ns_pay_tilopay.procesar_callback`.

`P3_ESTADO = PENDIENTE_HASH` con HMAC vacío es correcto: Tilopay ya aprobó (`code=1`).
