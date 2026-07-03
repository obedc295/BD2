select *
  from C##_PEDIDOS.CATEGORIAS;
/


declare
   cursor C_REGISTRO_CATEGORIAS is
   select *
     from C##_PEDIDOS.CATEGORIAS
    where not exists (
      select 1
        from C##_MIG_PEDIDOS.CATEGORIAS
       where C##_PEDIDOS.CATEGORIAS.CATEGORIAID = C##_MIG_PEDIDOS.CATEGORIAS.CATEGORIAID
   );

   cursor C_REGISTRO_PROVEEDORES is
   select *
     from C##_PEDIDOS.PROVEEDORES;


   cursor C_REGISTRO_PRODUCTOS is
   select *
     from C##_PEDIDOS.PRODUCTOS;




   V_REGISTRO_CATEGORIAS  C_REGISTRO_CATEGORIAS%ROWTYPE;
   V_REGISTRO_PROVEEDORES C_REGISTRO_PROVEEDORES%ROWTYPE;
   V_REGISTRO_PRODUCTOS   C_REGISTRO_PRODUCTOS%ROWTYPE;
begin
   open C_REGISTRO_CATEGORIAS;
   


   -- INSERTAR CATEGORIAS
   loop
      fetch C_REGISTRO_CATEGORIAS into V_REGISTRO_CATEGORIAS;
      exit when C_REGISTRO_CATEGORIAS%NOTFOUND;
      insert into C##_MIG_PEDIDOS.CATEGORIAS (
         CATEGORIAID,
         NOMBRECAT
      ) values ( V_REGISTRO_CATEGORIAS.CATEGORIAID,
                 V_REGISTRO_CATEGORIAS.NOMBRECAT );
    --COMMIT;
      DBMS_OUTPUT.PUT_LINE('REGISTRO INSERTADO CORRECTAMENTE. ');
   end loop;
   close C_REGISTRO_CATEGORIAS;
   open C_REGISTRO_PROVEEDORES;
   -- INSERTAR PROVEEDORES
   fetch C_REGISTRO_PROVEEDORES into V_REGISTRO_PROVEEDORES;
   while ( C_REGISTRO_PROVEEDORES%FOUND ) loop
      insert into C##_MIG_PEDIDOS.PROVEEDORES (
         PROVEEDORID,
         NOMBREPROV,
         CONTACTO,
         CELUPROV,
         FIJOPROV
      ) values ( V_REGISTRO_PROVEEDORES.PROVEEDORID,
                 V_REGISTRO_PROVEEDORES.NOMBREPROV,
                 V_REGISTRO_PROVEEDORES.CONTACTO,
                 V_REGISTRO_PROVEEDORES.CELUPROV,
                 V_REGISTRO_PROVEEDORES.FIJOPROV );
      fetch C_REGISTRO_PROVEEDORES into V_REGISTRO_PROVEEDORES;
      DBMS_OUTPUT.PUT_LINE('REGISTRO INSERTADO CORRECTAMENTE. ');
 --COMMIT;
   end loop;
   close C_REGISTRO_PROVEEDORES;
   open C_REGISTRO_PRODUCTOS;
   loop
      fetch C_REGISTRO_PRODUCTOS into V_REGISTRO_PRODUCTOS;
      exit when C_REGISTRO_PRODUCTOS%NOTFOUND;
      insert into PRODUCTOS values ( V_REGISTRO_PRODUCTOS.PRODUCTOID,
                                     V_REGISTRO_PRODUCTOS.PROVEEDORID,
                                     V_REGISTRO_PRODUCTOS.CATEGORIAID,
                                     V_REGISTRO_PRODUCTOS.DESCRIPCION,
                                     V_REGISTRO_PRODUCTOS.PRECIOUNIT,
                                     V_REGISTRO_PRODUCTOS.EXISTENCIA );

      DBMS_OUTPUT.PUT_LINE('REGISTRO INSERTADO CORRECTAMENTE. ');
   end loop;


   close C_REGISTRO_PRODUCTOS;
