/*
  Cliente : NAVASOFT (interno)
  Proyecto: tilopay
  Objetivo: Templates del módulo UI `tilopay-module` (base /tilopay/)
  Schema  : WKSP_PRUEBAS
  URL     : https://g147092bf4447e7-fd95nrdce4pbvcwy.adb.sa-bogota-1.oraclecloudapps.com/ords/pruebas/tilopay/

  NO llama ORDS.DEFINE_MODULE (eso borra templates).
  El módulo ya existe en RESTful Services.

  POST .../tilopay/iniciar
  GET  .../tilopay/orden/:orderNumber
*/

SET DEFINE OFF

BEGIN
  ORDS.DEFINE_TEMPLATE(
    p_module_name => 'tilopay-module',
    p_pattern     => 'iniciar',
    p_priority    => 0,
    p_etag_type   => 'HASH',
    p_comments    => 'POST JSON: crea orden + token loginSdk'
  );

  ORDS.DEFINE_HANDLER(
    p_module_name    => 'tilopay-module',
    p_pattern        => 'iniciar',
    p_method         => 'POST',
    p_source_type    => 'plsql/block',
    p_mimes_allowed  => 'application/json',
    p_items_per_page => 0,
    p_comments       => 'POST /tilopay/iniciar',
    p_source         => q'[
DECLARE
  l_id       NUMBER;
  l_ord      VARCHAR2(64);
  l_token    VARCHAR2(4000);
  l_err      VARCHAR2(400);
  l_host     VARCHAR2(400);
  l_base     VARCHAR2(400);
  l_redirect VARCHAR2(400);
  l_checkout VARCHAR2(400);
  l_monto    NUMBER;
  l_moneda   VARCHAR2(3);
  l_email    VARCHAR2(200);
  l_nombre   VARCHAR2(80);
  l_apellido VARCHAR2(80);
  l_json     JSON_OBJECT_T;
  l_payload  CLOB;
  l_out      CLOB;
  l_off      INTEGER := 1;
  l_len      INTEGER;
BEGIN
  l_payload := :body_text;
  IF l_payload IS NULL OR NVL(DBMS_LOB.getlength(l_payload), 0) = 0 THEN
    l_json := JSON_OBJECT_T();
  ELSE
    l_json := JSON_OBJECT_T.parse(l_payload);
  END IF;

  BEGIN
    l_monto := NVL(l_json.get_number('monto'), 100);
  EXCEPTION
    WHEN OTHERS THEN
      BEGIN
        l_monto := TO_NUMBER(REPLACE(NVL(l_json.get_string('monto'), '100'), ',', '.'));
      EXCEPTION
        WHEN OTHERS THEN
          l_monto := 100;
      END;
  END;

  l_moneda   := NVL(l_json.get_string('moneda'), 'CRC');
  l_email    := NVL(l_json.get_string('email'), 'prueba@navasoftsoluciones.com');
  l_nombre   := NVL(l_json.get_string('nombre'), 'Saul');
  l_apellido := NVL(l_json.get_string('apellido'), 'Marin');

  l_host := NVL(owa_util.get_cgi_env('X-Forwarded-Host'),
            NVL(owa_util.get_cgi_env('HTTP_HOST'), ''));
  l_base := 'https://' || l_host || '/ords';
  l_redirect := l_base || '/r/pruebas/tilopay/callback';
  l_checkout := l_base || '/r/pruebas/tilopay/home';

  ns_pay_tilopay.iniciar(
    p_ambiente     => 'SANDBOX',
    p_monto        => l_monto,
    p_moneda       => l_moneda,
    p_email        => l_email,
    p_nombre       => l_nombre,
    p_apellido     => l_apellido,
    p_url_redirect => l_redirect,
    p_app_id       => 110,
    p_workspace    => 'WKSP_PRUEBAS',
    p_orden_id     => l_id,
    p_order_number => l_ord,
    p_token        => l_token,
    p_error        => l_err
  );

  owa_util.mime_header('application/json', TRUE, 'UTF-8');

  SELECT JSON_OBJECT(
           'orderNumber' VALUE l_ord,
           'token'       VALUE l_token,
           'checkoutUrl' VALUE l_checkout,
           'error'       VALUE l_err
           RETURNING CLOB
         )
    INTO l_out
    FROM dual;

  l_len := NVL(DBMS_LOB.getlength(l_out), 0);
  WHILE l_off <= l_len LOOP
    htp.prn(DBMS_LOB.SUBSTR(l_out, 4000, l_off));
    l_off := l_off + 4000;
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    owa_util.status_line(500, 'Internal Server Error', FALSE);
    owa_util.mime_header('application/json', TRUE, 'UTF-8');
    htp.p('{"orderNumber":null,"token":null,"checkoutUrl":null,"error":"'
      || REPLACE(REPLACE(SQLERRM, '\', '\\'), '"', '\"')
      || '"}');
END;
]'
  );

  ORDS.DEFINE_TEMPLATE(
    p_module_name => 'tilopay-module',
    p_pattern     => 'orden/:orderNumber',
    p_priority    => 0,
    p_etag_type   => 'HASH',
    p_comments    => 'GET estado de una orden'
  );

  ORDS.DEFINE_HANDLER(
    p_module_name    => 'tilopay-module',
    p_pattern        => 'orden/:orderNumber',
    p_method         => 'GET',
    p_source_type    => 'plsql/block',
    p_items_per_page => 0,
    p_comments       => 'GET /tilopay/orden/:orderNumber',
    p_source         => q'[
DECLARE
  l_out CLOB;
  l_n   NUMBER;
BEGIN
  SELECT COUNT(*) INTO l_n
    FROM ns_pay_orden
   WHERE order_number = :orderNumber;

  IF l_n = 0 THEN
    owa_util.status_line(404, 'Not Found', FALSE);
    owa_util.mime_header('application/json', TRUE, 'UTF-8');
    htp.p('{"error":"not_found","orderNumber":"'
      || REPLACE(:orderNumber, '"', '')
      || '"}');
    RETURN;
  END IF;

  owa_util.mime_header('application/json', TRUE, 'UTF-8');

  SELECT JSON_OBJECT(
           'orderNumber' VALUE o.order_number,
           'estado'      VALUE o.estado,
           'monto'       VALUE o.monto,
           'moneda'      VALUE o.moneda,
           'authCode'    VALUE o.auth_code,
           'code'        VALUE o.code_cb,
           'tilopayId'   VALUE o.tilopay_id,
           'error'       VALUE CAST(NULL AS VARCHAR2(1))
           RETURNING CLOB
         )
    INTO l_out
    FROM ns_pay_orden o
   WHERE o.order_number = :orderNumber;

  htp.prn(l_out);
EXCEPTION
  WHEN OTHERS THEN
    owa_util.status_line(500, 'Internal Server Error', FALSE);
    owa_util.mime_header('application/json', TRUE, 'UTF-8');
    htp.p('{"error":"' || REPLACE(REPLACE(SQLERRM, '\', '\\'), '"', '\"') || '"}');
END;
]'
  );

  COMMIT;
END;
/
