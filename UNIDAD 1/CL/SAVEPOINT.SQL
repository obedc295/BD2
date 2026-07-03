-- SIRVE A MEDIDA DE QUE YO PUEDO SALVAR PUNTOS EN LA EJECUCION QUE ESTAN CORRECTOS . 
select *
  from CATEGORIAS;
delete from CATEGORIAS
 where CATEGORIAID < 100;

declare
   V_EST_CORRECTO number(1);
begin
   insert into CATEGORIAS values ( 1,
                                   'CATEGORIA 1' );
   insert into CATEGORIAS values ( 2,
                                   'CATEGORIA 2' );
   insert into CATEGORIAS values ( 3,
                                   'CATEGORIA 3' );
   savepoint ESTADO1;
   V_EST_CORRECTO := 1;
   insert into CATEGORIAS values ( 4,
                                   'CATEGORIA 4' );
   insert into CATEGORIAS values ( 4,
                                   'CATEGORIA 5' );
   savepoint ESTADO2;
   V_EST_CORRECTO := 2;
   insert into CATEGORIAS values ( 6,
                                   'CATEGORIA 6' );
   insert into CATEGORIAS values ( 6,
                                   'CATEGORIA 7' );
   savepoint ESTADO3;
   V_EST_CORRECTO := 3;
   commit;
exception
   when others then
      DBMS_OUTPUT.PUT_LINE('ERROR AL INSERTAR: ' || SQLCODE);
      case
         when V_EST_CORRECTO = 1 then
            rollback to savepoint ESTADO1;
            commit;
         when V_EST_CORRECTO = 2 then
            rollback to savepoint ESTADO2;
            commit;
         when V_EST_CORRECTO = 3 then
            commit;
      end case;
      --COMMIT;
end;