exception
   when DUP_VAL_ON_INDEX then
      DBMS_OUTPUT.PUT_LINE('Codigo duplicado. ');
      DBMS_OUTPUT.PUT_LINE(SQLCODE);
      DBMS_OUTPUT.PUT_LINE(SQLERRM);
end;
/
   SET SERVEROUTPUT ON;

select *
  from CATEGORIAS;

select *
  from PROVEEDORES;

select *
  from PRODUCTOS;



  -------------------------------------------

declare
   type T_REGISTRO_CATEGORIAS is
      table of CATEGORIAS%ROWTYPE;
   type T_REGISTRO_PROVEEDORES is
      table of PROVEEDORES%ROWTYPE;
   type T_REGISTRO_PRODUCTOS is
      table of PRODUCTOS%ROWTYPE;
   V_REGISTRO_CATEGORIAS  T_REGISTRO_CATEGORIAS;
   V_REGISTRO_PROVEEDORES T_REGISTRO_PROVEEDORES;
   V_REGISTRO_PRODUCTOS   T_REGISTRO_PRODUCTOS;
begin
   select *
   bulk collect
     into V_REGISTRO_PROVEEDORES
     from C##_PEDIDOS.PROVEEDORES;


   for NUMFILA in 1..sql%ROWCOUNT loop
      insert into C##_MIG_PEDIDOS.PROVEEDORES (
         PROVEEDORID,
         NOMBREPROV,
         CONTACTO,
         CELUPROV,
         FIJOPROV
      ) values ( V_REGISTRO_PROVEEDORES(NUMFILA).PROVEEDORID,
                 V_REGISTRO_PROVEEDORES(NUMFILA).NOMBREPROV,
                 V_REGISTRO_PROVEEDORES(NUMFILA).CONTACTO,
                 V_REGISTRO_PROVEEDORES(NUMFILA).CELUPROV,
                 V_REGISTRO_PROVEEDORES(NUMFILA).FIJOPROV );
   end loop;



   select *
   bulk collect
     into V_REGISTRO_CATEGORIAS
     from C##_PEDIDOS.CATEGORIAS;


   for NUMFILA in 1..sql%ROWCOUNT loop
      insert into C##_MIG_PEDIDOS.CATEGORIAS (
         CATEGORIAID,
         NOMBRECAT
      ) values ( V_REGISTRO_CATEGORIAS(NUMFILA).CATEGORIAID,
                 V_REGISTRO_CATEGORIAS(NUMFILA).NOMBRECAT );



   end loop;


   select *
   bulk collect
     into V_REGISTRO_PRODUCTOS
     from C##_PEDIDOS.PRODUCTOS;


   for NUMFILA in 1..sql%ROWCOUNT loop
      insert into PRODUCTOS values ( V_REGISTRO_PRODUCTOS(NUMFILA).PRODUCTOID,
                                     V_REGISTRO_PRODUCTOS(NUMFILA).PROVEEDORID,
                                     V_REGISTRO_PRODUCTOS(NUMFILA).CATEGORIAID,
                                     V_REGISTRO_PRODUCTOS(NUMFILA).DESCRIPCION,
                                     V_REGISTRO_PRODUCTOS(NUMFILA).PRECIOUNIT,
                                     V_REGISTRO_PRODUCTOS(NUMFILA).EXISTENCIA );
   end loop;
   -- 

exception
   when DUP_VAL_ON_INDEX then
      rollback;
      DBMS_OUTPUT.PUT_LINE('Codigo duplicado. ');
      DBMS_OUTPUT.PUT_LINE(SQLCODE);
      DBMS_OUTPUT.PUT_LINE(SQLERRM);
end;



select *
  from CATEGORIAS;

select *
  from PROVEEDORES;

select *
  from PRODUCTOS;