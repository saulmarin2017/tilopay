/*
  Cliente : NAVASOFT (interno)
  Proyecto: tilopay
  Objetivo: Habilitar REST en WKSP_PRUEBAS (alias pruebas)
  Ambiente: DEV / sandbox
  Notas   : APEX ya suele tener el schema habilitado.
            Si el SELECT de abajo devuelve una fila, NO hace falta correr el BEGIN.
            DEFINE_MODULE no va aquí (borra templates).
*/

-- Verificar:
-- SELECT parsing_schema, pattern FROM user_ords_schemas;

BEGIN
  ORDS.ENABLE_SCHEMA(
    p_enabled             => TRUE,
    p_schema              => 'WKSP_PRUEBAS',
    p_url_mapping_type    => 'BASE_PATH',
    p_url_mapping_pattern => 'pruebas',
    p_auto_rest_auth      => FALSE
  );
  COMMIT;
END;
/
