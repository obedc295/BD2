grant create session,
   create any table,
   drop any table,
   alter any table,
   create any sequence,
   drop any sequence,
   create any trigger,
   drop any trigger,
   alter any trigger
to C##_PEDIDOS

-- PARA CREAR UN ROLE SE USAR CREATE ROLE

create role C##_PROGRAMADOR_JUNIOR;

grant create session,
   create any table,
   drop any table,
   alter any table,
   create any sequence,
   drop any sequence,
   create any trigger,
   drop any trigger,
   alter any trigger
to C##_PROGRAMADOR_JUNIOR;


-- PARA ASIGNAR ROLES

grant C##_PROGRAMADOR_JUNIOR to C##_PEDIDOS;

-- select into

declare
   NOMBRE_PROV varchar;
   CELULAR     varchar2;
   TEL_FIGO    varchar2;
   CONTACTO    number;
begin
   select NOMBREPROV,
          CONTACTO,
          CELUPROV,
          INTO NOMBRE_PROV,
          CONTACTO,
          CELULAR
     from PROVEEDORES
    where PROVEEDORID = 40;

-- CHAR COMPLETA LOS ESPACIOS FALTANTES CON ESPACIOS VACIOS , APLICAR TRIM.

   DBMS_OUTPUT.PUTLINE('EL NOMBRE DEL PROVEEDOR ES ' || NOMRE_PROV);
end;



-- CURSORES


-- PROPIEDADES DE LOS CURSORES 

-- ISOPEN 
-- NOT FOUND

declare 
    -- 1. Se quitó el espacio en el nombre del cursor
    -- 2. Se especifican las columnas exactas de la tabla "a" para que coincidan con el FETCH
   cursor C_DATOS_EMP is
   select A.EMPLEADOID,
          A.NOMBRE,
          A.APELLIDO,
          A.FECHA_NAC,
          A.REPORTA_A,
          A.EXTENSION,
          A.SALARIO,
          B.NOMBRE,
          B.APELLIDO
     from EMPLEADOS A
     left join EMPLEADOS B
   on A.REPORTA_A = B.EMPLEADOID
    where A.REPORTA_A is null;

    -- 3. Corregido el error de dedo "EMPELADOS" por "EMPLEADOS"
    -- 4. Se cambiaron los tipos para que coincidan con las columnas reales (ej. NOMBRE %TYPE)
   COD_EMP       EMPLEADOS.EMPLEADOID%type;
   NOMBRE        EMPLEADOS.NOMBRE%type;
   APELLIDO      EMPLEADOS.APELLIDO%type;
   FECHA         EMPLEADOS.FECHA_NAC%type;
   JEFE          EMPLEADOS.REPORTA_A%type;
   EXTENSION     EMPLEADOS.EXTENSION%type;
   NOMBRE_JEFE   EMPLEADOS.NOMBRE%type;
   APELLIDO_JEFE EMPLEADOS.APELLIDO%type;
   SALARIO       EMPLEADOS.SALARIO%type;
begin 
    -- Corregido el nombre del cursor para que coincida con la declaración
   open C_DATOS_EMP;
   loop
      fetch C_DATOS_EMP into
         COD_EMP,
         NOMBRE,
         APELLIDO,
         FECHA,
         JEFE,
         EXTENSION,
         SALARIO,
         NOMBRE_JEFE,
         APELLIDO_JEFE;
      exit when C_DATOS_EMP%NOTFOUND;

        -- 5. Corregido "COD_EM" por "COD_EMP" y los textos de los mensajes
      DBMS_OUTPUT.PUT_LINE('EL CODIGO DEL EMPLEADO ES: ' || COD_EMP);
      DBMS_OUTPUT.PUT_LINE('EL NOMBRE DEL EMPLEADO ES: ' || NOMBRE);
      DBMS_OUTPUT.PUT_LINE('EL APELLIDO DEL EMPLEADO ES: ' || APELLIDO);
      DBMS_OUTPUT.PUT_LINE('LA FECHA DEL EMPLEADO ES: ' || FECHA);
      DBMS_OUTPUT.PUT_LINE('EL SALARIO DEL EMPLEADO ES: ' || SALARIO);
      if (
         ( NOMBRE_JEFE is not null )
         and ( APELLIDO_JEFE is not null )
      ) then
         DBMS_OUTPUT.PUT_LINE('EL NOMBRE DEL JEFE ES: '
                              || TRIM(NOMBRE_JEFE)
                              || ' '
                              || 'EL APELLIDO DEL JEFE ES: ' || TRIM(APELLIDO_JEFE));
      else
         DBMS_OUTPUT.PUT_LINE('NO EXISTE EL JEFE. ');
      end if;
--- CON IF ELSE
      if (
         ( SALARIO >= 15000 )
         and ( SALARIO < 20000 )
      ) then
         DBMS_OUTPUT.PUT_LINE('SALARIO BAJO');
      elsif (
         ( SALARIO >= 20000 )
         and ( SALARIO < 25000 )
      ) then
         DBMS_OUTPUT.PUT_LINE('SALARIO MEDIO');
      elsif (
         SALARIO >= 25000
         and SALARIO <= 30000
      ) then
         DBMS_OUTPUT.PUT_LINE('SALARIO ALTO');
      else
         DBMS_OUTPUT.PUT_LINE('SALARIO FUERA DE PLANILLA');
      end if;

