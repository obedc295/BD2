declare
   V_PROVEEDOR PROVEEDORES%ROWTYPE;
begin
   select *
     into V_PROVEEDOR
     from PROVEEDORES
    where PROVEEDORID = 10;


   V_PROVEEDOR.CELUPROV := '1920284098210482094802938402';
exception
   when NO_DATA_FOUND then
      DBMS_OUTPUT.PUT_LINE('Proveedor no existe. ');
   when TOO_MANY_ROWS then
      DBMS_OUTPUT.PUT_LINE('Se encontraron varios registros, no se puede procesar. ');
   when others then
      DBMS_OUTPUT.PUT_LINE('Error encontrado. '
                           || CHR(10)
                           || 'Código error: '
                           || SQLCODE
                           || CHR(10)
                           || ' Mensaje error: ' || SQLERRM);
end;
/
   set SERVEROUTPUT on;