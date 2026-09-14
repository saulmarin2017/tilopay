/*
  Cliente : NAVASOFT (interno)
  Proyecto: tilopay
  Fecha   : 2026-09-11
  Objetivo: El 03 ya tiene BVIlkv y Postman da 200; probar_login desde
            WKSP_PRUEBAS sigue en HTTP 401. Ver bytes del apiuser y
            reintentar loginSdk con headers limpios + JSON como Postman.
  Ambiente: SQL Commands / WKSP_PRUEBAS
  Notas   : Dos Runs separados. No pegar el SELECT junto al BEGIN.
            dump_user esperado (BVIlkv): Typ=1 Len=6: 42,56,49,6c,6b,76
            dump_user malo (BVlikv):     Typ=1 Len=6: 42,56,6c,69,6b,76
            49 = I mayúscula, 6c = ele minúscula, 69 = i minúscula.
*/

-- Run 1: bytes en NS_PAY_CONFIG (sin mostrar el password en claro)
select ambiente,
       api_user,
       dump(api_user, 16)     as dump_user,
       length(api_user)       as len_user,
       dump(api_password, 16) as dump_pwd,
       length(api_password)   as len_pwd,
       dump(api_key, 16)      as dump_key,
       length(api_key)        as len_key
  from ns_pay_config
 where ambiente = 'SANDBOX';

/*
  Run 2: reintento loginSdk. Headers en cero + JSON con espacios (como Postman).
  El password no se escribe en NS_PAY_EVENTO.
  Después: select id_evento, http_code, payload from ns_pay_evento
           where tipo = 'PRUEBA_LOGIN_FMT' order by id_evento desc;
*/
declare
  l_cfg  ns_pay_config%rowtype;
  l_body varchar2(4000);
  l_resp clob;
  l_http number;
begin
  select * into l_cfg
    from ns_pay_config
   where ambiente = 'SANDBOX'
     and activo   = 'S';

  apex_web_service.g_request_headers.delete;
  apex_web_service.g_request_headers(1).name  := 'Content-Type';
  apex_web_service.g_request_headers(1).value := 'application/json';

  l_body := '{ "apiuser" : "' || trim(l_cfg.api_user)
         || '", "password" : "' || trim(l_cfg.api_password)
         || '", "key": "' || trim(l_cfg.api_key) || '" }';

  l_resp := apex_web_service.make_rest_request(
              p_url         => nvl(l_cfg.url_get_token,
                                   'https://app.tilopay.com/api/v1/loginSdk'),
              p_http_method => 'POST',
              p_body        => l_body
            );
  l_http := apex_web_service.g_status_code;

  insert into ns_pay_evento (id_evento, tipo, http_code, payload)
  values (
    ns_pay_evento_seq.nextval,
    'PRUEBA_LOGIN_FMT',
    l_http,
    'dump_user=' || dump(l_cfg.api_user, 16)
    || ' len_pwd=' || length(trim(l_cfg.api_password))
    || ' http=' || l_http
    || ' resp=' || dbms_lob.substr(l_resp, 400, 1)
  );
  commit;
end;
