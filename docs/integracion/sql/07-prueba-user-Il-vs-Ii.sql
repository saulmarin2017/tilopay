/*
  Cliente : NAVASOFT (interno)
  Proyecto: tilopay
  Fecha   : 2026-09-11
  Objetivo: Probar apiuser BVIlkv (BD) vs BVIikv (I+i, lectura Postman)
            con UTL_HTTP. SQL Commands: sin DUMP, sin BOOLEAN, sin nested proc.
  Ambiente: SQL Commands / WKSP_PRUEBAS
*/

declare
  l_cfg  ns_pay_config%rowtype;
  l_req  utl_http.req;
  l_resp utl_http.resp;
  l_buf  varchar2(32767);
  l_out  varchar2(4000);
  l_http number;
  l_body varchar2(4000);
  l_user varchar2(30);
  l_tipo varchar2(30);
  l_pay  varchar2(4000);
  i      number;
begin
  utl_http.set_detailed_excp_support(true);

  select * into l_cfg
    from ns_pay_config
   where ambiente = 'SANDBOX'
     and activo   = 'S';

  for i in 1 .. 2 loop
    if i = 1 then
      l_user := 'BVIlkv';
      l_tipo := 'PRUEBA_USER_Il';
    else
      l_user := 'BVIikv';
      l_tipo := 'PRUEBA_USER_Ii';
    end if;

    l_out  := '';
    l_body := '{"apiuser":"' || l_user
           || '","password":"' || trim(l_cfg.api_password)
           || '","key":"' || trim(l_cfg.api_key) || '"}';

    begin
      l_req := utl_http.begin_request(
                 'https://app.tilopay.com/api/v1/loginSdk',
                 'POST',
                 'HTTP/1.1'
               );
      utl_http.set_header(l_req, 'Content-Type', 'application/json');
      utl_http.set_header(l_req, 'Content-Length', to_char(lengthb(l_body)));
      utl_http.write_text(l_req, l_body);
      l_resp := utl_http.get_response(l_req);
      l_http := l_resp.status_code;
      begin
        loop
          utl_http.read_text(l_resp, l_buf, 800);
          l_out := substr(l_out || l_buf, 1, 1500);
        end loop;
      exception
        when utl_http.end_of_body then
          null;
      end;
      utl_http.end_response(l_resp);

      l_pay := 'user=' || l_user || ' http=' || l_http
            || ' resp=' || substr(l_out, 1, 400);
      insert into ns_pay_evento (id_evento, tipo, http_code, payload)
      values (ns_pay_evento_seq.nextval, l_tipo, l_http, l_pay);
      commit;
    exception
      when others then
        l_pay := substr(sqlerrm, 1, 4000);
        insert into ns_pay_evento (id_evento, tipo, http_code, payload)
        values (ns_pay_evento_seq.nextval, l_tipo, null, l_pay);
        commit;
    end;
  end loop;
end;
