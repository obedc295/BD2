select *
  from RESERVAS;

select *
  from AGENCIAS;




select *
  from VUELOS;
-- 4) Mediante un bloque anónimo utilizar un BULK COLLECT para cargar en todas las
-- reservas, luego en el cuerpo del bloque anónimo se debe verificar si la reserva se ha
-- realizado por Internet y cuyo importe sea inferior a 175, los registros que cumplen la
-- condición se deben imprimir. Los datos para mostrar son todos los de la tabla reservas, el
-- nombre de la agencia y la fecha del vuelo. (valor 20%)


-- EN TRS_ID_TRESERVA CAMPO DATOS INT PARA INTERNET

/

--- PRIMERO COMO DICE TAL CUAL EL EJERCICIO, GUARDA TODOS LOS DATOS DE LAS RESERVAS CON EL BULK COLLECT Y LUEGO DENTRO DEL FOR SE APLICAN LAS CONDICIONES 
--- ES MÁS LENTO PORQUE HACE UN SELECT PARA CADA REGISTRO

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

--- VERIFACANDO QUE LA RESERVA SE REALIZO POR INTERNET Y CUYO IMPORTE SEA MENOR A 175.

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
         DBMS_OUTPUT.PUT_LINE(V_DATOS_RESERVAS(FILA).ID_RESERVA);
         DBMS_OUTPUT.PUT_LINE(V_DATOS_RESERVAS(FILA).IMPORTE);
         DBMS_OUTPUT.PUT_LINE(V_DATOS_RESERVAS(FILA).CLI_NIF);
         DBMS_OUTPUT.PUT_LINE(V_DATOS_RESERVAS(FILA).TRS_ID_TRESERVA);
         DBMS_OUTPUT.PUT_LINE(V_DATOS_RESERVAS(FILA).AGE_ID_AGENCIA);
         DBMS_OUTPUT.PUT_LINE(V_DATOS_RESERVAS(FILA).PLA_ID_PLAZA);
         DBMS_OUTPUT.PUT_LINE(V_DATOS_RESERVAS(FILA).VUE_ID_VUELO);
         DBMS_OUTPUT.PUT_LINE(V_FECHA_VUELO);
         DBMS_OUTPUT.PUT_LINE(V_NOMBRE_AGENCIA);
         DBMS_OUTPUT.PUT_LINE(CHR(13));
      end if;
   end loop;

end;


----------- VERSION OPTIMIZADA
-- SE GUARDA DE UN SOLO EN EL BULK COLLECT LOS REGISTROS QUE CUMPLEN LAS CONDICIONES Y LUEGO SOLO SE IMPRIMEN EN EL FOR. 

declare
   type T_FILA is record (
         ID_RESERVA      RESERVAS.ID_RESERVA%type,
         IMPORTE         RESERVAS.IMPORTE%type,
         CLI_NIF         RESERVAS.CLI_NIF%type,
         TRS_ID_TRESERVA RESERVAS.TRS_ID_TRESERVA%type,
         AGE_ID_AGENCIA  RESERVAS.AGE_ID_AGENCIA%type,
         PLA_ID_PLAZA    RESERVAS.PLA_ID_PLAZA%type,
         VUE_ID_VUELO    RESERVAS.VUE_ID_VUELO%type,
         FECHA_VUELO     VUELOS.FECHA_VUELO%type,
         CN_AGENCIA      AGENCIAS.CN_AGENCIA%type
   );
   type T_TABLA_RESERVAS is
      table of T_FILA;
   V_DATOS_RESERVAS T_TABLA_RESERVAS;
begin
   select A.*,
          B.FECHA_VUELO,
          C.CN_AGENCIA
   bulk collect
     into V_DATOS_RESERVAS
     from RESERVAS A
    inner join VUELOS B
   on B.ID_VUELO = A.VUE_ID_VUELO
    inner join AGENCIAS C
   on C.ID_AGENCIA = A.AGE_ID_AGENCIA
    where A.TRS_ID_TRESERVA = 'INT'
      and A.IMPORTE < 175;

--- VERIFACANDO QUE LA RESERVA SE REALIZO POR INTERNET Y CUYO IMPORTE SEA MENOR A 175.

   for FILA in 1..sql%ROWCOUNT loop
      DBMS_OUTPUT.PUT_LINE('REGISTRO #' || FILA);
      DBMS_OUTPUT.PUT_LINE(V_DATOS_RESERVAS(FILA).ID_RESERVA);
      DBMS_OUTPUT.PUT_LINE(V_DATOS_RESERVAS(FILA).IMPORTE);
      DBMS_OUTPUT.PUT_LINE(V_DATOS_RESERVAS(FILA).CLI_NIF);
      DBMS_OUTPUT.PUT_LINE(V_DATOS_RESERVAS(FILA).TRS_ID_TRESERVA);
      DBMS_OUTPUT.PUT_LINE(V_DATOS_RESERVAS(FILA).AGE_ID_AGENCIA);
      DBMS_OUTPUT.PUT_LINE(V_DATOS_RESERVAS(FILA).PLA_ID_PLAZA);
      DBMS_OUTPUT.PUT_LINE(V_DATOS_RESERVAS(FILA).VUE_ID_VUELO);
      DBMS_OUTPUT.PUT_LINE(V_DATOS_RESERVAS(FILA).FECHA_VUELO);
      DBMS_OUTPUT.PUT_LINE(V_DATOS_RESERVAS(FILA).CN_AGENCIA);
      DBMS_OUTPUT.PUT_LINE(CHR(13));
   end loop;

end;



EXEC DBMS_OUTPUT.ENABLE(NULL);
set serveroutput on size unlimited;


