# Theme Tilopay — colores

Paleta de **Tilopay Demo** (app APEX 110). El rojo es el carmesí oficial de Tilopay (`#ED1525`).

## Paleta

| Token | Hex | Uso |
|-------|-----|-----|
| `tilopayRed` | `#ED1525` | Marca, botón Acceder / Pagar, ítem activo menú |
| `tilopayRedDark` | `#B0101C` | Header, hover de botones |
| `tilopayRedDeeper` | `#7A0A14` | Arranque del gradiente login / menú |
| `tilopayRedSoft` | `#FF6B75` | Hover header, acentos claros |
| `tilopayPaua` | `#160065` | Acento secundario (marca Tilopay) |
| `surface` | `#F5F7FA` | Fondo de contenido |
| `textPrimary` | `#1A1A1A` | Texto sobre blanco |
| `textSecondary` | `#5F6368` | Tagline, hints |
| `ok` | `#1B8A4A` | Callback aprobado (`code=1`) |
| `warn` | `#E65100` | `PENDIENTE_HASH` |
| `error` | `#C62828` | Errores |
| blanco | `#FFFFFF` | Card login, inputs |

## Gradiente login

Pedido de sesión: **rojo en degradado**. Familia del carmesí Tilopay:

```
linear-gradient(155deg, #5C0810 0%, #7A0A14 28%, #B0101C 58%, #ED1525 100%)
```

No mezclar con el naranja de Gridxia ni el navy de Ordexia.

## Relación con Flutter

`lib/core/theme/app_colors.dart` todavía trae azul/naranja del scaffold. Esta paleta APEX es la de **presentación Tilopay Demo**. Si se alinea Flutter después, usar estos mismos tokens.
