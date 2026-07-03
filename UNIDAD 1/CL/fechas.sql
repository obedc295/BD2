-- Manipulación de fechas en PLSQL
select *
  from PRODUCTOS;

  -- FUNCIONO EXTRACT SOLO FUNCIONA CON TIPOS DE DATOS DATE Y TIMESTAMP (HOUR, MIN, SECONDS)

select PRODUCTOID,
       DESCRIPCION,
       FECHA_INSERCION,
       FECHA_ACTUALIZACION,
       extract(hour from FECHA_INSERCION),
       extract(minute from FECHA_INSERCION),
       extract(second from FECHA_INSERCION)
  from PRODUCTOS;



select extract(year from FECHAORDEN)
  from ORDENES;