/*
TAREA #1 BASES DE DATOS 2 SEC:1100
INTEGRANTES GRUPO #7
20221003175	JEAN CARLOS GONZALEZ DE LA O
20221031507	CARLOS LEONEL GIRON VELASQUEZ
20231003205	BAYRON RENIERY DUARTE MATUTE
20241002161	OBED ELIEL CASTELLANOS OSEGUERA
*/

/*1. Hacer uso de un bloque anónimo que obtenga todos los vuelos realizados por la 
compañía Iberia en el año 2004 en el mes de junio. El bloque anónimo debe recorrer los 
registros e imprimir el código de vuelo, fecha del vuelo, detalles, la descripción de si el 
vuelo tiene incluido catering y qué tipo de vuelo es. Recorrer la información con un ciclo 
FOR y un cursor explícito. (valor 15%)*/
declare
   cursor CUR_VUELOS is
   select V.ID_VUELO,
          V.FECHA_VUELO,
          V.DETALLES,
          C.CN_CATERING,
          T.CN_VUELO
     from C##_VUELOS.VUELOS V
     join C##_VUELOS.COMPANIAS CO
   on CO.ID_COMP = V.COMP_ID_COMP
     join C##_VUELOS.CATERING C
   on C.ID_CATERING = V.CAT_ID_CATERING
     join C##_VUELOS.TIPOS_VUELO T
   on T.ID_VUELO = V.TVUE_ID_VUELO
    where CO.CN_COMP = 'Iberia'
      and extract(year from V.FECHA_VUELO) = 2004
      and extract(month from V.FECHA_VUELO) = 6;
begin
   DBMS_OUTPUT.PUT_LINE('====== VUELOS DE IBERIA - JUNIO 2004 ======');
   for REG in CUR_VUELOS loop
      DBMS_OUTPUT.PUT_LINE('Codigo   : ' || REG.ID_VUELO);
      DBMS_OUTPUT.PUT_LINE('Fecha    : ' || TO_CHAR(
         REG.FECHA_VUELO,
         'DD/MM/YYYY'
      ));
      DBMS_OUTPUT.PUT_LINE('Detalles : ' || REG.DETALLES);
      DBMS_OUTPUT.PUT_LINE('Catering : ' || REG.CN_CATERING);
      DBMS_OUTPUT.PUT_LINE('Tipo     : ' || REG.CN_VUELO);
      DBMS_OUTPUT.PUT_LINE('----------------------------------------');
   end loop;
end;
/

/*2) Crear un trigger en RESERVAS que registre en una bitácora el importe anterior y el 
importe nuevo, además de la fecha del cambio y el usuario que llevó a cabo la operación. 
El trigger debe ser capaz de controlar los errores que se produzcan en la bitácora. La 
bitácora debe tener un ID único que la identifique y el cual debe ser generado mediante 
una secuencia. (valor 20%) */

drop trigger TG_LOG_RESERVA;
drop table TBL_LOG_RESERVAS;
drop sequence SQ_RESERVAS_ID;

create sequence SQ_RESERVAS_ID start with 1 increment by 1;


create table TBL_LOG_RESERVAS (
   SQ_RESERVA_ID    number,
   ID_RESERVA       varchar2(100),
   IMPORTE_ANTERIOR number(10,2),
   IMPORTE_NUEVO    number(10,2),
   FECHA_CAMBIO     date,
   USUARIO          varchar2(100),
   OPERACION        varchar2(20)
);

create or replace trigger TG_LOG_RESERVAS before
   insert or update or delete on RESERVAS
   for each row
