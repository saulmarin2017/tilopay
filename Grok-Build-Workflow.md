# Grok Build - Flujo de Trabajo y Preferencias (Tilopay)

---
**Fecha de creación:** 14 de septiembre de 2026
**Última actualización:** 14 de septiembre de 2026
**Propietario:** Saúl (Administrador)
**Objetivo:** Trabajar de forma segura en Tilopay (Flutter + APEX + ORDS), con el mismo patrón que Ordexia y Órdenes de Mantenimiento.
**Remoto:** https://github.com/saulmarin2017/tilopay.git
**Origen sandbox:** `Innovacion/NAVASOFT/proyectos/tilopay/` (app APEX **110**, WKSP_PRUEBAS)

---

## 1. Flujo de Trabajo Diario (Obligatorio)

**Cada vez que vayas a trabajar:**

### Paso 0 — Pendientes (SIEMPRE primero)

Cuando el usuario diga **"lee el workflow"**, **"leé el workflow"** o inicie una sesión nueva, Grok debe:

1. Leer `Grok-Build-Workflow.md` (este archivo).
2. Leer `docs/PENDIENTES.md`.
3. Leer `docs/integracion/RECOMENDACIONES_APEX.md`.
4. **Mostrar al usuario un resumen claro de los pendientes** antes de hacer cualquier otra cosa.
5. Preguntar por cuál pendiente quiere empezar (o si hay una tarea nueva).
6. Solo después de eso, continuar con el flujo Git diario (pasos 1–4).

### 1.1 Recordatorio APEX (obligatorio al leer el workflow)

**Grok debe tener presente en cada sesión:**

- Las claves Tilopay (`apiuser`, `password`, `key`) **nunca** van en Flutter ni en Git. Solo el token de `loginSdk`.
- El cobro de tarjeta corre en **WebView / APEX + SDK JS**, no por Dart (`http.post` del PAN = alcance PCI).
- App APEX de pruebas: **110** Tilopay · alias `tilopay` · schema **WKSP_PRUEBAS**.
- Checkout = página **1** (`P1_*`). Callback = página **3** alias `CALLBACK`.
- Sin `hmac_secreto` el estado en BD queda `PENDIENTE_HASH` aunque Tilopay haya aprobado (`code=1`).

**Al mostrar el resumen de inicio, incluir siempre un bloque breve APEX:**

| Área | Hoy | Futuro |
|------|-----|--------|
| Checkout | App 110 p.1 (sandbox OK) | WebView Flutter camino A, luego HTML propio |
| Callback | App 110 p.3 | ORDS `/pay/retorno` sin Application Items |
| Token | `NS_PAY_TILOPAY.iniciar` en APEX | ORDS `POST /pay/iniciar` |
| Estado | `PENDIENTE_HASH` | `PAGADO` cuando haya HMAC |

**Formato sugerido al mostrar pendientes:**

- Lista breve con prioridad (alta / media / baja)
- Qué está bloqueado vs. qué solo falta ejecutar
- Archivos o endpoints involucrados
- Si hay cambios locales sin commit, mencionarlo

**Al cerrar el día o terminar una tarea importante:** actualizar `docs/PENDIENTES.md`. Si el trabajo fue de APEX, actualizar también `APEX/PENDIENTES.md`.

---

### Pasos 1–4 — Git y trabajo

```bash
# 1. Actualiza tu copia local
git checkout main
git pull origin main

# 2. Crea tu rama de trabajo
git checkout -b feature/nombre-de-lo-que-haras

# Ejemplos:
# git checkout -b feature/webview-checkout
# git checkout -b feature/ords-iniciar

# 3. Trabaja normalmente...

# 4. Sube tus cambios
git add .
git commit -m "feat(pago): WebView al checkout APEX"
git push origin feature/nombre-de-lo-que-haras
```

---

## 2. Git y Commits

### Preferencia actual del usuario:
- Normalmente hace commits **al final del día**.
- Con Grok Build quiere hacer **commits intermedios** cuando algo quede funcionando.

### Política de commits recomendada:

**Opción preferida:** Grok puede encargarse de hacer commits cuando una tarea quede funcionando. Mensajes claros. El usuario puede pedir "no hagas commit".

**Regla general:**
- Antes de una tarea importante, `git status`.
- Commits pequeños y significativos.
- **Nunca** commitear `app_secrets.dart`, `CREDENCIALES.local.md`, tokens ni password Tilopay.

---

## 3. Cómo Solicitar Cambios de Código

**Yo nunca aplico cambios sin confirmación explícita del usuario.**

1. El usuario describe lo que quiere cambiar.
2. Yo analizo el código.
3. Yo propongo los cambios (before/after o diff).
4. Explico qué voy a modificar y por qué.
5. El usuario confirma ("Sí, hacelo", "Aplicá los cambios", "Dale, seguí", "OK").
6. Solo entonces ejecuto los cambios.

---

## 4. Seguridad y Reversiones

- Git es la principal herramienta de seguridad.
- `git diff` / `git checkout -- archivo` / rama temporal antes de cambios grandes.
- No aplicar SQL contra ADB sin autorización explícita de Saúl.

---

## 5. Trabajo Visual (UI / Diseño)

| Herramienta     | Mejor para |
|-----------------|------------|
| **SuperGrok**   | Capturas, layout, feedback visual |
| **Grok Build**  | Código, Git, SQL, docs, APEX |

Flujo: SuperGrok (diagnóstico visual) → Grok Build (implementar).

---

## 6. Persistencia entre Sesiones

El contexto vive en el repo, no en el chat.

- Workflow: este archivo.
- Pendientes Flutter: `docs/PENDIENTES.md`.
- Pendientes APEX: `APEX/PENDIENTES.md`.
- Qué va a APEX vs Flutter: `docs/integracion/RECOMENDACIONES_APEX.md`.

Al abrir sesión: **"Leé el workflow"**.

---

## 7. Cómo Empezar una Sesión

- **"Leé el workflow"** → este archivo + `docs/PENDIENTES.md` + `docs/integracion/RECOMENDACIONES_APEX.md`, pendientes primero
- **"Trabajamos en APEX"** → además `APEX/README.md` + `APEX/PENDIENTES.md`
- "Estado actual del proyecto y de Git"
- "Antes de tocar nada, mostrame el estado de Git"

### Secuencia obligatoria al leer el workflow

1. Leer `Grok-Build-Workflow.md`
2. Leer `docs/PENDIENTES.md`
3. Leer `docs/integracion/RECOMENDACIONES_APEX.md`
4. Mostrar pendientes + bloque APEX (§1.1)
5. Preguntar: ¿seguimos con un pendiente o hay tarea nueva?
6. Verificar `git status` si va a haber cambios
7. Continuar con la tarea acordada

---

## 8. Resumen de Preferencias del Usuario

- Seguridad y facilidad para revertir.
- Commits intermedios cuando algo quede listo.
- Ver los cambios **antes** de aplicarlos.
- Estructura feature-first (`lib/core`, `lib/features`, `lib/data`, `lib/shared`).
- Carpeta `APEX/` para la app web (mismo patrón que Ordexia / Gridxia).
- Scripts SQL con cabecera (proyecto, ambiente, objetivo).

---

**Última actualización:** 14 de septiembre de 2026

---

**Fin del documento**
