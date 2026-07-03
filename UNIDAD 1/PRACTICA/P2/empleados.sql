--
--
--NOTA: para realizar estos ejercicios deben trabajar con la base de datos Venta
--Bicicletas e Inmobiliaria. Los scripts se han subido al campus virtual.
--
--1) Utilizando la base de datos venta bicicletas y la tabla ordenes y clientes, crear un
--bloque anonimo que permita obtener todas las ordenes y los clientes que colocaron
--dichas ordenes, toda esta informacion se debe procesar y almacenar o guardar en una
--tabla llamada TBL_ORDENES y TBL_CLIENTES respectivamente. La tabla
--TBL_ORDENES y TBL_CLIENTES se deben crear en otro esquema el cual tendra el
--nombre que usted desee. Es necesario utilizar los elementos de programacion de PL/SQL
--vistos hasta el momento en la asignatura. Adicionalmente, debe tener en cuenta todo lo
--necesario para la asignación de permisos, de modo que la información se pueda obtener
--desde el esquema venta bicicleta y trasladarse al esquema nuevo que usted creará.

-- ESQUEMA PRINCIPAL

create user C##_BICICLETAS_20241002161 identified by 1234
    default tablespace USERS
    temporary tablespace TEMP
    quota unlimited on USERS;

grant
    create session,
    create any trigger,
    create any table,
    drop any table,
    alter any table,
    create any sequence
to C##_BICICLETAS_20241002161;

-- ESQUEMA SECUNDARIO 
create user C##_BICIS_2 identified by 1234
    default tablespace USERS
    temporary tablespace TEMP
    quota unlimited on USERS;

grant
    create session,
    create any trigger,
    create any table,
    drop any table,
    create any sequence,
    alter any table
to C##_BICIS_2;

-- PERMISOS PARA ACCEDER
grant select on C##_BICICLETAS_20241002161.CUSTOMERS to C##_BICIS_2;

grant select on C##_BICICLETAS_20241002161.ORDERS to C##_BICIS_2;

--- TABLAS A CREAER EN C##_BICIS_2


create table TBL_ORDENES (
    ORDER_ID      number primary key,
    CUSTOMER_ID   number,
    ORDER_STATUS  number(2) not null,
	-- Order status: 1 = Pending; 2 = Processing; 3 = Rejected; 4 = Completed
    ORDER_DATE    varchar2(8) not null,
    REQUIRED_DATE varchar2(8) not null,
    SHIPPED_DATE  varchar2(8),
    STORE_ID      number not null,
    STAFF_ID      number not null,
    foreign key ( CUSTOMER_ID )
        references TBL_CLIENTES ( CUSTOMER_ID )
            on delete cascade
);

create table TBL_CLIENTES (
    CUSTOMER_ID number primary key,
    FIRST_NAME  varchar2(255) not null,
    LAST_NAME   varchar2(255) not null,
    PHONE       varchar2(25),
    EMAIL       varchar2(255) not null,
    STREET      varchar2(255),
    CITY        varchar2(50),
    STATE       varchar2(25),
    ZIP_CODE    varchar2(5)
);


-- PRIMERO INSERTAMOS LOS CLIENTES LUEGO LAS ORDENES 

declare
    type T_TABLA_CLIENTES is
        table of TBL_CLIENTES%ROWTYPE;
    type T_TABLA_ORDENES is
        table of TBL_ORDENES%ROWTYPE;
    V_REGISTROS_CLIENTES T_TABLA_CLIENTES;
    V_REGISTROS_ORDENES T_TABLA_ORDENES;
begin
    select
        *
    bulk collect
    into V_REGISTROS_CLIENTES
    from
        C##_BICICLETAS_20241002161.CUSTOMERS;

    for FILA in 1..sql%ROWCOUNT loop
        insert into TBL_CLIENTES values V_REGISTROS_CLIENTES ( FILA );

    end loop;

    select
        *
    bulk collect
    into V_REGISTROS_ORDENES
    from
        C##_BICICLETAS_20241002161.ORDERS;

    for FILA in 1..sql%ROWCOUNT loop
        insert into TBL_ORDENES values V_REGISTROS_ORDENES ( FILA );
    end loop;

end;

SELECT COUNT(*) FROM TBL_CLIENTES;
SELECT COUNT(*) FROM TBL_ORDENES;
--2) Utilizando la base de datos de inmobiliaria, hacer uso de un bloque anonimo que
--permita migrar los registros de la tabla empleados a una nueva estructura de tablas. Las
--nuevas tablas serán:
--
--Empleados
--. código de empleado (pk)
--. nombre completo
--· nif empleado
--. fecha de nacimiento
--· salario
--· código de horario laboral
--
--Direcciones
--· código direccion (pk)
--. dirección
--· codigo de empleado
--
--Telefonos
--· código teléfono (pk)
--· numero teléfono
--· código de empleado
--
--Correos
--. código correo (pk)
--correo
--codigo de empleado
--
--Horarios Laborales
--. código horario laboral (pk)
--jornada laboral
--
--Usted debe crear las tablas y asignarle los tipos de datos respectivos a cada campo. Para
--realizar la migración de los datos debe tomar en cuenta las reglas del negocio:
--
--. Un empleado puede tener registradas varias direcciones
--. Un empleado puede tener registrados varios teléfonos
--. Un empleado puede tener registrados varios correos
--· El horario o jomada laboral se puede repetir para diferentes empleados
--. En la tabla horarios laborales el valor almacenado en la jornada laboral no se
--puede repetir, es decir, que al momento de la migracion se debe garantizar que se
--guarden valores únicos
--
--Los cambios se deben aprobar y en caso de algun error es necesario deshacer los
--cambios.
--


--
--3) Utilizando la base de datos de inmobiliaria, se pide hacer uso de bloques anónimos
--para llevar a cabo el ejercicio planteado. Obtener todos los empleados que tengan 30 año
--o mas de haber nacido y cuyo salario sea superior o igual a 30,000.
--
--Con los empleados que cumplan la condicion, se debe guardar esta información en una
--nueva tabla llamada empleados jubilación, cuya estructura debe ser creada por usted. Los
--cambios se deben aprobar y en caso de algun error es necesario deshacer los cambios.