begin
   if INSERTING then
      insert into TBL_LOG_RESERVAS (
         SQ_RESERVA_ID,
         ID_RESERVA,
         IMPORTE_ANTERIOR,
         IMPORTE_NUEVO,
         FECHA_CAMBIO,
         USUARIO,
         OPERACION
      ) values ( SQ_RESERVAS_ID.nextval,
                 :NEW.ID_RESERVA,
                 null,
                 :NEW.IMPORTE,
                 SYSDATE,
                 USER,
                 'INSERT' );
   elsif UPDATING then
      insert into TBL_LOG_RESERVAS (
         SQ_RESERVA_ID,
         ID_RESERVA,
         IMPORTE_ANTERIOR,
         IMPORTE_NUEVO,
         FECHA_CAMBIO,
         USUARIO,
         OPERACION
      ) values ( SQ_RESERVAS_ID.nextval,
                 :OLD.ID_RESERVA,
                 :OLD.IMPORTE,
                 :NEW.IMPORTE,
                 SYSDATE,
                 USER,
                 'UPDATE' );
   elsif DELETING then
      insert into TBL_LOG_RESERVAS (
         SQ_RESERVA_ID,
         ID_RESERVA,
         IMPORTE_ANTERIOR,
         IMPORTE_NUEVO,
         FECHA_CAMBIO,
         USUARIO,
         OPERACION
      ) values ( SQ_RESERVAS_ID.nextval,
                 :OLD.ID_RESERVA,
                 :OLD.IMPORTE,
                 null,
                 SYSDATE,
                 USER,
                 'DELETE' );
   end if;
exception
   when others then
      DBMS_OUTPUT.PUT_LINE('Error en bitácora: '
                           || SQLCODE
                           || ' - ' || SQLERRM);
end;
/

-- Probar UPDATE
update RESERVAS
   set
   IMPORTE = 900
 where ID_RESERVA = 'fgfP\bCAQD';
commit;



select *
  from TBL_LOG_RESERVAS;


/* Crear un bloque anónimo que se encargue de insertar un registro en la tabla vuelos, se 
debe verificar que la fecha del vuelo sea mayor cinco días a la fecha actual del servidor. 
En caso de no cumplirse con la condición antes mencionada, guardar una bitácora con los 
valores del registro que se intentó ingresa, si las condiciones se cumplen entonces se 
debe insertar el registro y adicionalmente guardar una bitácora con los valores insertados. 
Si la inserción genera cualquier error, se debe controlar y mostrar un mensaje 
personalizado. (valor 15%) */
create sequence SEQ_BITACORA_VUELOS start with 1 increment by 1 nocache nocycle;

create table BITACORA_VUELOS (
   ID_BITACORA         number primary key,
   TIPO_EVENTO         varchar2(30) not null,
   ID_VUELO            number(9,0),
   FECHA_VUELO         date,
   DETALLES            varchar2(300 byte),
   AER_ID_AERO         varchar2(3 byte),
   COMP_ID_COMP        varchar2(5 byte),
   TVUE_ID_VUELO       varchar2(3 byte),
   CAT_ID_CATERING     varchar2(2 byte),
   AER_ID_AERO_DESTINO varchar2(3 byte),
   FECHA_REGISTRO      date not null,
   OBSERVACION         varchar2(300 byte)
);

declare
    -- Datos del vuelo
   V_ID_VUELO            VUELOS.ID_VUELO%type := 1001;
   V_FECHA_VUELO         VUELOS.FECHA_VUELO%type := SYSDATE + 3;
   V_DETALLES            VUELOS.DETALLES%type := 'Vuelo especial de prueba';
   V_AER_ID_AERO         VUELOS.AER_ID_AERO%type := 'TGU';
   V_COMP_ID_COMP        VUELOS.COMP_ID_COMP%type := 'CM001';
   V_TVUE_ID_VUELO       VUELOS.TVUE_ID_VUELO%type := 'INT';
   V_CAT_ID_CATERING     VUELOS.CAT_ID_CATERING%type := 'A1';
   V_AER_ID_AERO_DESTINO VUELOS.AER_ID_AERO_DESTINO%type := 'SAP';
   C_DIAS_MINIMOS        constant number := 5;
