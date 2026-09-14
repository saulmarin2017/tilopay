/*
  Cliente : NAVASOFT (interno)
  Proyecto: tilopay
  Origen  : 2-CASO-20260819-pasarela-pagos-tilopay (investigación, cerrado)
  Fecha   : 2026-09-01
  Autor   : Saúl / Grok Build
  Objetivo: Paquete de checkout Tilopay (token servidor + callback)
  Ambiente: DEV (no correr en PROD sin confirmación)
  Prereq  : sql/01-tablas-pagos.sql + fila en NS_PAY_CONFIG
  Notas   : c_url_get_token se pisa con NS_PAY_CONFIG.url_get_token.
            Confirmar verb/body de GetTokenSdk en Postman antes de usar iniciar().
            hash_ok: HMAC-SHA256 V2 (plugin Woo Tilopay computed_customer_hash).
            Prereq: GRANT EXECUTE ON SYS.DBMS_CRYPTO TO WKSP_PRUEBAS (script 09).
*/

create or replace package ns_pay_tilopay as

  function siguiente_order_number return varchar2;

  procedure iniciar (
    p_ambiente     in  varchar2,
    p_monto        in  number,
    p_moneda       in  varchar2 default 'CRC',
    p_email        in  varchar2,
    p_nombre       in  varchar2,
    p_apellido     in  varchar2,
    p_url_redirect in  varchar2,
    p_app_id       in  number   default null,
    p_workspace    in  varchar2 default null,
    p_orden_id     out number,
    p_order_number out varchar2,
    p_token        out varchar2,
    p_error        out varchar2
  );

  procedure procesar_callback (
    p_order_number in  varchar2,
    p_code         in  varchar2,
    p_auth         in  varchar2,
    p_order_hash   in  varchar2,
    p_tpt          in  varchar2,
    p_descripcion  in  varchar2,
    p_crd          in  varchar2 default null,
    p_metodo       in  varchar2 default null,
    p_estado       out varchar2,
    p_error        out varchar2
  );

  -- Prueba loginSdk. El resultado queda en NS_PAY_EVENTO (tipo PRUEBA_LOGIN).
  procedure probar_login;

end ns_pay_tilopay;
/

