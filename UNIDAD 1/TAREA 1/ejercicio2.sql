-- 2) Crear un trigger en RESERVAS que registre en una bitácora el importe anterior y el 
-- importe nuevo, además de la fecha del cambio y el usuario que llevó a cabo la operación. 
-- El trigger debe ser capaz de controlar los errores que se produzcan en la bitácora. La 
-- bitácora debe tener un ID único que la identifique y el cual debe ser generado mediante 
-- una secuencia.


-- creamos la tabla para poder llevar la bitacora de los nuevos y antiguos registros de la tabla reservas. 
-- solo pide el importe anterior , importoe nuevo, fecha de cambio y el usuario que lo hizo 

create table TBL_LOG_RESERVAS (
   ID_RESERVA       varchar2(10 byte),
   IMPORTE_VIEJO    number,
   IMPORTE_NUEVO    number,
   FECHA_CAMBIO     timestamp,
   USUARIO_MODIFICO varchar2(10 byte)
);

alter table TBL_LOG_RESERVAS add (
   TIPO_OPERACION varchar2(50)
);

alter table TBL_LOG_RESERVAS modify (
   USUARIO_MODIFICO varchar2(50)
);

alter table TBL_LOG_RESERVAS add (
   ID_BITACORA number
);

alter table TBL_LOG_RESERVAS add constraint PK_ID_BITACORA primary key ( ID_BITACORA );


create sequence SQ_ID_BITACORA start with 1 increment by 1 nocache;



select *
  from TBL_LOG_RESERVAS;



create or replace trigger TG_LOG_RESERVAS after
   update or insert or delete on RESERVAS
   for each row
declare begin
   if ( INSERTING ) then
      insert into TBL_LOG_RESERVAS (
         ID_BITACORA,
         ID_RESERVA,
         IMPORTE_VIEJO,
         IMPORTE_NUEVO,
         FECHA_CAMBIO,
         USUARIO_MODIFICO,
         TIPO_OPERACION
      ) values ( SQ_ID_BITACORA.nextval,
                 :NEW.ID_RESERVA,
                 null,
                 :NEW.IMPORTE,
                 SYSDATE,
                 USER,
                 'INSERCION' );
   elsif ( UPDATING ) then
      insert into TBL_LOG_RESERVAS (
         ID_BITACORA,
         ID_RESERVA,
         IMPORTE_VIEJO,
         IMPORTE_NUEVO,
         FECHA_CAMBIO,
         USUARIO_MODIFICO,
         TIPO_OPERACION
      ) values ( SQ_ID_BITACORA.nextval,
                 :NEW.ID_RESERVA,
                 :OLD.IMPORTE,
                 :NEW.IMPORTE,
                 SYSDATE,
                 USER,
                 'ACTUALIZACION' );
   elsif ( DELETING ) then
      insert into TBL_LOG_RESERVAS (
         ID_BITACORA,
         ID_RESERVA,
         IMPORTE_VIEJO,
         IMPORTE_NUEVO,
         FECHA_CAMBIO,
         USUARIO_MODIFICO,
         TIPO_OPERACION
      ) values ( SQ_ID_BITACORA.nextval,
                 :OLD.ID_RESERVA,
                 :OLD.IMPORTE,
                 null,
                 SYSDATE,
                 USER,
                 'ELIMINACION' );

   end if;
exception
   when others then
      DBMS_OUTPUT.PUT_LINE('CÓDIGO DEL ERROR: ' || SQLCODE);
      DBMS_OUTPUT.PUT_LINE('MENSAJE DEL ERROR: ' || SQLERRM);
end;

insert into RESERVAS values ( 'KGxWeUVa',
                              13.3,
                              '9238-Q',
                              'TEL',
                              30,
                              26,
                              99138 );


delete from RESERVAS;


select count(*)
  from TBL_LOG_RESERVAS;