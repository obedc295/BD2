/* ============================================================
    TAREA DATAWAREHOUSE - BASE DE DATOS II
    Creacion de la base de datos OLAP
    ============================================================
*/
-- Crear y usar la base de datos OLAP
BEGIN
    CREATE DATABASE DW_Ventas;
END
GO

USE DW_Ventas;
GO

/*
============================================================
                    DIMENSIONES
============================================================
------------------------------------------------------------
                    DIM_CATEGORIA
-------------------------------------------------------------
*/
CREATE TABLE DIM_CATEGORIA (
    categoria_id   INT           NOT NULL,
    category_name  VARCHAR(255)  NOT NULL,
    CONSTRAINT PK_DIM_CATEGORIA PRIMARY KEY (categoria_id)
);
GO

/*
------------------------------------------------------------
                    DIM_PRODUCTO
------------------------------------------------------------
*/

CREATE TABLE DIM_PRODUCTO (
    producto_id    INT             NOT NULL,
    product_name   VARCHAR(255)    NOT NULL,
    description    VARCHAR(2000)   NULL,
    standard_cost  DECIMAL(9,2)    NULL,
    list_price     DECIMAL(9,2)    NULL,
    categoria_id   INT             NOT NULL,
    CONSTRAINT PK_DIM_PRODUCTO   PRIMARY KEY (producto_id),
    CONSTRAINT FK_PROD_CATEGORIA FOREIGN KEY (categoria_id)
        REFERENCES DIM_CATEGORIA(categoria_id)
);
GO

/*
------------------------------------------------------------
                    DIM_TIEMPO
------------------------------------------------------------
*/
CREATE TABLE DIM_TIEMPO (
    tiempo_id     DATE         NOT NULL, 
    año          INT          NOT NULL,
    mes       INT          NOT NULL, 
    dia    VARCHAR(20)  NOT NULL,  
    semestre      INT          NOT NULL,   
    trimestre     INT          NOT NULL,   
    num_semana    INT          NOT NULL, 
    CONSTRAINT PK_DIM_TIEMPO PRIMARY KEY (tiempo_id)
);
GO

/*
-- ------------------------------------------------------------
                DIM_REGION
------------------------------------------------------------
*/
CREATE TABLE DIM_REGION (
    region_id    INT          NOT NULL,
    region_name  VARCHAR(50)  NOT NULL,
    CONSTRAINT PK_DIM_REGION PRIMARY KEY (region_id)
);
GO

/*
------------------------------------------------------------
                    DIM_COUNTRY
--------------------------------------------------------------
*/

CREATE TABLE DIM_COUNTRY (
    country_id       CHAR(2)      NOT NULL,
    country_name  VARCHAR(40)  NOT NULL,
    region_id     INT          NOT NULL,
    CONSTRAINT PK_DIM_COUNTRY   PRIMARY KEY (country_id),
    CONSTRAINT FK_COUNTRY_REGION FOREIGN KEY (region_id)
        REFERENCES DIM_REGION(region_id)
);
GO

/*
------------------------------------------------------------
                    DIM_UBICACION
------------------------------------------------------------
*/

CREATE TABLE DIM_UBICACION (
    location_id    INT           NOT NULL,
    warehouse_id    INT           NULL,
    warehouse_name  VARCHAR(255)  NULL,
    city            VARCHAR(50)   NULL,
    state           VARCHAR(50)   NULL,
    postal_code     VARCHAR(20)   NULL,
    address         VARCHAR(255)  NULL,
    country_id         CHAR(2)       NOT NULL,
    CONSTRAINT PK_DIM_UBICACION   PRIMARY KEY (location_id),
    CONSTRAINT FK_UBIC_COUNTRY       FOREIGN KEY (country_id)
        REFERENCES DIM_COUNTRY(country_id)
);
GO

/*
============================================================
                    TABLA DE HECHOS
                    FACT_VENTAS
============================================================
*/
CREATE TABLE FACT_VENTAS (
    venta_id        BIGINT IDENTITY(1,1) NOT NULL,
    producto_id     INT            NOT NULL,
    tiempo_id       DATE           NOT NULL,
    location_id    INT            NOT NULL,
    cantidad        DECIMAL(8,2)   NOT NULL,
    precio_unitario DECIMAL(8,2)   NOT NULL,
    costo_estandar  DECIMAL(9,2)   NOT NULL,
    ingreso_total   DECIMAL(12,2)  NOT NULL,   -- cantidad * precio_unitario
    costo_total     DECIMAL(12,2)  NOT NULL,   -- cantidad * costo_estandar
    ganancia        DECIMAL(12,2)  NOT NULL,   -- cantidad * (precio_unitario - costo_estandar)
    CONSTRAINT PK_FACT_VENTAS  PRIMARY KEY (venta_id),
    CONSTRAINT FK_FACT_PROD    FOREIGN KEY (producto_id)
        REFERENCES DIM_PRODUCTO(producto_id),
    CONSTRAINT FK_FACT_TIEMPO  FOREIGN KEY (tiempo_id)
        REFERENCES DIM_TIEMPO(tiempo_id),
    CONSTRAINT FK_FACT_UBIC    FOREIGN KEY (location_id)
        REFERENCES DIM_UBICACION(location_id)
);
GO