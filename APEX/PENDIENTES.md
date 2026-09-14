# Pendientes — Aplicación APEX (Tilopay)

**Última actualización:** 2026-09-14 (branding Tilopay Demo en repo)  
**Estado general:** Checkout sandbox **OK** (app 110). Branding listo en repo; falta pegar en App Builder. HMAC / export / ORDS siguen abiertos.  
**Workspace:** `WKSP_PRUEBAS`  
**Application ID:** **110** · alias `tilopay`

La especificación de cobro está en [`docs/PAGINA-CHECKOUT.md`](docs/PAGINA-CHECKOUT.md) y [`../docs/integracion/RECOMENDACIONES_APEX.md`](../docs/integracion/RECOMENDACIONES_APEX.md).  
Este archivo es el **seguimiento de la app web**; no duplicar el detalle en `docs/PENDIENTES.md`.

---

## Orden de trabajo actual

1. **A6** — Export `f110.sql` a `exports/app/`
2. **A10** — Ocultar token e ítems extra en callback
3. **A11** — HMAC `OrderHash` → estado `PAGADO` (bloqueado: falta secreto Tilopay)
4. **A12** — Página de pago pública **o** ORDS `/pay/iniciar` para Flutter

---

## Alta

| ID | Tarea | Estado | Notas |
|----|--------|--------|-------|
| A1 | Crear aplicación APEX en `WKSP_PRUEBAS` | **Hecho** | App **110**, alias `tilopay` |
| A2 | Checkout p.1 (Init + carrusel SDK V2) | **Hecho** (2026-09-11) | `P1_*` + `pages/html/checkout-*` |
| A3 | Callback p.3 | **Hecho** (2026-09-11) | Alias `CALLBACK`, Unrestricted + Deep Linking |
| A4 | Application Items Tilopay (`CODE`, `AUTH`, `ORDER`, …) | **Hecho** | Unrestricted; evitan ERR-1002 |
| A5 | Pago sandbox Visa | **Hecho** | `NS-20260911-00000034`, `code=1`, `auth=123456` |
| **A6** | **Export de la app APEX al repo** | Pendiente | `exports/app/f110.sql` |
| **A10** | **Ocultar token / Application Items en UI callback** | **Repo listo** | HTML `callback-region.html` + JS. Pegar en p.3; ítems `P3_*` Hidden. |
| **A11** | **HMAC `OrderHash`** | **Bloqueado** | Sin `hmac_secreto` el estado queda `PENDIENTE_HASH` |
| **A12** | **Página de pago pública o ORDS iniciar** | Pendiente | Hace falta para WebView Flutter (camino A/B) |

---

## Media

| ID | Tarea | Estado | Notas |
|----|--------|--------|-------|
| A13 | Prueba sandbox SINPE Móvil | Pendiente | Visa/MC ya OK |
| **A8** | **Login APEX Tilopay Demo (gradiente rojo)** | **Repo listo** | CSS `login_tilopay.css` + icono `tilopay_icon.png`. Guía `pages/P9999_login.md`. Título **Tilopay Demo**. |
| **A9** | **Shell menú alineado al branding** | **Repo listo** | CSS `app_tilopay.css`. Guía `pages/THEME_TILOPAY_SHELL.md`. |
| A4b | Auth / roles APEX (si deja de ser app de pruebas) | Pendiente | Distinto del OAuth de Flutter |

---

## Baja

| ID | Tarea | Estado | Notas |
|----|--------|--------|-------|
| **A7** | **Theme / branding en todas las páginas** | **Repo listo** | Checkout + callback con cards. Mockups en `pages/mockups/`. Pegar en workspace. |
| A14 | PayPal Business (extranjeros) | Pendiente | Fase 2 |
| A15 | Tokenización / cargos recurrentes | Pendiente | `InitTokenize` |

---

## Bloqueado

| ID | Tarea | Bloqueo |
|----|--------|---------|
| A11 | HMAC → `PAGADO` | Tilopay no ha entregado `hmac_secreto` |

---

## Application ID

| Dato | Valor |
|------|-------|
| Application ID | **110** |
| Nombre | Tilopay |
| Alias | `tilopay` |
| Schema | `WKSP_PRUEBAS` |
