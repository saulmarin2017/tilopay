# Postman — probar loginSdk antes de responder a soporte

Colección: `Tilopay-loginSdk.postman_collection.json`  
Entorno (con claves, **no Git**): `Tilopay-sandbox.local.json`

## Pasos

1. Abrir **Postman**.
2. **Import** → arrastrar `Tilopay-loginSdk.postman_collection.json`.
3. **Import** → arrastrar `Tilopay-sandbox.local.json` (si no está, crear entorno con `apiuser`, `password`, `key` desde `docs/CREDENCIALES.local.md`).
4. Arriba a la derecha, elegir entorno **Tilopay sandbox (local)**.
5. Abrir **loginSdk (el de soporte)** → **Send**.
6. No poner header `Authorization`. Solo `Content-Type: application/json`.

## Qué esperar

| Resultado | Qué hacer |
|-----------|-----------|
| **200** y `access_token` | OK. apiuser = `BVIikv` (I + i). No guardar el token. |
| **401** `{"error":"Unauthorized"}` | apiuser mal: `BVlikv` o `BVIlkv` (ele). El bueno es `BVIikv`. |

Opcional: disparar también **login (sin Sdk)**.
