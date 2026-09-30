--El siguiente archivo consistira en la implementación en sql--
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

CREATE TABLE Cliente(
  dni INT NOT NULL,
  direccion VARCHAR(200) NOT NULL,
  CONSTRAINT PK_CLIENTE PRIMARY KEY (dni),
  CONSTRAINT FK_CLIENTE_PERSONA FOREIGN KEY (dni) REFERENCES Persona(dni)
);

CREATE TABLE Vendedor(
  cod_vendedor INT NOT NULL,
  dni INT NOT NULL,
  CONSTRAINT PK_VENDEDOR PRIMARY KEY (cod_vendedor),
  CONSTRAINT UQ_vendedor_dni UNIQUE (dni),
  CONSTRAINT FK_VENDEDOR_PERSONA FOREIGN KEY (dni) REFERENCES Persona(dni)
);

CREATE TABLE Venta(
  cod_venta INT NOT NULL,
  fecha_venta DATE NOT NULL,
  metodo_pago VARCHAR(50) NOT NULL,
  nro_receta VARCHAR(50) NULL, 
  cod_vendedor INT NOT NULL,
  dni INT NOT NULL,
  CONSTRAINT PK_VENTA PRIMARY KEY (cod_venta),
  CONSTRAINT UQ_nro_receta UNIQUE (nro_receta),
  CONSTRAINT ck_venta_metodo_pago CHECK (metodo_pago IN (
        'Efectivo', 'Tarjeta de débito', 'Tarjeta de crédito', 'Transferencia',
        'Mercado Pago', 'Código QR', 'Obra social', 'Cuenta corriente')),
  CONSTRAINT FK_VENTA_VENDEDOR FOREIGN KEY (cod_vendedor) REFERENCES Vendedor(cod_vendedor),
  CONSTRAINT FK_VENTA_CLIENTE FOREIGN KEY (dni) REFERENCES Cliente(dni)
);

CREATE TABLE Detalle_venta(
  cod_venta INT NOT NULL,
  linea_venta INT NOT NULL,
  cod_producto INT NOT NULL,
  cant_comprada INT NOT NULL,
  precio_unitario DECIMAL(10, 2) NOT NULL,
  CONSTRAINT PK_DETALLE_VENTA PRIMARY KEY (cod_venta, linea_venta),
  CONSTRAINT ck_detalle_cantidad CHECK (cant_comprada > 0),
  CONSTRAINT ck_detalle_precio   CHECK (precio_unitario > 0),
  CONSTRAINT FK_DETALLE_VENTA_VENTA FOREIGN KEY (cod_venta) REFERENCES Venta(cod_venta),
  CONSTRAINT FK_DETALLE_VENTA_PRODUCTO FOREIGN KEY (cod_producto) REFERENCES Producto(cod_producto)
);

CREATE TABLE Pedido(
  cod_pedido INT NOT NULL,
  fecha_pedido DATE NOT NULL,
  cantidad_entregada INT NOT NULL,
  cuit VARCHAR(20) NOT NULL,
  cod_producto INT NOT NULL,
  CONSTRAINT PK_PEDIDO PRIMARY KEY (cod_pedido),
  CONSTRAINT ck_pedido_cantidad CHECK (cantidad_entregada > 0),
  CONSTRAINT FK_PEDIDO_PROVEEDOR FOREIGN KEY (cuit) REFERENCES Proveedor(cuit),
  CONSTRAINT FK_PEDIDO_PRODUCTO FOREIGN KEY (cod_producto) REFERENCES Producto(cod_producto)
);
