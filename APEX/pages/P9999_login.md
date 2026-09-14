# Login APEX — Tilopay Demo

**Objetivo:** Página Login (9999) con icono Tilopay, título **Tilopay Demo** y gradiente rojo (`#ED1525`).

**Estado:** CSS, icono y guía listos en repo → **aplicar en App Builder** (manual en el workspace 110).

---

## Referencia visual

| Elemento | Valor |
|----------|--------|
| Fondo | Gradiente `#5C0810` → `#7A0A14` → `#B0101C` → `#ED1525` |
| Card | Blanco, radio 20px, sombra |
| Icono | `tilopay_icon.png` (T blanca sobre rojo) |
| Título | **Tilopay Demo** (visible, no ocultar) |
| Tagline | Checkout sandbox · Navasoft |
| Botón **Acceder** | `#ED1525`, texto blanco |

Archivos:

- Colores: [`../shared/theme_tilopay_colores.md`](../shared/theme_tilopay_colores.md)
- CSS: [`../shared/css/login_tilopay.css`](../shared/css/login_tilopay.css)
- Icono: [`../assets/tilopay_icon.png`](../assets/tilopay_icon.png)
- Wordmark oficial (opcional): [`../assets/tilopay_logo.svg`](../assets/tilopay_logo.svg)
- Mock: [`mockups/login.html`](mockups/login.html)

---

## Pasos en Oracle APEX (Universal Theme)

### 1. Subir el icono

1. **Shared Components → Static Application Files → Create**.
2. Subí `tilopay_icon.png` desde `APEX/assets/tilopay_icon.png`.
3. Referencia: `#APP_FILES#tilopay_icon.png`.

| Dónde | Qué poner |
|-------|-----------|
| **Shared Components → User Interface → Logo** | Type = **Image** · `#APP_FILES#tilopay_icon.png` (header) |
| **Página Login (9999) → región Login → Logo** | Type = **Image** · `#APP_FILES#tilopay_icon.png` |

No uses Type = **Icon** / App Icon: Universal Theme recorta el logo en un cuadrado.

### 2. Aplicar el CSS

1. App 110 → página **Login** (9999).
2. **Page Designer → CSS → Inline**.
3. Pegá el contenido completo de **`login_tilopay.css`**.  
   **No** pegues `login_ordexia.css` ni `login_gridxia.css`.
4. **Save** y ejecutá la app (logout si hace falta).

No pongas el CSS de login en el theme global: pintaría el fondo rojo en todas las páginas. El shell post-login va en `app_tilopay.css`.

### 3. Textos del login

| Ítem / región | Valor |
|---------------|--------|
| Título | **Tilopay Demo** |
| Botón | Label `Acceder`; estilo **Hot** |
| Usuario | Label `Usuario` |
| Contraseña | Label `Contraseña` |

### 4. Verificar

- [ ] Fondo rojo en degradado (no bloque plano ni azul APEX)
- [ ] Icono T rojo visible, no recortado
- [ ] Título **Tilopay Demo**
- [ ] Botón Acceder `#ED1525`
- [ ] Focus de inputs en rojo

---

## Relación con el shell

| Archivo | Alcance |
|---------|---------|
| `login_tilopay.css` | Solo página Login (inline en P9999) |
| `app_tilopay.css` | Shell + checkout + callback — ver [`THEME_TILOPAY_SHELL.md`](THEME_TILOPAY_SHELL.md) |

**Checklist:** cuando lo veas bien en el browser, marcá **A8** en `APEX/PENDIENTES.md` como aplicado en workspace.
