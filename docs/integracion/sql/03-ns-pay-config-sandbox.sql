/*
  Cliente : NAVASOFT (interno)
  Proyecto: tilopay
  Origen  : Innovacion/NAVASOFT/proyectos/tilopay/sql/03-ns-pay-config-sandbox.sql
  Objetivo: Una fila SANDBOX en NS_PAY_CONFIG (WKSP_PRUEBAS / app 110)
  Notas   : Las claves reales NO van en Git. Completar en SQL Workshop
            desde CREDENCIALES.local.md (Innovacion) o el admin Tilopay.
            apiuser bueno = BVIikv (I mayúscula + i minúscula). No ele.
            hmac_secreto vacío → callback deja PENDIENTE_HASH.
*/

-- SQL Commands de APEX: un solo bloque. No pegar el SELECT en el mismo Run.
begin
  delete from ns_pay_config where ambiente = 'SANDBOX';
  insert into ns_pay_config (
    ambiente, api_key, api_user, api_password,
    url_get_token, url_sdk, capture_default, hmac_secreto,
    moneda_default, activo, fec_actualiza
  ) values (
    'SANDBOX',
    'REEMPLAZAR_API_KEY',
    'REEMPLAZAR_APIUSER',
    'REEMPLAZAR_PASSWORD',
    'https://app.tilopay.com/api/v1/loginSdk',
    'https://app.tilopay.com/sdk/v2/sdk_tpay.min.js',
    1,
    null,
    'CRC',
    'S',
    sysdate
  );
  commit;
end;
/