-- 5) Crear un nuevo esquema que se puede llamar C##_MIG_VUELOS, usted debe
-- considerar los permisos que se deben agregar al esquema. Luego, usando bulk collect,
-- migrar todos los registros de la tabla reservas al nuevo esquema, se debe migrar todos
-- los campos, más no las tablas a las cuales han referencia las llaves foráneas.
-- Posteriormente, realizar la misma migración utilizando un cursor explícito. Al finalizar las
-- migraciones, comparar los tiempos de ejecución y plantear soluciones para mejorar el
-- tiempo de ejecución. La solución se debe programar mediante PL/SQL



-- creacion del usuario y sus respectivos permisos.
create user C##_MIG_VUELOS identified by 1234;

grant create session,
   create any table,
   drop any table,
   alter any table
to C##_MIG_VUELOS;
grant
   create any sequence,
   drop any sequence
to C##_MIG_VUELOS;
grant create any trigger,
   drop any trigger,
   alter any trigger
to C##_MIG_VUELOS;
grant insert any table to C##_MIG_VUELOS;


grant select,insert on C##_VUELOS.RESERVAS to C##_MIG_VUELOS;



-- tabla de mig vuelos de reservas. 
create table RESERVAS (
   ID_RESERVA      varchar2(10 byte) not null,
   IMPORTE         number not null,
   CLI_NIF         varchar2(10 byte),
   TRS_ID_TRESERVA varchar2(3 byte),
   AGE_ID_AGENCIA  number,
   PLA_ID_PLAZA    number(10,0),
   VUE_ID_VUELO    number(9,0) not null
);


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
end;

delete from C##_MIG_VUELOS.RESERVAS;


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
end;


delete from C##_MIG_VUELOS.RESERVAS;


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

--En conclusión, al observar los resultados nos damos cuenta que son bastantes similares, con una ligera ventaja para el método de bulk collect. 
-- Los resultados depeden completamente de los recursos de la computadora, pero por eso fueron probados en la misma.


-- solucion 
declare
   type T_DATOS_RESERVAS is table of RESERVAS%ROWTYPE;
   V_DATOS_RESERVAS T_DATOS_RESERVAS;
begin
   select * bulk collect into V_DATOS_RESERVAS 
   from C##_VUELOS.RESERVAS;

   forall i in 1..V_DATOS_RESERVAS.count
      insert into C##_MIG_VUELOS.RESERVAS values V_DATOS_RESERVAS(i);
end;

-- PRUEBAS CON LA SOLUCIÓN
-- PRUEBA 1: 1.589 seg
-- PRUEBA 2: 0.955 seg
-- PRUEBA 3: 1.114 seg
-- PRUEBA 4: 1.085 seg
-- PRUEBA 5: 1.15 seg
-- PROMEDIO: 1,1746 seg

-- EL PROBLEMA CON LAS SOLUCIONES ANTERIORES ES QUE SE ESTABA HACIENDO INSERT DE LOS DATOS UNO POR UNO.
-- ENTONCES, AL USAR UN FORALL BASICAMENTE LE ESTOY DICIENDO AL GESTOR, MIRA TENGO 117113 REGISTROS, INSERTARLOS TODOS DE UN SOLO AQUI.
-- A DIFERENCIA DE HACER TODAS ESAS 171K ITERACIONES.


-- OTRA SOLUCIONES EFICIENTE (BULK COLLECT CON LIMIT)
--ESTO PARA PODER LIBERAR MEMORIA Y QUE SI HAY ALGUN ERROR EN ALGUN REGISTRO PUES NO PERDER TODA LA MIGRACIÓN , ESAS SERIAN UNAS DE LAS 
-- VENTAJAS DE HACER ASI.

DECLARE 
CURSOR C_REGISTRO_rESERVAS IS SELECT * FROM C##_VUELOS.RESERVAS;
TYPE T_REGISTRO_RESERVAS IS TABLE OF C_REGISTRO_RESERVAS%ROWTYPE;
V_DATOS_RESERVAS T_REGISTRO_RESERVAS;
BEGIN 
OPEN C_REGISTRO_RESERVAS;
LOOP 
FETCH C_REGISTRO_RESERVAS BULK COLLECT INTO V_DATOS_RESERVAS LIMIT 10000;
EXIT WHEN v_datos_reservas.count = 0;

FORALL FILA IN 1..V_DATOS_RESERVAS.COUNT
insert into c##_mig_vuelos.reservas values v_datos_reservas(fila);

v_datos_reservas.delete;
END LOOP;
CLOSE C_REGISTRO_RESERVAS;
END;


-- PRUEBAS 
-- PRUEBA 1: 0.841 seg
-- PRUEBA 2: 1.562 seg
-- PRUEBA 3: 0.471 seg
-- PRUEBA 4: 0.703 seg
-- PRUEBA 5: 0.559 seg
-- PROMEDIO: 0,8272 seg

-- ESTA SOLUCION DE USAR BLOQUES E IR LIBERANDO LA MEMORIA A  MEDIDAS GUARDAMOS LOS DATOS ES LA QUE HA OBTENIDO EL PROMEDIO DE TIEMPO MAS RÁPIDO.
-- AL FINAL LAS OPCIONES QUEDARIAN ASI:

-- BULK COLLECT POR BLOQUES DE 10,000 REGISTROS USANDO FORALL: 0.8272 seg
-- BULK COLLECT SIN BLOQUES USANDO FORALL: 1.1786 seg
-- BULK COLLECT USANDO FOR TRADICIONAL: 7.3002 seg
-- CURSOR USANDO FOR TRADICIONAL: 8.2382 seg




select count(*)
  from C##_VUELOS.RESERVAS;


select count(*)
  from C##_MIG_VUELOS.RESERVAS;

delete from C##_MIG_VUELOS.RESERVAS;