create or replace package body ns_pay_tilopay as

  procedure log_evento (
    p_id_orden in number,
    p_tipo     in varchar2,
    p_http     in number,
    p_payload  in clob
  ) is
    pragma autonomous_transaction;
  begin
    insert into ns_pay_evento (id_evento, id_orden, tipo, http_code, payload)
    values (ns_pay_evento_seq.nextval, p_id_orden, p_tipo, p_http, p_payload);
    commit;
  end log_evento;

  function siguiente_order_number return varchar2 is
  begin
    return 'NS-' || to_char(sysdate, 'YYYYMMDD') || '-' ||
           ltrim(to_char(ns_pay_orden_seq.nextval, '00000009'));
  end siguiente_order_number;

  function get_token_sdk (
    p_ambiente in varchar2,
    p_id_orden in number
  ) return varchar2 is
    l_cfg     ns_pay_config%rowtype;
    l_body    varchar2(4000);
    l_resp    clob;
    l_token   varchar2(4000);
    l_http    number;
  begin
    select * into l_cfg
      from ns_pay_config
     where ambiente = p_ambiente
       and activo   = 'S';

    apex_web_service.g_request_headers(1).name  := 'Content-Type';
    apex_web_service.g_request_headers(1).value := 'application/json';

    -- loginSdk exige apiuser + password + key
    -- https://tilopay.com/developers/api/autenticacion/token-sdk
    l_body := '{'
           || '"apiuser":"'  || l_cfg.api_user     || '",'
           || '"password":"' || l_cfg.api_password || '",'
           || '"key":"'      || l_cfg.api_key      || '"'
           || '}';

    l_resp := apex_web_service.make_rest_request(
                p_url         => l_cfg.url_get_token,
                p_http_method => 'POST',
                p_body        => l_body
              );
    l_http := apex_web_service.g_status_code;

    log_evento(
      p_id_orden,
      'GET_TOKEN',
      l_http,
      'http=' || l_http || ' url=' || l_cfg.url_get_token
      || ' (password omitido) resp_len=' || nvl(dbms_lob.getlength(l_resp), 0)
    );

    if l_http not between 200 and 299 then
      raise_application_error(-20001, 'GetTokenSdk HTTP ' || l_http);
    end if;

    -- Ajustar la ruta JSON cuando se tenga un response real de Postman.
    apex_json.parse(l_resp);
    begin
      l_token := apex_json.get_varchar2(p_path => 'access_token');
    exception
      when others then
        l_token := apex_json.get_varchar2(p_path => 'token');
    end;

    if l_token is null then
      raise_application_error(-20002, 'GetTokenSdk no devolvió token. Revisar Postman.');
    end if;

    return l_token;
  end get_token_sdk;

  function hmac_sha256_hex (p_msg in varchar2, p_key in varchar2) return varchar2 is
    l_mac raw(64);
  begin
    if p_msg is null or p_key is null then
      return null;
    end if;
    l_mac := dbms_crypto.mac(
               src => utl_i18n.string_to_raw(p_msg, 'AL32UTF8'),
               typ => dbms_crypto.hmac_sh256,
               key => utl_i18n.string_to_raw(p_key, 'AL32UTF8')
             );
    return lower(rawtohex(l_mac));
  end hmac_sha256_hex;

  function hash_ok (
    p_ambiente     in varchar2,
    p_order_number in varchar2,
    p_monto        in number,
    p_moneda       in varchar2,
    p_tpt          in varchar2,
    p_code         in varchar2,
    p_auth         in varchar2,
    p_email        in varchar2,
    p_order_hash   in varchar2
  ) return varchar2 is
    l_cfg    ns_pay_config%rowtype;
    l_amount varchar2(40);
    l_msg    varchar2(4000);
    l_hex    varchar2(64);
    l_want   varchar2(64);
  begin
    if p_order_hash is null or length(p_order_hash) != 64 then
      return 'N';
    end if;
    if p_tpt is null or p_auth is null then
      return 'N';
    end if;

    select * into l_cfg
      from ns_pay_config
     where ambiente = p_ambiente;

    l_want   := lower(p_order_hash);
    l_amount := trim(to_char(p_monto, 'FM9999999990.00'));
    -- PHP http_build_query del plugin Woo (hashVersion V2).
    l_msg :=
      'api_Key='            || l_cfg.api_key ||
      '&api_user='          || l_cfg.api_user ||
      '&orderId='           || p_tpt ||
      '&external_orden_id=' || p_order_number ||
      '&amount='            || l_amount ||
      '&currency='          || p_moneda ||
      '&responseCode='      || p_code ||
      '&auth='              || p_auth ||
      '&email='             || replace(nvl(p_email, ''), '@', '%40');

    -- Clave V2 del plugin: tpt|api_key|api_password
    l_hex := hmac_sha256_hex(l_msg, p_tpt || '|' || l_cfg.api_key || '|' || l_cfg.api_password);
    if l_hex = l_want then
      return 'S';
    end if;

    -- V1 (plugin viejo): api_key|api_password
    l_hex := hmac_sha256_hex(l_msg, l_cfg.api_key || '|' || l_cfg.api_password);
    if l_hex = l_want then
      return 'S';
    end if;

    -- Secreto que Tilopay mandó por correo (si está en hmac_secreto).
    if l_cfg.hmac_secreto is not null then
      l_hex := hmac_sha256_hex(l_msg, l_cfg.hmac_secreto);
      if l_hex = l_want then
        return 'S';
      end if;
      l_hex := hmac_sha256_hex(l_msg, p_tpt || '|' || l_cfg.hmac_secreto);
      if l_hex = l_want then
        return 'S';
      end if;
    end if;

    return 'N';
  end hash_ok;

  procedure iniciar (
    p_ambiente     in  varchar2,
    p_monto        in  number,
    p_moneda       in  varchar2 default 'CRC',
    p_email        in  varchar2,
    p_nombre       in  varchar2,
    p_apellido     in  varchar2,
    p_url_redirect in  varchar2,
    p_app_id       in  number   default null,
    p_workspace    in  varchar2 default null,
    p_orden_id     out number,
    p_order_number out varchar2,
    p_token        out varchar2,
    p_error        out varchar2
  ) is
    l_id     number;
    l_ord    varchar2(64);
    l_cap    number;
  begin
    p_error := null;
    l_id    := ns_pay_orden_seq.nextval;
    l_ord   := 'NS-' || to_char(sysdate, 'YYYYMMDD') || '-' ||
               ltrim(to_char(l_id, '00000009'));

    select capture_default
      into l_cap
      from ns_pay_config
     where ambiente = p_ambiente
       and activo   = 'S';

    insert into ns_pay_orden (
      id_orden, order_number, ambiente, app_id, workspace,
      moneda, monto, email, nombre, apellido, estado, capture, url_redirect
    ) values (
      l_id, l_ord, p_ambiente, p_app_id, p_workspace,
      nvl(p_moneda, 'CRC'), p_monto, p_email, p_nombre, p_apellido,
      'PENDIENTE', l_cap, p_url_redirect
    );

    p_orden_id     := l_id;
    p_order_number := l_ord;
    p_token        := get_token_sdk(p_ambiente, l_id);
    commit;
  exception
    when others then
      p_error := substr(sqlerrm, 1, 400);
      log_evento(p_orden_id, 'INICIAR_ERR', null, p_error);
  end iniciar;

  procedure procesar_callback (
    p_order_number in  varchar2,
    p_code         in  varchar2,
    p_auth         in  varchar2,
    p_order_hash   in  varchar2,
    p_tpt          in  varchar2,
    p_descripcion  in  varchar2,
    p_crd          in  varchar2 default null,
    p_metodo       in  varchar2 default null,
    p_estado       out varchar2,
    p_error        out varchar2
  ) is
    l_ord ns_pay_orden%rowtype;
    l_ok  varchar2(1);
  begin
    p_error := null;

    select * into l_ord
      from ns_pay_orden
     where order_number = p_order_number
       for update;

    if l_ord.estado = 'PAGADO' then
      p_estado := l_ord.estado;
      return;
    end if;

    l_ok := hash_ok(
              l_ord.ambiente, l_ord.order_number, l_ord.monto, l_ord.moneda,
              p_tpt, p_code, p_auth, l_ord.email, p_order_hash
            );

    update ns_pay_orden
       set tilopay_id     = p_tpt,
           auth_code      = p_auth,
           code_cb        = p_code,
           order_hash     = p_order_hash,
           card_token     = p_crd,
           metodo         = nvl(p_metodo, metodo),
           descripcion_cb = substr(p_descripcion, 1, 400)
     where id_orden = l_ord.id_orden;

    if p_code = '1' and p_auth is not null and length(p_auth) >= 6 and l_ok = 'S' then
      update ns_pay_orden
         set estado = 'PAGADO', fec_paga = sysdate
       where id_orden = l_ord.id_orden;
      p_estado := 'PAGADO';
    elsif p_code = '1' and l_ok = 'N' then
      update ns_pay_orden
         set estado = 'PENDIENTE_HASH'
       where id_orden = l_ord.id_orden;
      p_estado := 'PENDIENTE_HASH';
    elsif p_code = 'Pending' then
      update ns_pay_orden
         set estado = 'EN_ESPERA'
       where id_orden = l_ord.id_orden;
      p_estado := 'EN_ESPERA';
    else
      update ns_pay_orden
         set estado = 'RECHAZADO'
       where id_orden = l_ord.id_orden;
      p_estado := 'RECHAZADO';
    end if;

    log_evento(l_ord.id_orden, 'CALLBACK', null,
               'code=' || p_code || ' auth=' || p_auth || ' tpt=' || p_tpt);
    commit;
  exception
    when no_data_found then
      p_error  := 'Orden no existe: ' || p_order_number;
      p_estado := 'RECHAZADO';
    when others then
      p_error := substr(sqlerrm, 1, 400);
  end procesar_callback;

  procedure probar_login is
    l_cfg  ns_pay_config%rowtype;
    l_resp clob;
    l_http number;

    procedure un_intento (p_tipo varchar2, p_url varchar2, p_body varchar2) is
    begin
      apex_web_service.g_request_headers(1).name  := 'Content-Type';
      apex_web_service.g_request_headers(1).value := 'application/json';
      begin
        l_resp := apex_web_service.make_rest_request(
                    p_url         => p_url,
                    p_http_method => 'POST',
                    p_body        => p_body
                  );
        l_http := apex_web_service.g_status_code;
        log_evento(
          null,
          p_tipo,
          l_http,
          'url=' || p_url
            || ' user=' || l_cfg.api_user
            || ' key=' || l_cfg.api_key
            || ' http=' || l_http
            || ' resp=' || dbms_lob.substr(l_resp, 3000, 1)
        );
      exception
        when others then
          log_evento(null, p_tipo, null, substr(sqlerrm, 1, 4000));
      end;
    end un_intento;
  begin
    select * into l_cfg
      from ns_pay_config
     where ambiente = 'SANDBOX'
       and activo   = 'S';

    -- 1) loginSdk: las tres (doc token-sdk)
    un_intento(
      'PRUEBA_LOGIN',
      nvl(l_cfg.url_get_token, 'https://app.tilopay.com/api/v1/loginSdk'),
      '{"apiuser":"' || l_cfg.api_user
        || '","password":"' || l_cfg.api_password
        || '","key":"' || l_cfg.api_key || '"}'
    );

    -- 2) login API: solo user+password (Postman Get Token Api)
    un_intento(
      'PRUEBA_LOGIN_API',
      'https://app.tilopay.com/api/v1/login',
      '{"apiuser":"' || l_cfg.api_user
        || '","password":"' || l_cfg.api_password || '"}'
    );
  end probar_login;

end ns_pay_tilopay;
/
