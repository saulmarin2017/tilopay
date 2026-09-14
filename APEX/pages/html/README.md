# APEX — HTML / JS de páginas

Fragmentos para pegar en regiones APEX (Static Content, Dynamic Content, Page JavaScript).

Convención de nombre: `{pantalla}_p{nn}_{descripcion}.html` o `.js`

| Archivo | Página | Dónde pegar |
|---------|--------|-------------|
| [`checkout-region.html`](checkout-region.html) | P1 | Static Content, Escape = No |
| [`checkout-js.js`](checkout-js.js) | P1 | Execute when Page Loads |

IDs de Tilopay (`tlpy_*`, `#responseTilopay`) **no** se renombran. El JS mueve `#responseTilopay` a `document.body` (el 3DS no puede anidar un form en `wwvFlowForm`).
