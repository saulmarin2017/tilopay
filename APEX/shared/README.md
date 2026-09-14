# APEX — Shared components

Listas de valores (LOVs), authorization schemes, application items, theme, plantillas, plugins y componentes reutilizables.

## Application Items (callback Tilopay)

Session State Protection **Unrestricted**. Nombres **sin** `P3_`:

`CODE` `DESCRIPTION` `AUTH` `ORDER` `TPT` `CRD` `PADDED` `BRAND`  
`LAST_DIGITS` `GATEWAY_TRANSACTION` `TILOPAY_TRANSACTION`  
`ORDERHASH` `RETURNDATA` `INTERNALORDERHASH`

Hacen falta porque Friendly URLs busca ítems con esos nombres. Los de página 3 son `P3_*`.

## Theme / login

| Archivo | Descripción |
|---------|-------------|
| [`css/login_tilopay.css`](css/login_tilopay.css) | CSS solo página Login (gradiente rojo, título Tilopay Demo) |
| [`css/app_tilopay.css`](css/app_tilopay.css) | CSS shell + checkout + callback |
| [`theme_tilopay_colores.md`](theme_tilopay_colores.md) | Paleta |
| [`../pages/P9999_login.md`](../pages/P9999_login.md) | Pasos login en App Builder |
| [`../pages/THEME_TILOPAY_SHELL.md`](../pages/THEME_TILOPAY_SHELL.md) | Cómo cargar `app_tilopay.css` |
