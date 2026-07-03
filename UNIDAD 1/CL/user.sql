grant create session,
   create any table,
   drop any table,
   alter any table
to C##_PEDIDOS;
grant
   create any sequence,
   drop any sequence
to C##_PEDIDOS;
grant create any trigger,
   drop any trigger,
   alter any trigger
to C##_PEDIDOS;
grant insert any table to C##_PEDIDOS;

alter user C##_PEDIDOS
   quota unlimited on USERS;

alter user C##_MIG_PEDIDOS
   quota unlimited on USERS;

create user C##_MIG_PEDIDOS identified by 1234;

alter user C##_MIG_VUELOS
   quota unlimited on USERS;

grant create session,
   create any table,
   drop any table,
   alter any table
to C##_MIG_PEDIDOS;
grant
   create any sequence,
   drop any sequence
to C##_MIG_PEDIDOS;
grant create any trigger,
   drop any trigger,
   alter any trigger
to C##_MIG_PEDIDOS;
grant insert any table to C##_MIG_PEDIDOS;

grant select,insert on C##_PEDIDOS.CATEGORIAS to C##_MIG_PEDIDOS;
grant select,insert on C##_PEDIDOS.PROVEEDORES to C##_MIG_PEDIDOS;
grant select,insert on C##_PEDIDOS.PRODUCTOS to C##_MIG_PEDIDOS;

-- PARA ELIMINAR SE REEMPLAZA GRANT POR REVOKE Y ON POR FROM
revoke select,insert on C##_PEDIDOS.CATEGOIRAS from C##_MIG_PEDIDOS;