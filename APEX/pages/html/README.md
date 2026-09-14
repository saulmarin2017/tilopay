# APEX — HTML / JS de páginas

Fragmentos para pegar en regiones APEX (Static Content, Dynamic Content, Page JavaScript).

Convención de nombre: `{pantalla}_p{nn}_{descripcion}.html` o `.js`

| Archivo | Página | Dónde pegar |
|---------|--------|-------------|
| [`checkout-region.html`](checkout-region.html) | P1 | Static Content, Escape = No |
| [`checkout-js.js`](checkout-js.js) | P1 | Execute when Page Loads |
| [`callback-region.html`](callback-region.html) | P3 | Static Content, Escape = No |
| [`callback-js.js`](callback-js.js) | P3 | Execute when Page Loads |

IDs de Tilopay (`tlpy_*`, `#responseTilopay`) **no** se renombran. El JS mueve `#responseTilopay` a `document.body` (el 3DS no puede anidar un form en `wwvFlowForm`).

Checkout: **Método de pago** al lado de **Tarjetas guardadas**; **Vence** al lado de **CVV**. Si Yappy, se ocultan tarjetas + datos de tarjeta.
