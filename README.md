# Tilopay — Navasoft

App Flutter de cobro con **Tilopay** (WebView + ORDS). La capa web vive en `APEX/`.

| Campo | Valor |
|--------|--------|
| **Ámbito** | NAVASOFT (interno) |
| **Remoto** | https://github.com/saulmarin2017/tilopay.git |
| **Ruta local** | `MyFlutter/tilopay/` |
| **Origen sandbox** | `Innovacion/NAVASOFT/proyectos/tilopay/` — copiado acá, ver [`docs/integracion/ORIGEN.md`](docs/integracion/ORIGEN.md) |
| **App APEX (pruebas)** | **110** Tilopay · alias `tilopay` · **WKSP_PRUEBAS** |
| **Sandbox** | Orden `NS-20260911-00000034` aprobada (`code=1`, `auth=123456`) |

Las 3 claves (`apiuser`, `password`, `key`) **nunca** van en esta app. Solo un `token` de `loginSdk`.

---

## Estructura (mismo patrón que Ordexia / Gridxia)

```
tilopay/
  Grok-Build-Workflow.md     ← flujo de sesiones Grok
  README.md
  APEX/                      ← app web Oracle APEX (páginas, SQL, exports)
  docs/
    PENDIENTES.md            ← pendientes Flutter
    ARQUITECTURA.md
    integracion/             ← ORDS, contratos, SQL de backend
    offline/
  lib/
    core/                    ← config, theme, API, services
    data/                    ← APIs transversales
    features/                ← splash, home, pago
    shared/                  ← widgets compartidos
  assets/images/
```

---

## Cómo empezar

1. Copiar secretos: `lib/core/config/app_secrets.example.dart` → `app_secrets.dart`
2. `flutter pub get`
3. En Grok: **"Leé el workflow"**

Pendientes Flutter: [`docs/PENDIENTES.md`](docs/PENDIENTES.md)  
Pendientes APEX: [`APEX/PENDIENTES.md`](APEX/PENDIENTES.md)  
Receta cobro: [`docs/integracion/FLUTTER.md`](docs/integracion/FLUTTER.md)
