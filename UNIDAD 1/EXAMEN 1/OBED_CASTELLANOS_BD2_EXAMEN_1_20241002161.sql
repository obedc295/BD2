-- CREACION DEL USUARIO 

-- EXAMEN 1 OBED ELIEL CASTELLANOS 2024100161 BD2

create user C##OBEDC_EX1 identified by 123
    default tablespace USERS
    temporary tablespace TEMP
    quota unlimited on USERS;

grant
    create session,
    create any table,
    create any trigger,
    create any sequence,
    alter any table,
    alter any trigger,
    alter any sequence,
    drop any table,
    drop any trigger,
    drop any sequence
to C##OBEDC_EX1;

SET SERVEROUTPUT ON;
--- CREACION DE OBJETOS

-- PROBLEMA 1. -----------------------------------------------
drop table TBL_INFO_PROD_20241002161;

create table TBL_INFO_PROD_20241002161 (
    CODIGO_PRODUCTO  number,
    NOMBRE_PRODUCTO  varchar2(500),
    DESCRIPCION      varchar2(2000),
    PRECIO_LISTA     number,
    NOMBRE_CATEGORIA varchar2(50),
    FECHA_GUARDADO   timestamp
);
    
-- BLOQUE ANONIMO 

declare
    type T_TABLA_INFO is
        table of TBL_INFO_PROD_20241002161%ROWTYPE;
    V_REGISTROS T_TABLA_INFO;
begin
    select
        A.PRODUCT_ID,
        A.PRODUCT_NAME,
        A.DESCRIPTION,
        A.LIST_PRICE,
        B.CATEGORY_NAME,
        SYSTIMESTAMP
    bulk collect
    into V_REGISTROS
    from
             PRODUCTS A
        inner join PRODUCT_CATEGORIES B on A.CATEGORY_ID = B.CATEGORY_ID
    where
        B.CATEGORY_ID = 2
        or B.CATEGORY_ID = 4;

    for FILA in 1..sql%ROWCOUNT loop
        insert into TBL_INFO_PROD_20241002161 values ( V_REGISTROS(FILA).CODIGO_PRODUCTO,
                                                       V_REGISTROS(FILA).NOMBRE_PRODUCTO,
                                                       V_REGISTROS(FILA).DESCRIPCION,
                                                       V_REGISTROS(FILA).PRECIO_LISTA,
                                                       V_REGISTROS(FILA).NOMBRE_CATEGORIA,
                                                       V_REGISTROS(FILA).FECHA_GUARDADO );

    end loop;

    commit;
exception
    when others then
        rollback;
        DBMS_OUTPUT.PUT_LINE('COD DE ERROR ' || SQLCODE || 'MENSAJE DE ERROR ' || SQLERRM);
end;

select
    *
from
    TBL_INFO_PROD_20241002161;





-- PROBLEMA 2. -----------------------------------------------------------

create or replace trigger TG_VERIFICACION_PRODUCTOS_20241002161 before
    insert or update on PRODUCTS
    for each row
declare
    V_PRECIO_ADECUADO number;
begin
    V_PRECIO_ADECUADO := :NEW.STANDARD_COST * 1.25;
    if ( :NEW.LIST_PRICE < V_PRECIO_ADECUADO ) then
        :NEW.LIST_PRICE := V_PRECIO_ADECUADO;
    end if;

end;
    
    
-- COMANDOS DE PRUEBA --

insert into PRODUCTS values ( 301,
                              'COMPU NUEVA',
                              'LAPTOP',
                              100,
                              90,
                              1 );

update PRODUCTS
set
    LIST_PRICE = 100,
    STANDARD_COST = 300
where
    PRODUCT_ID = 301;

select
    *
from
    PRODUCTS
where
    PRODUCT_ID = 301;




-- EJERCICIO 3-----------------------------
create sequence SQ_BITACORA_20241002161 start with 1 increment by 1 nocache;

