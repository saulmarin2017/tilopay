/*
  Cliente : NAVASOFT (interno)
  Proyecto: tilopay
  Fecha   : 2026-09-01
  Objetivo: Llamar loginSdk. NO pegar esto en SQL Commands (parte en DELETE/INSERT).
  Ambiente: WKSP_PRUEBAS

  1. SQL Workshop → SQL Scripts → correr de nuevo 02-pkg-tilopay.sql
     (ahora incluye NS_PAY_TILOPAY.probar_login)
  2. SQL Commands, SOLO esto:

       begin
         ns_pay_tilopay.probar_login;
       end;

  3. Otro Run:

       select id_evento, http_code, substr(payload, 1, 1000) payload, fec_evento
         from ns_pay_evento
        where tipo = 'PRUEBA_LOGIN'
        order by id_evento desc;
*/
