-- 1) Hacer uso de un bloque anónimo que obtenga todos los vuelos realizados por la 
-- compañía Iberia en el año 2004 en el mes de junio. El bloque anónimo debe recorrer los 
-- registros e imprimir el código de vuelo, fecha del vuelo, detalles, la descripción de si el 
-- vuelo tiene incluido catering y qué tipo de vuelo es. Recorrer la información con un ciclo 
-- FOR y un cursor explícito

select *
  from VUELOS;

select *
  from CATERING;


select *
  from COMPANIAS; -- ID IBERI

declare
   cursor C_REGISTRO_VUELOS is
   select A.ID_VUELO,
          A.FECHA_VUELO,
          A.DETALLES,
          A.COMP_ID_COMP,
          B.CN_CATERING,
          C.CN_VUELO
     from VUELOS A
    inner join CATERING B
   on A.CAT_ID_CATERING = B.ID_CATERING
    inner join TIPOS_VUELO C
   on A.TVUE_ID_VUELO = C.ID_VUELO;
   
   V_CONTADOR NUMBER;
begin
V_CONTADOR := 0;
   for FILA in C_REGISTRO_VUELOS loop
      if (
         EXTRACT(year from FILA.FECHA_VUELO) = '2004'
         and EXTRACT(month from FILA.FECHA_VUELO) = 6
         and FILA.COMP_ID_COMP = 'IBERI'
      ) then
      V_CONTADOR := V_CONTADOR + 1;
       DBMS_OUTPUT.PUT_LINE('========== VUELO DE LA COMPANIA IBERIA EN EL 06-2004  # ' || V_CONTADOR || ' ========== ');
         DBMS_OUTPUT.PUT_LINE('ID VUELO: ' || FILA.ID_VUELO);
         DBMS_OUTPUT.PUT_LINE('FECHA VUELO: ' || FILA.FECHA_VUELO);
         DBMS_OUTPUT.PUT_LINE('DETALLLES:  ' || FILA.DETALLES);
         DBMS_OUTPUT.PUT_LINE('DESCRIPCION CATERING: ' || FILA.CN_CATERING);
         DBMS_OUTPUT.PUT_LINE('TIPO VUELO:  ' || FILA.CN_VUELO);
          DBMS_OUTPUT.PUT_LINE(CHR(13));
      end if;
   end loop;
end;

SET SERVEROUTPUT ON ;