create table TBL_BITACORA_20241002161 (
    CODIGO_BITACORA    number,
    OPERACION          varchar2(50),
    USUARIO            varchar2(50),
    FECHA_MODIFICACION date,
    EMPLOYEE_ID        number,
    FIRST_NAME_VIEJO   varchar(255),
    LAST_NAME_VIEJO    varchar(255),
    EMAIL_VIEJO        varchar(255),
    PHONE_VIEJO        varchar(50),
    HIRE_DATE_VIEJO    date,
    MANAGER_ID_VIEJO   number(12, 0), -- fk
    JOB_TITLE_VIEJO    varchar(255),
    EMPLOYEE_ID_NUEVO  number,
    FIRST_NAME_NUEVO   varchar(255),
    LAST_NAME_NUEVO    varchar(255),
    EMAIL_NUEVO        varchar(255),
    PHONE_NUEVO        varchar(50),
    HIRE_DATE_NUEVO    date,
    MANAGER_ID_NUEVO   number(12, 0), -- fk
    JOB_TITLE_NUEVO    varchar(255)
);

create or replace trigger TG_EMPLEADOS_BITACORA after
    insert or update or delete on EMPLOYEES
    for each row
declare begin
    if INSERTING then
        insert into TBL_BITACORA_20241002161 values ( SQ_BITACORA_20241002161.nextval,
                                                      'INSERTANDO',
                                                      USER,
                                                      SYSDATE,
                                                      null,
                                                      null,
                                                      null,
                                                      null,
                                                      null,
                                                      null,
                                                      null,
                                                      null,
                                                      :NEW.EMPLOYEE_ID,
                                                      :NEW.FIRST_NAME,
                                                      :NEW.LAST_NAME,
                                                      :NEW.EMAIL,
                                                      :NEW.PHONE,
                                                      :NEW.HIRE_DATE,
                                                      :NEW.MANAGER_ID,
                                                      :NEW.JOB_TITLE );

    elsif UPDATING then
        insert into TBL_BITACORA_20241002161 values ( SQ_BITACORA_20241002161.nextval,
                                                      'ACTUALIZANDO',
                                                      USER,
                                                      SYSDATE,
                                                      :OLD.EMPLOYEE_ID,
                                                      :OLD.FIRST_NAME,
                                                      :OLD.LAST_NAME,
                                                      :OLD.EMAIL,
                                                      :OLD.PHONE,
                                                      :OLD.HIRE_DATE,
                                                      :OLD.MANAGER_ID,
                                                      :OLD.JOB_TITLE,
                                                      :NEW.EMPLOYEE_ID,
                                                      :NEW.FIRST_NAME,
                                                      :NEW.LAST_NAME,
                                                      :NEW.EMAIL,
                                                      :NEW.PHONE,
                                                      :NEW.HIRE_DATE,
                                                      :NEW.MANAGER_ID,
                                                      :NEW.JOB_TITLE );

    elsif DELETING then
        insert into TBL_BITACORA_20241002161 values ( SQ_BITACORA_20241002161.nextval,
                                                      'ELIMINANDO',
                                                      USER,
                                                      SYSDATE,
                                                      :OLD.EMPLOYEE_ID,
                                                      :OLD.FIRST_NAME,
                                                      :OLD.LAST_NAME,
                                                      :OLD.EMAIL,
                                                      :OLD.PHONE,
                                                      :OLD.HIRE_DATE,
                                                      :OLD.MANAGER_ID,
                                                      :OLD.JOB_TITLE,
                                                      null,
                                                      null,
                                                      null,
                                                      null,
                                                      null,
                                                      null,
                                                      null,
                                                      null );

    end if;
end;

-- COMAND0S DE PRUEBA

select
    *
from
    TBL_BITACORA_20241002161;

update EMPLOYEES
set
    FIRST_NAME = 'Verano'
where
    EMPLOYEE_ID = 107;