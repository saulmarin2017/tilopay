/*
  Cliente : NAVASOFT (interno)
  Proyecto: tilopay
  Fecha   : 2026-09-11
  Objetivo: ACL HTTPS para WKSP_PRUEBAS → Tilopay.
            UTL_HTTP desde el schema da ORA-24247.
            APEX_WEB_SERVICE sí sale (usa ACL del engine APEX) y
            llega a loginSdk con HTTP 401.
  Ambiente: ADB. **No** corre en SQL Workshop de WKSP_PRUEBAS
            (PLS-00201: DBMS_NETWORK_ACL_ADMIN must be declared).
            Correr en Database Actions → SQL, usuario ADMIN
            (OCI → ADB FD95NRDCE4PBVCVY → Database Actions).
  Prereq  : privilegio para DBMS_NETWORK_ACL_ADMIN
  Notas   : hosts del SDK V2 / API. Puerto 443.
            Idempotente: si el ACE ya existe, se ignora ORA-46252 / -955.
*/

-- Run 1 (ADMIN): resolve SIN puerto; connect en 443.
-- ORA-24244 si resolve va con lower_port/upper_port.
begin
  dbms_network_acl_admin.append_host_ace(
    host => 'app.tilopay.com',
    ace  => xs$ace_type(
              privilege_list => xs$name_list('resolve'),
              principal_name => 'WKSP_PRUEBAS',
              principal_type => xs_acl.ptype_db
            )
  );
  dbms_network_acl_admin.append_host_ace(
    host       => 'app.tilopay.com',
    lower_port => 443,
    upper_port => 443,
    ace        => xs$ace_type(
                    privilege_list => xs$name_list('connect'),
                    principal_name => 'WKSP_PRUEBAS',
                    principal_type => xs_acl.ptype_db
                  )
  );
  dbms_network_acl_admin.append_host_ace(
    host => 'secure.tilopay.com',
    ace  => xs$ace_type(
              privilege_list => xs$name_list('resolve'),
              principal_name => 'WKSP_PRUEBAS',
              principal_type => xs_acl.ptype_db
            )
  );
  dbms_network_acl_admin.append_host_ace(
    host       => 'secure.tilopay.com',
    lower_port => 443,
    upper_port => 443,
    ace        => xs$ace_type(
                    privilege_list => xs$name_list('connect'),
                    principal_name => 'WKSP_PRUEBAS',
                    principal_type => xs_acl.ptype_db
                  )
  );
  dbms_network_acl_admin.append_host_ace(
    host => 'securepayment.tilopay.com',
    ace  => xs$ace_type(
              privilege_list => xs$name_list('resolve'),
              principal_name => 'WKSP_PRUEBAS',
              principal_type => xs_acl.ptype_db
            )
  );
  dbms_network_acl_admin.append_host_ace(
    host       => 'securepayment.tilopay.com',
    lower_port => 443,
    upper_port => 443,
    ace        => xs$ace_type(
                    privilege_list => xs$name_list('connect'),
                    principal_name => 'WKSP_PRUEBAS',
                    principal_type => xs_acl.ptype_db
                  )
  );
  commit;
end;
