# APEX — Shared components

Listas de valores (LOVs), authorization schemes, application items, theme, plantillas, plugins y componentes reutilizables.

## Application Items (callback Tilopay)

Session State Protection **Unrestricted**. Nombres **sin** `P3_`:

`CODE` `DESCRIPTION` `AUTH` `ORDER` `TPT` `CRD` `PADDED` `BRAND`  
`LAST_DIGITS` `GATEWAY_TRANSACTION` `TILOPAY_TRANSACTION`  
`ORDERHASH` `RETURNDATA` `INTERNALORDERHASH`

Hacen falta porque Friendly URLs busca ítems con esos nombres. Los de página 3 son `P3_*`.

## Theme / login

Cuando exista branding:

| Archivo | Descripción |
|---------|-------------|
| `css/` | CSS de login y shell |
| `../pages/P9999_login.md` | Pasos login en App Builder |
