-- secuencias 

grant
   create any sequence,
   drop any sequence
to C##_PROGRAMADOR_JUNIOR;

create sequence SQ_CLIENTES start with 11 increment by 1 nocache;

select 'L' || SQ_CLIENTES.nextval
  from DUAL;

select SQ_CLIENTES.currval
  from DUAL;

drop sequence SQ_CLIENTES;

insert into CLIENTES values ( SQ_CLIENTES.nextval,
                              '1234567',
                              'unah',
                              'obed castellanos',
                              'bulevar suyapa',
                              2230404,
                              'OBED.CASTELLANOS@UNAH.HN',
                              '3203920',
                              '2299483' );

--- triggers
-- esto se asocian a una sola tabla. Estos sirvel más que todo para completar algun valor.
-- Usos más comunes
--Gestionar llave primaria
-- Crear bitacoras. 
-- Para las validaciones es mejor usar procedimientos o funciones.

-- dos variables 

-- :NEW acceder a los valores nuevos
-- :OLD acceder a los valores antiguos



-- insert 
-- :new 


-- update 
--     :new 
--     :old 

-- delete 
--     :old


--- UN TRIGGER NO PUEDE EJECUTAR COMMIT NI ROLLBACK POR DEFECTO YA QUE SE NECESITAN OPERACIONES AUTONOMAS.

-- permisos triggers

grant create any trigger,
   alter any trigger,
   drop any trigger
to USUARIO;


---
create or replace trigger TG_PK_CLIENTES before
   insert on CLIENTES
   for each row
declare begin
   DBMS_OUTPUT.PUT_LINE(:NEW.CLIENTEID);
   :NEW.CLIENTEID := SQ_CLIENTES.NEXTVAL;
end;


insert into CLIENTES (
   CEDULA_RUC,
   NOMBRECIA,
   NOMBRECONTACTO,
   DIRECCIONCLI,
   FAX,
   EMAIL,
   CELULAR,
   FIJO
) values ( '1234567',
           'unah',
           'obed castellanos',
           'bulevar suyapa',
           2230404,
           'OBED.CASTELLANOS@UNAH.HN',
           '3203920',
           '2299483' );


insert into CLIENTES (
   CLIENTEID,
   CEDULA_RUC,
   NOMBRECIA,
   NOMBRECONTACTO,
   DIRECCIONCLI,
   FAX,
   EMAIL,
   CELULAR,
   FIJO
) values ( 30, -- AQUI TENDRIA PRORIDAD EL TRIGGER, PORQUE SE EJECUTA ANTES. 
           '1234567',
           'unah-VS',
           'CARLOS PEREZ',
           'bulevar DEL NORTE',
           2230404,
           'CARLOS.PEREZ@UNAH.HN',
           '3203920',
           '2299483' );


select *
  from CLIENTES;


  --- CON LA TABLA PRODUCTOS CREAR UN TRIGGER QUE SRIVA PARA HACER VALIDACIONES EN LOS CAMPOS QUE SON OBLIGATORIOS, QUE EL PRECIO UNITARIO QUE SEA MAYOR DE 100 
  -- VALIDAR QUE LA EXISTENCIA DEL PRODUCTO SEA MAYOR A 0
  --- VALIDAR QUE EXISTA EL PROVEEDOR  Y LA CATEGORIA, SI NO EXISTE , PUES AGREGAR UNO POR DEFECTO,
  --  PARA LA PK, OBTENER EL ULTIMO VALOR Y EL SIGUINTE PARA LA NUEVA

create or replace trigger TG_INGRESA_PRODUCTO before
   insert on PRODUCTOS
   for each row
declare
   V_PRODUCTOID PRODUCTOS.PRODUCTOID%type;
   V_EXISTE_COD number(1);
begin
   select NVL(
      MAX(PRODUCTOID) + 1,
      1
   )
     into V_PRODUCTOID
     from PRODUCTOS;


   :NEW.PRODUCTOID := V_PRODUCTOID;
   select count(*)
     into V_EXISTE_COD
     from CATEGORIAS
    where CATEGORIAID = :NEW.CATEGORIAID;


   if ( V_EXISTE_COD = 0 ) then
   -- validar codigo del proveedor
      :NEW.CATEGORIAID := 100;
   end if;
   if ( :NEW.PRECIOUNIT <= 100 ) then
      :NEW.PRECIOUNIT := 200;
   end if;

   if ( :NEW.EXISTENCIA <= 0 ) then
      :NEW.EXISTENCIA := 5;
   end if;

   select count(*)
     into V_EXISTE_COD
     from PROVEEDORES
    where PROVEEDORID = :NEW.PROVEEDORID;
   if ( V_EXISTE_COD = 0 ) then
      :NEW.PROVEEDORID := 10;
   end if;
   :NEW.FECHA_INSERCION := SYSTIMESTAMP;
   :NEW.USUARIO := USER;
end;







insert into PRODUCTOS (
   PROVEEDORID,
   CATEGORIAID,
   DESCRIPCION,
   PRECIOUNIT,
   EXISTENCIA
) values ( 9999,
           3500,
           'LECHE DESCREMADA',
           - 20,
           - 1 );


insert into PRODUCTOS (
   PROVEEDORID,
   CATEGORIAID,
   DESCRIPCION,
   PRECIOUNIT,
   EXISTENCIA
) values ( 100,
           40,
           'BISTEK',
           125.32,
           250 );

insert into PRODUCTOS (
   PROVEEDORID,
   CATEGORIAID,
   DESCRIPCION,
   PRECIOUNIT,
   EXISTENCIA
) values ( 40,
           300,
           'JABON LIQUIDO DE PLATOS',
           78.95,
           300 );


