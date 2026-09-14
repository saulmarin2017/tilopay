/*
  Cliente : NAVASOFT (interno)
  Proyecto: tilopay
  Objetivo: Guardar el hmac_secreto del correo de Tilopay (opcional si V2
            con api_key|api_password ya valida).
  Dónde   : SQL Workshop WKSP_PRUEBAS
  Notas   : NO pegar el valor en Git ni en el chat. Completar acá y Run.
*/

update ns_pay_config
   set hmac_secreto  = 'PEGAR_AQUI_EL_SECRETO_DEL_CORREO',
       fec_actualiza = sysdate
 where ambiente = 'SANDBOX';
commit;

select ambiente,
       case when hmac_secreto is null then 'VACIO' else 'OK' end as hmac
  from ns_pay_config
 where ambiente = 'SANDBOX';
