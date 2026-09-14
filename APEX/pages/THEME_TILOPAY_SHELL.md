# Theme Tilopay Demo — Shell (menú horizontal + vertical)

**Objetivo:** Barra superior y menú lateral en carmesí Tilopay (`#ED1525` / `#B0101C`), no el azul default de Universal Theme.

**Archivo CSS:** [`../shared/css/app_tilopay.css`](../shared/css/app_tilopay.css)

---

## Cómo aplicarlo (recomendado: Static Files + Theme)

### 1. Subir archivos

**Shared Components → Static Application Files → Create** (uno por archivo):

| Archivo local | Nombre en APEX |
|---------------|----------------|
| `APEX/shared/css/app_tilopay.css` | `app_tilopay.css` |
| `APEX/assets/tilopay_icon.png` | `tilopay_icon.png` |

Referencias: `#APP_FILES#app_tilopay.css` · `#APP_FILES#tilopay_icon.png`

### 2. Invocarlo en el Theme

1. **Shared Components → User Interface → Themes**
2. Theme activo (Universal Theme) → **CSS File URLs**
3. Agregá:

```text
#APP_FILES#app_tilopay.css
```

4. **Save** + **Ctrl+F5**

### Logo del header

**Shared Components → User Interface Attributes → Logo**

- Type = Image
- `#APP_FILES#tilopay_icon.png`
- Texto de la app: **Tilopay Demo** (si el theme muestra el nombre)

---

## Qué debería cambiar

| Zona | Antes (default APEX) | Después (Tilopay Demo) |
|------|----------------------|------------------------|
| Barra superior | Azul APEX | Rojo `#B0101C` |
| Menú lateral | Gris genérico | Gradiente `#5C0810` → `#B0101C` |
| Ítem activo | Azul | `#ED1525` |
| Botones Hot | Theme | `#ED1525` |
| Checkout / callback | Form crudo | Cards de `app_tilopay.css` |

---

## Relación con el login

| Archivo | Alcance |
|---------|---------|
| `login_tilopay.css` | Solo Login (inline en P9999). Gradiente rojo de página completa. |
| `app_tilopay.css` | Shell + estilos de checkout P1 y recibo P3. |

No pegues el CSS de login en el theme: el fondo rojo taparía el contenido.

---

**Checklist:** cuando el header/menú se vean en rojo, marcá **A9** (y **A7** si P1/P3 ya usan las regiones nuevas) en `APEX/PENDIENTES.md`.
