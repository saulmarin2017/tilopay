/*
  Cliente : NAVASOFT (interno)
  Proyecto: tilopay
  Origen  : 2-CASO-20260819-pasarela-pagos-tilopay (investigación, cerrado)
  Fecha   : 2026-09-01
  Autor   : Saúl / Grok Build
  Objetivo: Tablas de órdenes de pago virtual (carrusel Tilopay)
  Ambiente: DEV (no correr en PROD sin confirmación)
  Esquema : WKSP_PRUEBAS (SQL Workshop; app APEX 110 Tilopay)
  Notas   : Idempotente a nivel de "si ya existe, no recrear".
            No guarda PAN ni CVV. Password de API se enmascara en eventos.
*/

-- ============================================================================
-- NS_PAY_CONFIG  — un registro por ambiente
-- ============================================================================
begin
  execute immediate q'[
    create table ns_pay_config (
      ambiente          varchar2(10)   not null,
      api_key           varchar2(80)   not null,
      api_user          varchar2(80)   not null,
      api_password      varchar2(80)   not null,
      url_get_token     varchar2(400)  not null,
      url_sdk           varchar2(400)  default 'https://app.tilopay.com/sdk/v2/sdk_tpay.min.js' not null,
      capture_default   number(1)      default 1 not null,
      hmac_secreto      varchar2(200),
      moneda_default    varchar2(3)    default 'CRC' not null,
      activo            varchar2(1)    default 'S' not null,
      fec_actualiza     date           default sysdate not null,
      constraint ns_pay_config_pk primary key (ambiente),
      constraint ns_pay_config_amb_ck check (ambiente in ('SANDBOX','PROD')),
      constraint ns_pay_config_cap_ck check (capture_default in (0,1)),
      constraint ns_pay_config_act_ck check (activo in ('S','N'))
    )
  ]';
exception
  when others then
    if sqlcode != -955 then raise; end if;
end;
/

comment on table ns_pay_config is 'Credenciales Tilopay por ambiente. No versionar valores reales.';

-- ============================================================================
-- NS_PAY_ORDEN
-- ============================================================================
begin
  execute immediate q'[
    create table ns_pay_orden (
      id_orden          number         not null,
      order_number      varchar2(64)   not null,
      ambiente          varchar2(10)   not null,
      app_id            number,
      workspace         varchar2(50),
      moneda            varchar2(3)    not null,
      monto             number(14,2)   not null,
      email             varchar2(200)  not null,
      nombre            varchar2(80),
      apellido          varchar2(80),
      estado            varchar2(20)   not null,
      capture           number(1)      default 1 not null,
      metodo            varchar2(40),
      tilopay_id        varchar2(80),
      auth_code         varchar2(40),
      code_cb           varchar2(20),
      order_hash        varchar2(80),
      card_token        varchar2(120),
      descripcion_cb    varchar2(400),
      url_redirect      varchar2(400),
      fec_crea          date           default sysdate not null,
      fec_paga          date,
      constraint ns_pay_orden_pk primary key (id_orden),
      constraint ns_pay_orden_uk unique (order_number),
      constraint ns_pay_orden_est_ck check (estado in (
        'PENDIENTE','PAGADO','RECHAZADO','CANCELADO','EN_ESPERA','PENDIENTE_HASH'
      )),
      constraint ns_pay_orden_cap_ck check (capture in (0,1))
    )
  ]';
exception
  when others then
    if sqlcode != -955 then raise; end if;
end;
/

begin
  execute immediate 'create sequence ns_pay_orden_seq start with 1 increment by 1 nocache';
exception
  when others then
    if sqlcode != -955 then raise; end if;
end;
/

comment on table ns_pay_orden is 'Una fila por intento de cobro Tilopay. order_number no se reutiliza.';

-- ============================================================================
-- NS_PAY_EVENTO  — bitácora API / callback (sin secretos)
-- ============================================================================
begin
  execute immediate q'[
    create table ns_pay_evento (
      id_evento         number         not null,
      id_orden          number,
      tipo              varchar2(30)   not null,
      http_code         number,
      payload           clob,
      fec_evento        date           default sysdate not null,
      constraint ns_pay_evento_pk primary key (id_evento)
    )
  ]';
exception
  when others then
    if sqlcode != -955 then raise; end if;
end;
/

begin
  execute immediate 'create sequence ns_pay_evento_seq start with 1 increment by 1 nocache';
exception
  when others then
    if sqlcode != -955 then raise; end if;
end;
/

comment on table ns_pay_evento is 'Log de GetTokenSdk y callbacks. Enmascarar passwords.';
