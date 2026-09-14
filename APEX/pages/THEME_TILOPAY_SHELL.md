# Theme Tilopay Demo — Shell (todas las páginas menos Login)

**Objetivo:** Header, menú, checkout (P1) y callback (P3) en carmesí Tilopay. El login **no** se toca (sigue con `login_tilopay.css` inline).

**Archivo CSS:** [`../shared/css/app_tilopay.css`](../shared/css/app_tilopay.css)

---

## Cómo aplicarlo (igual que el login: pegar CSS)

### Opción A — Theme Custom CSS (rápida)

1. **Shared Components → User Interface → Themes**
2. Theme activo (Universal Theme) → **Custom CSS** / **Inline CSS**
3. Pegá el contenido **completo** de `app_tilopay.css`
4. **Save** + **Ctrl+F5**
5. Entrá a **página 1** (no al login) y verificá header rojo

**No** pegues `login_tilopay.css` acá: el fondo rojo taparía P1 y P3.  
El CSS del shell **excluye** `body.t-PageBody--login`, así el login no pierde el gradiente.

### Opción B — Static Files

1. **Shared Components → Static Application Files → Create**
2. Subí `APEX/shared/css/app_tilopay.css` como `app_tilopay.css`
3. Theme → **CSS File URLs**: `#APP_FILES#app_tilopay.css`

### Logo del header

Si todavía no está (del login):

- **Shared Components → User Interface Attributes → Logo**
- Type = **Image** · `#APP_FILES#tilopay_icon.png`
- Nombre de la app: **Tilopay Demo**

---

## Páginas que cubre

| Página | Qué cambia |
|--------|------------|
| **1** Checkout | Header/menú rojo + card `.tp-checkout` (si pegaste `checkout-region.html`) |
| **3** Callback | Header/menú rojo + recibo `.tp-receipt` (si pegaste `callback-region.html`) |
| **9999** Login | Sin cambio (excluido a propósito) |

HTML a pegar si aún está el form crudo:

| Página | Región Static Content (Escape = No) | JS Page Load |
|--------|--------------------------------------|--------------|
| 1 | [`html/checkout-region.html`](html/checkout-region.html) | [`html/checkout-js.js`](html/checkout-js.js) |
| 3 | [`html/callback-region.html`](html/callback-region.html) | [`html/callback-js.js`](html/callback-js.js) |

Ítems `P1_*` / `P3_*` visibles → **Hidden** (el HTML ya muestra monto, orden y recibo).

---

## Qué debería cambiar

| Zona | Antes (default APEX) | Después (Tilopay Demo) |
|------|----------------------|------------------------|
| Barra superior | Azul APEX | Rojo `#B0101C` |
| Menú lateral | Gris genérico | Gradiente `#5C0810` → `#B0101C` |
| Ítem activo | Azul | `#ED1525` |
| Botones Hot / Primary | Theme | `#ED1525` |
| Fondo contenido | Blanco/gris APEX | `#F5F7FA` |
| Focus de inputs | Azul | Rojo |
| Checkout / callback | Form crudo | Cards de `app_tilopay.css` |

---

## Relación con el login

| Archivo | Dónde | Alcance |
|---------|--------|---------|
| `login_tilopay.css` | P9999 → CSS Inline | Solo login |
| `app_tilopay.css` | Theme → Custom CSS | P1, P3 y el chrome |

---

**Checklist**

- [ ] Login sigue con gradiente rojo (no se puso gris)
- [ ] P1: header rojo, card checkout, icono T
- [ ] P3: recibo (verde si `code=1`), sin token en pantalla
- [ ] Botón Pagar / Ingresar / Hot en `#ED1525`

Cuando lo veas en el workspace, marcá **A9** y **A7** en `APEX/PENDIENTES.md`.
