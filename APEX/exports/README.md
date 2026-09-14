# APEX / ORDS — Exports de recuperación

Snapshots importables del workspace **WKSP_PRUEBAS**.  
Complementan las guías en `APEX/pages/` y los scripts en `docs/integracion/sql/`.

## Estructura

```text
APEX/exports/
  app/     ← Export de la aplicación APEX (App Builder → Export)
  ords/    ← Export del módulo REST ORDS (cuando exista /pay/)
  README.md
```

## Contenido actual

| Carpeta | Archivo | Descripción |
|---------|---------|-------------|
| `app/` | _(vacío)_ | Exportar app **110** → `f110.sql` |
| `ords/` | _(vacío)_ | Preferir scripts en `docs/integracion/sql/ords/` |

## Cómo reimportar (cuando exista `f110.sql`)

1. App Builder → **Import**
2. Elegir `app/f110.sql`
3. Revisar Application ID (remapear si choca)
4. Tras import: validar checkout p.1 y callback p.3

**No commitear** `client_secret` ni contraseñas en estos exports.