begin

    -- Validar fecha
   if V_FECHA_VUELO > SYSDATE + C_DIAS_MINIMOS then

        -- Insertar vuelo
      insert into VUELOS (
         ID_VUELO,
         FECHA_VUELO,
         DETALLES,
         AER_ID_AERO,
         COMP_ID_COMP,
         TVUE_ID_VUELO,
         CAT_ID_CATERING,
         AER_ID_AERO_DESTINO
      ) values ( V_ID_VUELO,
                 V_FECHA_VUELO,
                 V_DETALLES,
                 V_AER_ID_AERO,
                 V_COMP_ID_COMP,
                 V_TVUE_ID_VUELO,
                 V_CAT_ID_CATERING,
                 V_AER_ID_AERO_DESTINO );

        -- Registrar bitácora de éxito
      insert into BITACORA_VUELOS (
         ID_BITACORA,
         TIPO_EVENTO,
         ID_VUELO,
         FECHA_VUELO,
         DETALLES,
         AER_ID_AERO,
         COMP_ID_COMP,
         TVUE_ID_VUELO,
         CAT_ID_CATERING,
         AER_ID_AERO_DESTINO,
         FECHA_REGISTRO,
         OBSERVACION
      ) values ( SEQ_BITACORA_VUELOS.nextval,
                 'INSERCION_EXITOSA',
                 V_ID_VUELO,
                 V_FECHA_VUELO,
                 V_DETALLES,
                 V_AER_ID_AERO,
                 V_COMP_ID_COMP,
                 V_TVUE_ID_VUELO,
                 V_CAT_ID_CATERING,
                 V_AER_ID_AERO_DESTINO,
                 SYSDATE,
                 'Vuelo insertado correctamente' );

      commit;
      DBMS_OUTPUT.PUT_LINE('Vuelo insertado y registrado en bitacora.');
   else
        -- Registrar intento fallido
      insert into BITACORA_VUELOS (
         ID_BITACORA,
         TIPO_EVENTO,
         ID_VUELO,
         FECHA_VUELO,
         DETALLES,
         AER_ID_AERO,
         COMP_ID_COMP,
         TVUE_ID_VUELO,
         CAT_ID_CATERING,
         AER_ID_AERO_DESTINO,
         FECHA_REGISTRO,
         OBSERVACION
      ) values ( SEQ_BITACORA_VUELOS.nextval,
                 'FECHA_INVALIDA',
                 V_ID_VUELO,
                 V_FECHA_VUELO,
                 V_DETALLES,
                 V_AER_ID_AERO,
                 V_COMP_ID_COMP,
                 V_TVUE_ID_VUELO,
                 V_CAT_ID_CATERING,
                 V_AER_ID_AERO_DESTINO,
                 SYSDATE,
                 'Fecha menor al minimo permitido de 5 dias' );

      commit;
      DBMS_OUTPUT.PUT_LINE('No se insertó el vuelo. La fecha no cumple la condicion.');
   end if;
exception
   when DUP_VAL_ON_INDEX then
      rollback;
      DBMS_OUTPUT.PUT_LINE('Error: ya existe un vuelo con ID ' || V_ID_VUELO);
   when others then
      rollback;
      DBMS_OUTPUT.PUT_LINE('Error al insertar el vuelo: ' || SQLERRM);
end;
-- Verificar resultados
select *
  from VUELOS
 order by ID_VUELO desc;
select *
  from BITACORA_VUELOS
 order by ID_BITACORA desc;


/*4) Mediante un bloque anónimo utilizar un BULK COLLECT para cargar en todas las
reservas, luego en el cuerpo del bloque anónimo se debe verificar si la reserva se ha
realizado por Internet y cuyo importe sea inferior a 175, los registros que cumplen la
condición se deben imprimir. Los datos para mostrar son todos los de la tabla reservas, el
nombre de la agencia y la fecha del vuelo. (valor 20%)*/
   set serveroutput on size unlimited;
EXEC DBMS_OUTPUT.ENABLE(NULL);
declare
   type T_TABLA_RESERVAS is
      table of RESERVAS%ROWTYPE;
   V_DATOS_RESERVAS T_TABLA_RESERVAS;
   V_NOMBRE_AGENCIA AGENCIAS.CN_AGENCIA%type;
   V_FECHA_VUELO    VUELOS.FECHA_VUELO%type;
   V_REGISTRO       number;
begin
   V_REGISTRO := 0;
   select *
   bulk collect
     into V_DATOS_RESERVAS
     from RESERVAS;

