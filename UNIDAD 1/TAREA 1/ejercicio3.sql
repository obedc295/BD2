-- 3) Crear un bloque anónimo que se encargue de insertar un registro en la tabla vuelos, se 
-- debe verificar que la fecha del vuelo sea mayor cinco días a la fecha actual del servidor. 
-- En caso de no cumplirse con la condición antes mencionada, guardar una bitácora con los 
-- valores del registro que se intentó ingresa, si las condiciones se cumplen entonces se 
-- debe insertar el registro y adicionalmente guardar una bitácora con los valores insertados. 
-- Si la inserción genera cualquier error, se debe controlar y mostrar un mensaje 
-- personalizado. (valor 15%) 

create sequence SQ_ID_BITACORA start with 1 increment by 1 nocache;

create table TBL_LOG_VUELOS (
   ID_BITACORA           number,
   "ID_VUELO"            number(9,0) not null enable,
   "FECHA_VUELO"         date not null enable,
   "DETALLES"            varchar2(300 byte),
   "AER_ID_AERO"         varchar2(3 byte),
   "COMP_ID_COMP"        varchar2(5 byte),
   "TVUE_ID_VUELO"       varchar2(3 byte),
   "CAT_ID_CATERING"     varchar2(2 byte),
   "AER_ID_AERO_DESTINO" varchar2(3 byte)
);

select *
  from VUELOS;

declare
   V_DATOS        VUELOS%ROWTYPE;
   V_FECHA_MINIMA date;
begin
   V_FECHA_MINIMA := SYSDATE + 5;
   V_DATOS.ID_VUELO := 999999;
   V_DATOS.FECHA_VUELO := SYSDATE + 6;
   V_DATOS.DETALLES := 'VUELO999999';
   V_DATOS.AER_ID_AERO := 'ESX';
   V_DATOS.COMP_ID_COMP := 'AIREU';
   V_DATOS.TVUE_ID_VUELO := 'REG';
   V_DATOS.CAT_ID_CATERING := 'NO';
   V_DATOS.AER_ID_AERO_DESTINO := 'PMP';
   if ( V_DATOS.FECHA_VUELO < V_FECHA_MINIMA ) then
      insert into TBL_LOG_VUELOS values ( SQ_ID_BITACORA.nextval,
                                          V_DATOS.ID_VUELO,
                                          V_DATOS.FECHA_VUELO,
                                          V_DATOS.DETALLES,
                                          V_DATOS.AER_ID_AERO,
                                          V_DATOS.COMP_ID_COMP,
                                          V_DATOS.TVUE_ID_VUELO,
                                          V_DATOS.CAT_ID_CATERING,
                                          V_DATOS.AER_ID_AERO_DESTINO );
   else
      insert into TBL_LOG_VUELOS values ( SQ_ID_BITACORA.nextval,
                                          V_DATOS.ID_VUELO,
                                          V_DATOS.FECHA_VUELO,
                                          V_DATOS.DETALLES,
                                          V_DATOS.AER_ID_AERO,
                                          V_DATOS.COMP_ID_COMP,
                                          V_DATOS.TVUE_ID_VUELO,
                                          V_DATOS.CAT_ID_CATERING,
                                          V_DATOS.AER_ID_AERO_DESTINO );

      insert into VUELOS values ( V_DATOS.ID_VUELO,
                                  V_DATOS.FECHA_VUELO,
                                  V_DATOS.DETALLES,
                                  V_DATOS.AER_ID_AERO,
                                  V_DATOS.COMP_ID_COMP,
                                  V_DATOS.TVUE_ID_VUELO,
                                  V_DATOS.CAT_ID_CATERING,
                                  V_DATOS.AER_ID_AERO_DESTINO );

   end if;


exception
   when others then
      DBMS_OUTPUT.PUT_LINE('MENSAJE DE ERROR: ' || SQLERRM);
end;

   SET SERVEROUTPUT ON;

select *
  from TBL_LOG_VUELOS;