select *
  from CATEGORIAS;
select *
  from PROVEEDORES;

select *
  from PRODUCTOS;


alter table PRODUCTOS add FECHA_INSERCION timestamp;
alter table PRODUCTOS add FECHA_ACTUALIZACION timestamp;
alter table PRODUCTOS add USUARIO varchar2(50);



create or replace trigger TG_PRODUCTOS_FECHA_ACT before
   update on PRODUCTOS
   for each row
declare begin
   :NEW.FECHA_ACTUALIZACION := SYSTIMESTAMP;
   :NEW.USUARIO := USER;
end;

update PRODUCTOS
   set
   DESCRIPCION = 'JABON LAVAPLATOS'
 where PRODUCTOID = 16;

 --- ioeracibes con commit explicito son los de la creacion de objetos y edicion de objetos, entonces los cambios despues de crear las 
 -- los objetos se guardan los cambios.

 --- Crear auditorias atravez de una tabla, ahi definiremos que guardar para poder tener un bitacora de la base de datos
 -- la manera en que se haga se difine por decision propia del programador. NO hay niguna alternativa que diga que se tengan
 -- que hacer exactamente asi. Peros si por lo general se crean con datos que cambian constantemente en la base de datos.
 --

create table TBL_LOG_PRODUCTOS (
   PRODUCTOID        number,
   PROVEEDORID       number,
   CATEGORIAID       number,
   DESCRIPCION       char(50),
   PRECIOUNIT        number,
   EXISTENCIA        number,
   USUARIO           varchar2(50),
   OPERACION         varchar2(50),
   PROVVEDORID_NUEVO number,
   CATEGORIAID_NUEVO number,
   DESCRIPCION_NUEVO char(50),
   PRECIOUNIT_NUEVO  number,
   EXISTENCIA_NUEVO  number
);



create or replace trigger TG_LOG_PRODUCTOS after
   insert or update or delete on PRODUCTOS
   for each row
declare
   pragma AUTONOMOUS_TRANSACTION;
begin
   if ( INSERTING ) then
      insert into TBL_LOG_PRODUCTOS values ( :NEW.PRODUCTOID
                                             || 'p',
                                             null,
                                             null,
                                             null,
                                             null,
                                             null,
                                             USER,
                                             'INSERCION',
                                             :NEW.PROVEEDORID,
                                             :NEW.CATEGORIAID,
                                             :NEW.DESCRIPCION,
                                             :NEW.PRECIOUNIT,
                                             :NEW.EXISTENCIA );
   elsif ( UPDATING ) then
      insert into TBL_LOG_PRODUCTOS values ( :NEW.PRODUCTOID,
                                             :OLD.PROVEEDORID,
                                             :OLD.CATEGORIAID,
                                             :OLD.DESCRIPCION,
                                             :OLD.PRECIOUNIT,
                                             :OLD.EXISTENCIA,
                                             USER,
                                             'ACTUALIZACION',
                                             :NEW.PROVEEDORID,
                                             :NEW.CATEGORIAID,
                                             :NEW.DESCRIPCION,
                                             :NEW.PRECIOUNIT,
                                             :NEW.EXISTENCIA );
   elsif ( DELETING ) then
      insert into TBL_LOG_PRODUCTOS values ( :OLD.PRODUCTOID,
                                             :OLD.PROVEEDORID,
                                             :OLD.CATEGORIAID,
                                             :OLD.DESCRIPCION,
                                             :OLD.PRECIOUNIT,
                                             :OLD.EXISTENCIA,
                                             USER,
                                             'ELIMINACION',
                                             null,
                                             null,
                                             null,
                                             null,
                                             null );
   end if;
   commit;
end;




insert into PRODUCTOS (
   PROVEEDORID,
   CATEGORIAID,
   DESCRIPCION,
   PRECIOUNIT,
   EXISTENCIA
) values ( 40580,
           300,
           'ACE',
           78.95,
           300 );


begin
   update PRODUCTOS
      set DESCRIPCION = 'SUAVITEL',
          EXISTENCIA = - 9,
          PRECIOUNIT = 250
    where PRODUCTOID > 8;

exception
   when others then
      DBMS_OUTPUT.PUT_LINE(SQLCODE);
      DBMS_OUTPUT.PUT_LINE(SQLERRM);
end;


begin
   insert into PRODUCTOS (
      PROVEEDORID,
      CATEGORIAID,
      DESCRIPCION,
      PRECIOUNIT,
      EXISTENCIA
   ) values ( 40580,
              300,
              'jabon',
              78.95,
              300 );

exception
   when others then
      rollback;
      DBMS_OUTPUT.PUT_LINE(SQLCODE);
      DBMS_OUTPUT.PUT_LINE(SQLERRM);
end;

rollback;

select *
  from PRODUCTOS;

select *
  from TBL_LOG_PRODUCTOS;

--- UN TRIGGER NO PUEDE EJECUTAR UN COMMIT Y UN ROLLABACK, POR ESO SE DEBEN DE SEPAARAR LAS TRANSAACIONES

-- EJEMP;O
-- T1 ES EL INSERT , UPDATE Y DELETE INICIAL
-- T2 TRIGGER 
-- AHORA  SI EN UNA 
-- TRASACCIONES AUTONOMAS ES DE LA TRASACCION PRINCIOPAL SEPARO LA PRINCIPARL EN MÁS PEQUEÑÁS DEFINIDAD POR MI
-- DEBO DEFINIR CUANTOS OBJETOS INTERVIENEN EN ESA TRASACCIONES , ANALIZANDO QUE DEBO DE DE GUARDAO O NO . 


-- ====== TRASACCIONES OUTONONAS  