--- VERIFICANDO QUE LA RESERVA SE REALIZO POR INTERNET Y CUYO IMPORTE SEA MENOR A 175.

   for FILA in 1..sql%ROWCOUNT loop
      if (
         V_DATOS_RESERVAS(FILA).TRS_ID_TRESERVA = 'INT'
         and V_DATOS_RESERVAS(FILA).IMPORTE < 175
      ) then
         V_REGISTRO := V_REGISTRO + 1;
         select B.FECHA_VUELO,
                C.CN_AGENCIA
           into
            V_FECHA_VUELO,
            V_NOMBRE_AGENCIA
           from RESERVAS A
          inner join VUELOS B
         on B.ID_VUELO = A.VUE_ID_VUELO
          inner join AGENCIAS C
         on C.ID_AGENCIA = A.AGE_ID_AGENCIA
          where A.ID_RESERVA = V_DATOS_RESERVAS(FILA).ID_RESERVA;

         DBMS_OUTPUT.PUT_LINE('REGISTRO #' || V_REGISTRO);
         DBMS_OUTPUT.PUT_LINE('ID RESERVA      : ' || V_DATOS_RESERVAS(FILA).ID_RESERVA);
         DBMS_OUTPUT.PUT_LINE('IMPORTE         : ' || V_DATOS_RESERVAS(FILA).IMPORTE);
         DBMS_OUTPUT.PUT_LINE('CLI NIF         : ' || V_DATOS_RESERVAS(FILA).CLI_NIF);
         DBMS_OUTPUT.PUT_LINE('TRS ID TRESERVA : ' || V_DATOS_RESERVAS(FILA).TRS_ID_TRESERVA);
         DBMS_OUTPUT.PUT_LINE('AGE ID AGENCIA  : ' || V_DATOS_RESERVAS(FILA).AGE_ID_AGENCIA);
         DBMS_OUTPUT.PUT_LINE('PLA ID PLAZA    : ' || V_DATOS_RESERVAS(FILA).PLA_ID_PLAZA);
         DBMS_OUTPUT.PUT_LINE('VUELO ID        : ' || V_DATOS_RESERVAS(FILA).VUE_ID_VUELO);
         DBMS_OUTPUT.PUT_LINE('FECHA VUELO     : ' || V_FECHA_VUELO);
         DBMS_OUTPUT.PUT_LINE('NOMBRE AGENCIA  : ' || V_NOMBRE_AGENCIA);
         DBMS_OUTPUT.PUT_LINE(CHR(13));
      end if;
   end loop;

end;

/*5) Crear un nuevo esquema que se puede llamar C##_MIG_VUELOS, usted debe
-- considerar los permisos que se deben agregar al esquema. Luego, usando bulk collect,
-- migrar todos los registros de la tabla reservas al nuevo esquema, se debe migrar todos
-- los campos, más no las tablas a las cuales han referencia las llaves foráneas.
-- Posteriormente, realizar la misma migración utilizando un cursor explícito. Al finalizar las
-- migraciones, comparar los tiempos de ejecución y plantear soluciones para mejorar el
-- tiempo de ejecución. La solución se debe programar mediante PL/SQL*/



-- creación del usuario y sus respectivos permisos.

--CONEXION SYSTEM
create user C##_MIG_VUELOS identified by 1234;

grant create session,
   create any table,
   drop any table,
   alter any table,
   insert any table
to C##_MIG_VUELOS;

alter user C##_MIG_VUELOS
   quota unlimited on USERS;

-- CONEXION C##_VUELOS

grant select on C##_VUELOS.RESERVAS to C##_MIG_VUELOS;


--CONEXION C##_MIG_VUELOS

   
-- Tabla de mig vuelos de reservas. 
create table RESERVAS (
   ID_RESERVA      varchar2(10 byte) not null,
   IMPORTE         number not null,
   CLI_NIF         varchar2(10 byte),
   TRS_ID_TRESERVA varchar2(3 byte),
   AGE_ID_AGENCIA  number,
   PLA_ID_PLAZA    number(10,0),
   VUE_ID_VUELO    number(9,0) not null
);

/
   set serveroutput on;
   -- borrar datos para tests
delete from RESERVAS;
-- tests
select count(*)
  from RESERVAS;

/
-- MIGRACION CON EL BULK COLLECT
declare
   type T_DATOS_RESERVAS is
      table of RESERVAS%ROWTYPE;
   V_DATOS_RESERVAS T_DATOS_RESERVAS;
