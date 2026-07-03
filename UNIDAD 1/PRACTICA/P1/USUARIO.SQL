create user C##_CASO_VENTAS identified by 1234;

grant create session,
   create any table,
   alter any table,
   drop any table,
   create any trigger,
   create any sequence
to C##_CASO_VENTAS;

alter user C##_CASO_VENTAS
   quota unlimited on USERS;