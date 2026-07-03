-- -- 

-- Utilizando la base de datos bd_caso_ventas (mostrada en el diagrama anterior), desarrolle los siguientes elementos:
-- 1.	Un usuario llamado userXX (donde XX es su número de cuenta) y usando el usuario anterior cree las tablas de la base de datos caso ventas.
-- no lei y lo cree con el usuario c##_caso_ventas 
create user C##_USER20241002161 identified by 1234;

grant create session,
   create any table,
   alter any table,
   drop any table,
   create any trigger,
   create any sequence
to C##_USER20241002161;

alter user C##_USER20241002161
   quota unlimited on USERS;
-- 2 NO HAY EJERCICIO
-- 3.	Un cursor que nos permita listar todas las ventas cuyo total de la venta esté en el rango de 200 y 25000, además que la condición de la venta sea al crédito.
select *
  from TBL_VENTA;
declare
   cursor C_REGISTRO_VENTAS is
   select *
     from TBL_VENTA
    where TOTAL between 200 and 25000
      and CONDICION = 'CREDITO';
begin
   for REG in C_REGISTRO_VENTAS loop
      DBMS_OUTPUT.PUT_LINE(REG.NRO_VENTA);
      DBMS_OUTPUT.PUT_LINE(REG.FECHA_HORA);
      DBMS_OUTPUT.PUT_LINE(REG.DNI_VENDEDOR);
      DBMS_OUTPUT.PUT_LINE(REG.NRO_CLIENTE);
      DBMS_OUTPUT.PUT_LINE(REG.TOTAL);
      DBMS_OUTPUT.PUT_LINE(REG.CONDICION);
      DBMS_OUTPUT.PUT_LINE(CHR(13));
   end loop;
end;


-- 4.	Un cursor que permita listar el DNI_VENDEDOR, NOMBRE DEL VENDEDOR y el TOTAL DE VENTAS que ha realizado cada uno de los vendedores.

select *
  from TBL_VENDEDOR;
select *
  from TBL_VENTA;


declare
   cursor C_REGISTRO_VENTAS is
   select A.DNI_VENDEDOR,
          A.V_NOMBRES,
          NVL(
             COUNT(B.DNI_VENDEDOR),
             0
          ) as TOTAL_VENTAS
     from TBL_VENDEDOR A
     left join TBL_VENTA B
   on A.DNI_VENDEDOR = B.DNI_VENDEDOR
    group by A.DNI_VENDEDOR,
             A.V_NOMBRES;
begin
   for REG in C_REGISTRO_VENTAS loop
      DBMS_OUTPUT.PUT_LINE(REG.DNI_VENDEDOR);
      DBMS_OUTPUT.PUT_LINE(REG.V_NOMBRES);
      DBMS_OUTPUT.PUT_LINE(REG.TOTAL_VENTAS);
      DBMS_OUTPUT.PUT_LINE(CHR(13));
   end loop;
end;

-- Ahora debe crear los siguientes objetos:
-- 1. Una tabla llamada TBL_CONTROLES con las columnas NRO_CONTROL de tipo
-- NUMBER, NOMBRE_USUARIO de tipo VARCHAR2(100), DESCRIPCION de tipo
-- VARCHAR2(500) y FECHA_HORA de tipo TIMESTAMP. EI NRO_CONTROL se
-- debe autogenerar de 1 en 1 para la columna NRO_CONTROL, el campo
-- descripción guardarà una observación de la operación realizada y la columna
-- FECHA_HORA almacenará por defecto la fecha y hora del sistema. Para asignar
-- un valor por defecto a un campo se debe realizar de forma similar al ejemplo:
-- FECHA DATE DEFAULT SYSDATE

create table TBL_CONTROLES (
   NRO_CONTROL    number,
   NOMBRE_USUARIO varchar2(100),
   DESCRIPCION    varchar2(500),
   FECHA_HORA     timestamp
);

create sequence SQ_NRO_CONTROL start with 1 increment by 1 nocache;

create or replace trigger TG_TBL_CONTROLES before
   insert on TBL_CONTROLES
   for each row
declare begin
   :NEW.NRO_CONTROL := SQ_NRO_CONTROL.NEXTVAL;
end;