begin
   select *
   bulk collect
     into V_DATOS_RESERVAS
     from C##_VUELOS.RESERVAS;

   for FILA in 1..sql%ROWCOUNT loop
      insert into C##_MIG_VUELOS.RESERVAS values ( V_DATOS_RESERVAS(FILA).ID_RESERVA,
                                                   V_DATOS_RESERVAS(FILA).IMPORTE,
                                                   V_DATOS_RESERVAS(FILA).CLI_NIF,
                                                   V_DATOS_RESERVAS(FILA).TRS_ID_TRESERVA,
                                                   V_DATOS_RESERVAS(FILA).AGE_ID_AGENCIA,
                                                   V_DATOS_RESERVAS(FILA).PLA_ID_PLAZA,
                                                   V_DATOS_RESERVAS(FILA).VUE_ID_VUELO );

   end loop;
   commit;
exception
   when DUP_VAL_ON_INDEX then
      rollback;
      DBMS_OUTPUT.PUT_LINE('Codigo duplicado. ');
      DBMS_OUTPUT.PUT_LINE(SQLCODE);
      DBMS_OUTPUT.PUT_LINE(SQLERRM);
   when others then
      rollback;
      DBMS_OUTPUT.PUT_LINE('Error inesperado. ');
      DBMS_OUTPUT.PUT_LINE(SQLCODE);
      DBMS_OUTPUT.PUT_LINE(SQLERRM);
end;

-- BORRAR PARA TESTS

/
delete from RESERVAS;
/

-- MICRACION CON EL CURSOR 
declare
   cursor C_REGISTRO_RESERVAS is
   select *
     from C##_VUELOS.RESERVAS;

   V_DATO_RESERVA C_REGISTRO_RESERVAS%ROWTYPE;
begin
   open C_REGISTRO_RESERVAS;
   loop
      fetch C_REGISTRO_RESERVAS into V_DATO_RESERVA;
      exit when C_REGISTRO_RESERVAS%NOTFOUND;
      insert into C##_MIG_VUELOS.RESERVAS values ( V_DATO_RESERVA.ID_RESERVA,
                                                   V_DATO_RESERVA.IMPORTE,
                                                   V_DATO_RESERVA.CLI_NIF,
                                                   V_DATO_RESERVA.TRS_ID_TRESERVA,
                                                   V_DATO_RESERVA.AGE_ID_AGENCIA,
                                                   V_DATO_RESERVA.PLA_ID_PLAZA,
                                                   V_DATO_RESERVA.VUE_ID_VUELO );
   end loop;


   close C_REGISTRO_RESERVAS;
   commit;
exception
   when DUP_VAL_ON_INDEX then
      rollback;
      DBMS_OUTPUT.PUT_LINE('Codigo duplicado. ');
      DBMS_OUTPUT.PUT_LINE(SQLCODE);
      DBMS_OUTPUT.PUT_LINE(SQLERRM);
   when others then
      rollback;
      DBMS_OUTPUT.PUT_LINE('Error inesperado. ');
      DBMS_OUTPUT.PUT_LINE(SQLCODE);
      DBMS_OUTPUT.PUT_LINE(SQLERRM);
end;
/
delete from RESERVAS;
/
-- TIEMPO QUE TARDA CADA MÉTODO (5 PRUEBAS PARA CADA UNO)

-- MÉTODO BULK COLLECT
-- PRUEBA 1: 5.859 seg
-- PRUEBA 2: 5.823 seg
-- PRUEBA 3: 8.096 seg
-- PRUEBA 4: 6.166 seg
-- PRUEBA 5: 10.557 seg
-- PROMEDIO: 7.3002 seg

-- MÉTODO CURSOR
-- PRUEBA 1: 9.259 seg
-- PRUEBA 2: 5.627 seg
-- PRUEBA 3: 10.191 seg
-- PRUEBA 4: 6.744 seg
-- PRUEBA 5: 9.37 seg
-- PROMEDIO:  8.2382 seg

--Al observar los resultados, nos damos cuenta que son bastantes similares, con una ligera ventaja para el método de bulk collect. 