-- CON CASE

   end loop;

   close C_DATOS_EMP;
end;

   set serveroutput on;
/


declare 
    -- 1. Se quitó el espacio en el nombre del cursor
    -- 2. Se especifican las columnas exactas de la tabla "a" para que coincidan con el FETCH
   cursor C_DATOS_EMP is
   select A.EMPLEADOID,
          A.NOMBRE,
          A.APELLIDO,
          A.FECHA_NAC,
          A.REPORTA_A,
          A.EXTENSION,
          A.SALARIO,
          B.NOMBRE,
          B.APELLIDO
     from EMPLEADOS A
     left join EMPLEADOS B
   on A.REPORTA_A = B.EMPLEADOID
    where A.REPORTA_A is null;

    -- 3. Corregido el error de dedo "EMPELADOS" por "EMPLEADOS"
    -- 4. Se cambiaron los tipos para que coincidan con las columnas reales (ej. NOMBRE %TYPE)
   COD_EMP            EMPLEADOS.EMPLEADOID%type;
   NOMBRE             EMPLEADOS.NOMBRE%type;
   APELLIDO           EMPLEADOS.APELLIDO%type;
   FECHA              EMPLEADOS.FECHA_NAC%type;
   JEFE               EMPLEADOS.REPORTA_A%type;
   EXTENSION          EMPLEADOS.EXTENSION%type;
   NOMBRE_JEFE        EMPLEADOS.NOMBRE%type;
   APELLIDO_JEFE      EMPLEADOS.APELLIDO%type;
   SALARIO            EMPLEADOS.SALARIO%type;
   CANTIDAD_REGISTROS number;
begin 
    -- Corregido el nombre del cursor para que coincida con la declaración
   open C_DATOS_EMP;
   select count(*)
     into CANTIDAD_REGISTROS
     from EMPLEADOS;
   for FILA in 1..CANTIDAD_REGISTROS loop
      fetch C_DATOS_EMP into
         COD_EMP,
         NOMBRE,
         APELLIDO,
         FECHA,
         JEFE,
         EXTENSION,
         SALARIO,
         NOMBRE_JEFE,
         APELLIDO_JEFE;
      exit when C_DATOS_EMP%NOTFOUND;

        -- 5. Corregido "COD_EM" por "COD_EMP" y los textos de los mensajes
      DBMS_OUTPUT.PUT_LINE('EL CODIGO DEL EMPLEADO ES: ' || COD_EMP);
      DBMS_OUTPUT.PUT_LINE('EL NOMBRE DEL EMPLEADO ES: ' || NOMBRE);
      DBMS_OUTPUT.PUT_LINE('EL APELLIDO DEL EMPLEADO ES: ' || APELLIDO);
      DBMS_OUTPUT.PUT_LINE('LA FECHA DEL EMPLEADO ES: ' || FECHA);
      DBMS_OUTPUT.PUT_LINE('EL SALARIO DEL EMPLEADO ES: ' || SALARIO);
      if (
         ( NOMBRE_JEFE is not null )
         and ( APELLIDO_JEFE is not null )
      ) then
         DBMS_OUTPUT.PUT_LINE('EL NOMBRE DEL JEFE ES: '
                              || TRIM(NOMBRE_JEFE)
                              || ' '
                              || 'EL APELLIDO DEL JEFE ES: ' || TRIM(APELLIDO_JEFE));
      else
         DBMS_OUTPUT.PUT_LINE('NO EXISTE EL JEFE. ');
      end if;
--- CON IF ELSE
      if (
         ( SALARIO >= 15000 )
         and ( SALARIO < 20000 )
      ) then
         DBMS_OUTPUT.PUT_LINE('SALARIO BAJO');
      elsif (
         ( SALARIO >= 20000 )
         and ( SALARIO < 25000 )
      ) then
         DBMS_OUTPUT.PUT_LINE('SALARIO MEDIO');
      elsif (
         SALARIO >= 25000
         and SALARIO <= 30000
      ) then
         DBMS_OUTPUT.PUT_LINE('SALARIO ALTO');
      else
         DBMS_OUTPUT.PUT_LINE('SALARIO FUERA DE PLANILLA');
      end if;

-- CON CASE

      case
         when ( (
            SALARIO >= 15000
            and ( SALARIO < 20000 )
         ) ) then
            DBMS_OUTPUT.PUT_LINE('SALARIO BAJO');
         when (
            ( SALARIO >= 20000 )
            and ( SALARIO < 25000 )
         ) then
            DBMS_OUTPUT.PUT_LINE('SALARIO MEDIO');
         when (
            ( SALARIO >= 25000 )
            and ( SALARIO <= 30000 )
         ) then
            DBMS_OUTPUT.PUT_LINE('SALARIO ALTO');
      end case;





   end loop;

   close C_DATOS_EMP;
end;
/