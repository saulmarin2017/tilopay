# APEX — Aplicación web (Oracle APEX)

Espacio de trabajo para completar y documentar la **aplicación APEX** de Tilopay.

La app Flutter (`lib/`) consume **ORDS**.  
Este folder es para la **capa APEX** (páginas, procesos, shared components, export, notas de configuración).

**Workspace:** `WKSP_PRUEBAS`  
**App:** **110** Tilopay · alias `tilopay`  
**Sandbox:** pago aprobado 2026-09-11 (`NS-20260911-00000034`, `code=1`, `auth=123456`)

---

## Relación con el resto del repo

| Ubicación | Qué es |
|-----------|--------|
| `APEX/` | **Esta app APEX** (UI web, páginas, docs de pantallas) |
| `docs/integracion/` | Contratos API, ORDS, modelo de datos |
| `docs/integracion/sql/` | DDL, paquete `NS_PAY_TILOPAY`, ACL |
| `lib/` | App móvil Flutter |

No duplicar SQL de ORDS aquí si ya vive en `docs/integracion/sql/` — enlazar.  
Sí guardar aquí: exports APEX, notas de páginas, listas de trabajo, capturas y scripts **específicos de APEX**.

---

## Estructura

```
APEX/
  README.md                 ← este archivo
  PENDIENTES.md             ← qué falta en APEX (no duplicar en docs/PENDIENTES.md)
  docs/                     ← guías, menú, receta checkout
  pages/                    ← specs por página (P1, P3, …)
    html/                   ← HTML/JS para pegar en App Builder
    mockups/                ← mockups HTML/imagen
  shared/                   ← theme, CSS, LOVs, plugins
    css/
    plugins/
  sql/                      ← solo SQL propio de APEX (no ORDS genérico)
  exports/                  ← export .sql / app APEX (cuando se genere)
    app/
    ords/
  assets/                   ← imágenes, logos de referencia para APEX
  samples/                  ← archivos de ejemplo
```

---

## Convenciones

1. **Una nota por pantalla** en `pages/` (ej. `pages/P1_checkout.md`).
2. **Pendientes de APEX** en `APEX/PENDIENTES.md` (separado de `docs/PENDIENTES.md` de la app Flutter).
3. **IDs de página** reales de APEX cuando se conozcan (Application → Page).
4. **No commitear** contraseñas, workspace secrets ni `client_secret`.
5. Si exportás la app: `exports/app/fNNN.sql` (o el nombre que use APEX).

---

## Cómo trabajar en sesiones con Grok

- “Trabajamos en APEX” → leer `APEX/README.md` + `APEX/PENDIENTES.md`.
- Documentar cada cambio en la subcarpeta que corresponda.
- Al cerrar un bloque: actualizar `APEX/PENDIENTES.md`.

---

## Estado

**Iniciado en ADB:** 2026-09-01 (app 110)  
**Checkout sandbox:** 2026-09-11 — **OK**  
**Folder en este repo:** 2026-09-14

Páginas armadas en workspace:

- Login (default)
- **P1** Home / checkout (carrusel Tilopay SDK V2)
- **P3** Callback (`CALLBACK`)

Receta: [`docs/PAGINA-CHECKOUT.md`](docs/PAGINA-CHECKOUT.md)

---

## Enlaces útiles del repo

- Receta Flutter (WebView + ORDS): [`docs/integracion/FLUTTER.md`](../docs/integracion/FLUTTER.md)
- Qué va en APEX vs Flutter: [`docs/integracion/RECOMENDACIONES_APEX.md`](../docs/integracion/RECOMENDACIONES_APEX.md)
- Pendientes Flutter: [`docs/PENDIENTES.md`](../docs/PENDIENTES.md)
