/*
  Cliente : NAVASOFT (interno)
  Proyecto: tilopay
  Objetivo: GRANT DBMS_CRYPTO para HMAC-SHA256 de OrderHash
  Dónde   : Database Actions / SQL, usuario ADMIN (no WKSP_PRUEBAS)
  Después : SQL Workshop WKSP_PRUEBAS → recompilar 02-pkg-tilopay.sql
*/

grant execute on sys.dbms_crypto to wksp_pruebas;
/