-- SOLUCIONES PLANTEADAS
declare
   type T_DATOS_RESERVAS is
      table of RESERVAS%ROWTYPE;
   V_DATOS_RESERVAS T_DATOS_RESERVAS;
begin
   select *
   bulk collect
     into V_DATOS_RESERVAS
     from C##_VUELOS.RESERVAS;

   forall FILA in 1..V_DATOS_RESERVAS.COUNT
      insert into C##_MIG_VUELOS.RESERVAS values V_DATOS_RESERVAS ( FILA );
   commit;
end;
/
delete from RESERVAS;
/
-- PRUEBAS CON LA SOLUCIÓN
-- PRUEBA 1: 1.589 seg
-- PRUEBA 2: 0.955 seg
-- PRUEBA 3: 1.114 seg
-- PRUEBA 4: 1.085 seg
-- PRUEBA 5: 1.15 seg
-- PROMEDIO: 1,1746 seg

-- EL PROBLEMA CON LAS PRIMERAS VERSIONES ES QUE SE ESTABA HACIENDO INSERT DE LOS DATOS UNO POR UNO.
-- ENTONCES, AL USAR UN FORALL BASICAMENTE LE ESTAMOS DICIENDO AL GESTOR, MIRA TENGO 117113 REGISTROS, INSERTARLOS TODOS DE UN SOLO AQUI.
-- A DIFERENCIA DE HACER TODAS ESAS 171K ITERACIONES.


-- OTRA SOLUCION EFICIENTE (BULK COLLECT CON LIMIT)
--ESTO PARA PODER LIBERAR MEMORIA Y QUE SI HAY ALGUN ERROR EN ALGUN REGISTRO PUES NO PERDER TODA LA MIGRACIÓN.

declare
   cursor C_REGISTRO_RESERVAS is
   select *
     from C##_VUELOS.RESERVAS;
   type T_REGISTRO_RESERVAS is
      table of C_REGISTRO_RESERVAS%ROWTYPE;
   V_DATOS_RESERVAS T_REGISTRO_RESERVAS;
begin
   open C_REGISTRO_RESERVAS;
   loop
      fetch C_REGISTRO_RESERVAS
      bulk collect into V_DATOS_RESERVAS limit 10000;
      exit when V_DATOS_RESERVAS.COUNT = 0;
      forall FILA in 1..V_DATOS_RESERVAS.COUNT
         insert into RESERVAS values V_DATOS_RESERVAS ( FILA );

      V_DATOS_RESERVAS.delete;
   end loop;
   close C_REGISTRO_RESERVAS;
   commit;
exception
   when DUP_VAL_ON_INDEX then
      rollback;
      DBMS_OUTPUT.PUT_LINE('Codigo duplicado. ');
      DBMS_OUTPUT.PUT_LINE(SQLCODE);
      DBMS_OUTPUT.PUT_LINE(SQLERRM);
   when others then
      rollback;
      DBMS_OUTPUT.PUT_LINE('Error inesperado. ');
      DBMS_OUTPUT.PUT_LINE(SQLCODE);
      DBMS_OUTPUT.PUT_LINE(SQLERRM);
end;




-- PRUEBAS 
-- PRUEBA 1: 0.841 seg
-- PRUEBA 2: 1.562 seg
-- PRUEBA 3: 0.471 seg
-- PRUEBA 4: 0.703 seg
-- PRUEBA 5: 0.559 seg
-- PROMEDIO: 0,8272 seg

-- ESTA SOLUCION DE USAR BLOQUES E IR LIBERANDO LA MEMORIA A MEDIDA GUARDAMOS LOS DATOS, ES LA QUE HA OBTENIDO EL PROMEDIO DE TIEMPO MAS RÁPIDO.
-- AL FINAL, LAS OPCIONES QUEDAN ASI:

-- BULK COLLECT POR BLOQUES DE 10,000 REGISTROS USANDO FORALL: 0.8272 seg
-- BULK COLLECT SIN BLOQUES USANDO FORALL:                     1.1786 seg
-- BULK COLLECT USANDO FOR TRADICIONAL:                        7.3002 seg
-- CURSOR USANDO FOR TRADICIONAL:                              8.2382 seg