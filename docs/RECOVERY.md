# Recovery

Cómo reconstruir el workspace si se pierde la ADB o el App Builder.

## Backend (WKSP_PRUEBAS)

Orden:

1. `docs/integracion/sql/01-tablas-pagos.sql`
2. `docs/integracion/sql/02-pkg-tilopay.sql`
3. ACL (usuario **ADMIN**): `docs/integracion/sql/08-acl-tilopay.sql`
4. Fila `NS_PAY_CONFIG` SANDBOX (valores en `CREDENCIALES.local.md`, no Git)
5. Import APEX: `APEX/exports/app/f110.sql` cuando exista

## Flutter

Repo: https://github.com/saulmarin2017/tilopay.git

```bash
cd "%USERPROFILE%\MyFlutter"
git clone https://github.com/saulmarin2017/tilopay.git
cd tilopay
copy lib\core\config\app_secrets.example.dart lib\core\config\app_secrets.dart
flutter pub get
```
