/*
  Cliente : NAVASOFT (interno)
  Proyecto: tilopay
  Objetivo: GET /tilopay/retorno — procesar callback sin depender del WebView APEX
  Módulo  : tilopay-module (NO DEFINE_MODULE)
  URL     : .../ords/pruebas/tilopay/retorno?code=1&order=NS-...&auth=...&OrderHash=...&tpt=...
*/

SET DEFINE OFF

BEGIN
  ORDS.DEFINE_TEMPLATE(
    p_module_name => 'tilopay-module',
    p_pattern     => 'retorno',
    p_priority    => 0,
    p_etag_type   => 'HASH',
    p_comments    => 'GET query Tilopay → ns_pay_tilopay.procesar_callback'
  );

  ORDS.DEFINE_HANDLER(
    p_module_name    => 'tilopay-module',
    p_pattern        => 'retorno',
    p_method         => 'GET',
    p_source_type    => 'plsql/block',
    p_items_per_page => 0,
    p_comments       => 'GET /tilopay/retorno',
    p_source         => q'[
DECLARE
  l_qs    VARCHAR2(4000);
  l_order VARCHAR2(64);
  l_code  VARCHAR2(20);
  l_auth  VARCHAR2(40);
  l_hash  VARCHAR2(80);
  l_tpt   VARCHAR2(80);
  l_desc  VARCHAR2(400);
  l_crd   VARCHAR2(120);
  l_est   VARCHAR2(20);
  l_err   VARCHAR2(400);

  FUNCTION qparam (p_qs VARCHAR2, p_name VARCHAR2) RETURN VARCHAR2 IS
    l VARCHAR2(4000);
  BEGIN
    l := regexp_substr(p_qs, '(^|&)' || p_name || '=([^&]*)', 1, 1, 'i', 2);
    RETURN utl_url.unescape(REPLACE(NVL(l, ''), '+', ' '));
  END;
BEGIN
  l_qs    := owa_util.get_cgi_env('QUERY_STRING');
  l_order := qparam(l_qs, 'order');
  l_code  := qparam(l_qs, 'code');
  l_auth  := qparam(l_qs, 'auth');
  l_hash  := qparam(l_qs, 'OrderHash');
  l_tpt   := NVL(qparam(l_qs, 'tpt'), qparam(l_qs, 'tilopay-transaction'));
  l_desc  := qparam(l_qs, 'description');
  l_crd   := qparam(l_qs, 'crd');

  IF l_order IS NULL THEN
    owa_util.status_line(400, 'Bad Request', FALSE);
    owa_util.mime_header('application/json', TRUE, 'UTF-8');
    htp.p('{"error":"sin order","estado":null}');
    RETURN;
  END IF;

  ns_pay_tilopay.procesar_callback(
    p_order_number => l_order,
    p_code         => l_code,
    p_auth         => l_auth,
    p_order_hash   => l_hash,
    p_tpt          => l_tpt,
    p_descripcion  => l_desc,
    p_crd          => l_crd,
    p_estado       => l_est,
    p_error        => l_err
  );

  owa_util.mime_header('application/json', TRUE, 'UTF-8');
  htp.p('{"orderNumber":"' || REPLACE(l_order, '"', '') ||
        '","estado":"' || NVL(l_est, '') ||
        '","error":' || CASE WHEN l_err IS NULL THEN 'null' ELSE '"' || REPLACE(REPLACE(l_err, '\', '\\'), '"', '\"') || '"' END ||
        '}');
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
