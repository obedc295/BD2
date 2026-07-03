-- 5) Crear un nuevo esquema que se puede llamar C##_MIG_VUELOS, usted debe
-- considerar los permisos que se deben agregar al esquema. Luego, usando bulk collect,
-- migrar todos los registros de la tabla reservas al nuevo esquema, se debe migrar todos
-- los campos, más no las tablas a las cuales han referencia las llaves foráneas.
-- Posteriormente, realizar la misma migración utilizando un cursor explícito. Al finalizar las
-- migraciones, comparar los tiempos de ejecución y plantear soluciones para mejorar el
-- tiempo de ejecución. La solución se debe programar mediante PL/SQL



-- creacion del usuario y sus respectivos permisos.

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
delete from reservas;

select count(*) from reservas;


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

-- BORRAR PARA TEST 
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


-- solucion 
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


-- OTRA SOLUCIONES EFICIENTE (BULK COLLECT CON LIMIT)
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

-- ESTA SOLUCION DE USAR BLOQUES E IR LIBERANDO LA MEMORIA A  MEDIDAS GUARDAMOS LOS DATOS ES LA QUE HA OBTENIDO EL PROMEDIO DE TIEMPO MAS RÁPIDO.
-- AL FINAL LAS OPCIONES QUEDARIAN ASI:

-- BULK COLLECT POR BLOQUES DE 10,000 REGISTROS USANDO FORALL: 0.8272 seg
-- BULK COLLECT SIN BLOQUES USANDO FORALL: 1.1786 seg
-- BULK COLLECT USANDO FOR TRADICIONAL: 7.3002 seg
-- CURSOR USANDO FOR TRADICIONAL: 8.2382 seg