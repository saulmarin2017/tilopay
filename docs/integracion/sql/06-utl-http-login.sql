/*
  Cliente : NAVASOFT (interno)
  Proyecto: tilopay
  Fecha   : 2026-09-11
  Objetivo: loginSdk 401 con APEX_WEB_SERVICE (probar_login y FMT).
            Claves en NS_PAY_CONFIG son correctas (DUMP). Postman 200.
            Aislar: UTL_HTTP sin Authorization (SQL Workshop / App Builder
            puede inyectar headers en APEX_WEB_SERVICE).
  Ambiente: SQL Commands / WKSP_PRUEBAS
  Notas   : Un solo BEGIN. Luego SELECT tipo like 'PRUEBA_LOGIN_UTL%'.
*/

declare
  l_cfg  ns_pay_config%rowtype;
  l_body varchar2(4000);
  l_req  utl_http.req;
  l_resp utl_http.resp;
  l_buf  varchar2(32767);
  l_out  varchar2(4000);
  l_http number;
  l_reas varchar2(256);
  l_got  boolean;

  procedure un_try (p_tipo varchar2, p_ua varchar2) is
  begin
    l_out := '';
    l_got := false;
    l_req := utl_http.begin_request(
               url          => 'https://app.tilopay.com/api/v1/loginSdk',
               method       => 'POST',
               http_version => 'HTTP/1.1'
             );
    utl_http.set_header(l_req, 'Content-Type', 'application/json');
    utl_http.set_header(l_req, 'Accept', 'application/json');
    utl_http.set_header(l_req, 'Content-Length', to_char(lengthb(l_body)));
    if p_ua is not null then
      utl_http.set_header(l_req, 'User-Agent', p_ua);
    end if;
    utl_http.write_text(l_req, l_body);
    l_resp := utl_http.get_response(l_req);
    l_got  := true;
    l_http := l_resp.status_code;
    l_reas := l_resp.reason_phrase;
    begin
      loop
        utl_http.read_text(l_resp, l_buf, 800);
        l_out := substr(l_out || l_buf, 1, 3500);
      end loop;
    exception
      when utl_http.end_of_body then
        null;
    end;
    utl_http.end_response(l_resp);
    insert into ns_pay_evento (id_evento, tipo, http_code, payload)
    values (
      ns_pay_evento_seq.nextval,
      p_tipo,
      l_http,
      'reason=' || l_reas
      || ' ua=' || nvl(p_ua, '(default)')
      || ' lenb=' || lengthb(l_body)
      || ' resp=' || substr(l_out, 1, 800)
    );
    commit;
  exception
    when others then
      if l_got then
        begin
          utl_http.end_response(l_resp);
        exception
          when others then null;
        end;
      else
        begin
          utl_http.end_request(l_req);
        exception
          when others then null;
        end;
      end if;
      insert into ns_pay_evento (id_evento, tipo, http_code, payload)
      values (
        ns_pay_evento_seq.nextval,
        p_tipo,
        null,
        substr(sqlerrm, 1, 4000)
      );
      commit;
  end un_try;
begin
  utl_http.set_detailed_excp_support(true);

  select * into l_cfg
    from ns_pay_config
   where ambiente = 'SANDBOX'
     and activo   = 'S';

  l_body := '{ "apiuser" : "' || trim(l_cfg.api_user)
         || '", "password" : "' || trim(l_cfg.api_password)
         || '", "key": "' || trim(l_cfg.api_key) || '" }';

  un_try('PRUEBA_LOGIN_UTL',    null);
  un_try('PRUEBA_LOGIN_UTL_UA', 'PostmanRuntime/7.37.3');
end;