-- 2. Cree un trigger que permita controlar si se está ingresando, modificando o
-- eliminando un registro de la tabla TBL_DETALLE_VENTA y de la tabla
-- TBL_VENTA. Este trioger debe utlizarse para almacenar un control en tabla
-- TBL_CONTROL y que registre lo que se ha realizado, si ha sido un ingreso, una
-- modificación o eliminación de fila. En la columna NOMBRE_USUARIO se debe
-- registrar el usuario que està haciendo dichas modificaciones, se debe controlar
-- que solamente el usuario uscrXX pueda insertar registros en la tabla
-- TBL_CONTROLES.

create or replace trigger TG_TBL_CONTROL_VENTAS after
   insert or update or delete on TBL_VENTA
   for each row
declare
   V_OPERACION varchar2(50);
begin
   if INSERTING then
      V_OPERACION := 'INSERT';
   elsif UPDATING then
      V_OPERACION := 'UPDATE';
   elsif DELETING then
      V_OPERACION := 'DELETE';
   end if;
   insert into TBL_CONTROLES values ( SQ_NRO_CONTROL.nextval,
                                      USER,
                                      V_OPERACION,
                                      SYSDATE );

end;

select *
  from TBL_DETALLE_VENTA;

create or replace trigger TG_TBL_CONTROL_DETALLE_VENTA after
   insert or update or delete on TBL_DETALLE_VENTA
   for each row
declare
   V_OPERACION varchar2(50);
begin
   if INSERTING then
      V_OPERACION := 'INSERT';
   elsif UPDATING then
      V_OPERACION := 'UPDATE';
   elsif DELETING then
      V_OPERACION := 'DELETE';
   end if;
   insert into TBL_CONTROLES values ( SQ_NRO_CONTROL.nextval,
                                      USER,
                                      V_OPERACION,
                                      SYSDATE );
end;





-- 3. Programe un trigger que al momento de ingresar o modificar un registro en la tabla
-- TBL_DETALLE_VENTA actualice de manera automática la tabta TBL_VENTA y se
-- modifique su total de acuerdo a todos los precios unitarios de los productos que
-- pertenecen a dicho número de venta, además, es necesario que el trigger
-- actualice la tabla TBL_PRODUCTO modificando la CANT_EXISTENCIA para los
-- productos en los cuales se modifico la cantidad en la tabla
-- TBL_DETALLE_VENTA, si fue el caso.
select *
  from TBL_DETALLE_VENTA;
select *
  from TBL_VENTA;
select *
  from TBL_PRODUCTO;


create or replace trigger TG_ACT_TBL_VENTA after
   insert or update or delete on TBL_DETALLE_VENTA
   for each row
declare
   V_NUEVO_TOTAL    number;
   V_NUEVA_CANTIDAD number;
   V_STOCK_ACTUAL   number;
   V_ID_VENTA       TBL_DETALLE_VENTA.NRO_VENTA%type;
   V_P_CODIGO       TBL_VENTA.TOTAL%type;
begin
   V_NUEVO_TOTAL := :NEW.CANTIDAD * :NEW.PRECIO_UNITARIO;
   if INSERTING then
      V_ID_VENTA := :NEW.NRO_VENTA;
      V_P_CODIGO := :NEW.P_CODIGO;
      select CANT_EXISTENCIA
        into V_STOCK_ACTUAL
        from TBL_PRODUCTO
       where P_CODIGO = V_P_CODIGO;

      V_STOCK_ACTUAL := V_STOCK_ACTUAL - :NEW.CANTIDAD;
   end if;

   if UPDATING then
      V_ID_VENTA := :OLD.NRO_VENTA;
      V_P_CODIGO := :OLD.P_CODIGO;
      select CANT_EXISTENCIA
        into V_STOCK_ACTUAL
        from TBL_PRODUCTO
       where P_CODIGO = :OLD.P_CODIGO;

      V_STOCK_ACTUAL := V_STOCK_ACTUAL - :NEW.CANTIDAD;
   end if;


   update TBL_VENTA
      set
      TOTAL = V_NUEVO_TOTAL
    where NRO_VENTA = V_ID_VENTA;

   update TBL_PRODUCTO
      set
      CANT_EXISTENCIA = V_STOCK_ACTUAL
    where P_CODIGO = V_P_CODIGO;

end;