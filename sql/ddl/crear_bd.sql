CREATE DATABASE Farmacia_SanaSana;
GO 

USE Farmacia_SanaSana;
GO

CREATE TABLE Persona(
  dni INT NOT NULL,
  nombres VARCHAR(100) NOT NULL,
  apellidos VARCHAR(100) NOT NULL,
  correo VARCHAR(254) NOT NULL,
  telefono_persona VARCHAR(20) NOT NULL,
  fecha_nacimiento DATE NOT NULL,
  CONSTRAINT PK_PERSONA PRIMARY KEY (dni),
  CONSTRAINT UQ_correo UNIQUE (correo),
  CONSTRAINT UQ_telefono_persona UNIQUE (telefono_persona)
);

CREATE TABLE Producto(
  cod_producto INT NOT NULL,
  descripcion VARCHAR(250) NOT NULL,
  categoria VARCHAR(50) NOT NULL,
  precio_unitario DECIMAL(10, 2) NOT NULL, 
  nombre_producto VARCHAR(100) NOT NULL,
  stock INT NOT NULL,
  lote VARCHAR(50) NOT NULL, 
  CONSTRAINT PK_PRODUCTO PRIMARY KEY (cod_producto),
  CONSTRAINT UQ_lote UNIQUE (lote),
  CONSTRAINT ck_producto_precio CHECK (precio_unitario > 0),
  CONSTRAINT ck_producto_stock  CHECK (stock >= 0)
);

CREATE TABLE Proveedor(
  cuit VARCHAR(20) NOT NULL,
  nombre VARCHAR(100) NOT NULL,
  direccion VARCHAR(200) NOT NULL,
  telefono_proveedor VARCHAR(20) NOT NULL,
  razon_social VARCHAR(100) NOT NULL,
  tipo_proveedor VARCHAR(50) NOT NULL,
  CONSTRAINT PK_PROVEEDOR PRIMARY KEY (cuit),
  CONSTRAINT UQ_telefono_proveedor UNIQUE (telefono_proveedor)
);
