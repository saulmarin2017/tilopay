# Pendientes — Tilopay (Flutter)

Documento de seguimiento de tareas abiertas.  
**Última actualización:** 2026-09-14 (ORDS /pay/iniciar + /pay/orden en repo)

**APEX (app web):** [`../APEX/PENDIENTES.md`](../APEX/PENDIENTES.md)  
**Especificación APEX vs Flutter:** [`integracion/RECOMENDACIONES_APEX.md`](integracion/RECOMENDACIONES_APEX.md)

> **Grok — lectura obligatoria con el workflow:** al decir *"lee el workflow"*, leer **siempre** `Grok-Build-Workflow.md` + este archivo + `integracion/RECOMENDACIONES_APEX.md`. Mostrar pendientes **y** el recordatorio APEX (§1.1 del workflow) antes de trabajar.

---

## RECORDATORIO — Trabajo actual

> **Grok:** mostrar este bloque **primero** al iniciar la sesión.

### Repo nuevo: `saulmarin2017/tilopay`

**Objetivo:** cobro Tilopay desde Flutter (WebView) reusando app **110** / `NS_PAY_TILOPAY`.

Sandbox APEX **ya cobró** (2026-09-11): orden `NS-20260911-00000034`. Este repo arranca el cliente móvil.

| Paso | Qué | Estado |
|------|-----|--------|
| 0 | Scaffold Flutter + `APEX/` (patrón Ordexia/Gridxia) | ✅ 2026-09-14 |
| 1 | ORDS `POST /pay/iniciar` y `GET /pay/orden/:id` | **Repo listo** — falta ejecutar SQL y host en `app_secrets.dart` |
| 2 | Flutter camino A: WebView a p.1; interceptar `/callback` | Pendiente |
| 3 | Página APEX pública **o** camino B (HTML + token) | Pendiente |
| 4 | ORDS `/pay/retorno` + App Link | Pendiente |
| 5 | HMAC → estado `PAGADO` | Bloqueado (secreto Tilopay) |

La app web se lleva en **[`APEX/PENDIENTES.md`](../APEX/PENDIENTES.md)**.

---

## Completado (sandbox, no en este repo)

Hecho en `Innovacion/NAVASOFT/proyectos/tilopay/` y app 110:

| ID | Tarea | Estado |
|----|--------|--------|
| S1 | Tablas `NS_PAY_*` + paquete `NS_PAY_TILOPAY` en WKSP_PRUEBAS | Hecho |
| S2 | `loginSdk` HTTP 200 (`apiuser=BVIikv`) | Hecho |
| S3 | ACL WKSP_PRUEBAS → hosts Tilopay :443 | Hecho |
| S4 | Checkout p.1 + callback p.3 | Hecho |
| S5 | Pago sandbox Visa aprobado | Hecho |

---

## Pendiente / parcial

### Alta

| ID | Tarea | Estado | Notas |
|----|--------|--------|-------|
| P1 | Scaffold feature-first (`core/features/shared/data/docs/APEX`) | **Hecho** | 2026-09-14 |
| P2 | Contrato ORDS `iniciar` / `orden` | **Repo listo** | Scripts `sql/ords/02_modulo_pay.sql`. Falta correrlos + host ORDS. |
| P3 | Feature `pago` (WebView camino A) | Parcial | UI checkout = APEX p.1. Recibo demo. Falta WebView + ORDS. |
| P4 | `app_secrets.dart` local (host ORDS) | Pendiente | Copiar desde `app_secrets.example.dart` |
| P13 | Repo remoto en GitHub | En curso | `saulmarin2017/tilopay` |

### Media

| ID | Tarea | Estado | Notas |
|----|--------|--------|-------|
| P5 | Storage persistente (si hay login de cliente) | Pendiente | No hay auth de usuario aún |
| P6 | Offline / cola | No aplica ahora | Flag `enableOfflineSync = false` |
| P14 | CI (analyze/test) | Pendiente | |

### Baja

| ID | Tarea | Estado | Notas |
|----|--------|--------|-------|
| P7 | Theme / branding Navasoft | Parcial | APEX + login Flutter Tilopay Demo (gradiente rojo, icono T). Auth real pendiente (P5). |
| P16 | Tests (unit / widget) | Parcial | Smoke del scaffold |

---

## Bloqueado

| ID | Tarea | Bloqueo |
|----|--------|---------|
| P8 | Estado `PAGADO` en UI | HMAC (`hmac_secreto`) lo entrega Tilopay |

---

## Qué no hacer

- Claves Tilopay en el APK / IPA / Git.
- `http.post` del PAN desde Dart.
- `redirect` = `f?p=110:3:…` (404 en esta ADB).
- Confiar en el deep link sin `procesar_callback`.
