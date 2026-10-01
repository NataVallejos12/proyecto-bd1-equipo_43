--Aquí se realizará la población inicial de la Farmacia--
USE Farmacia_SanaSana;
GO

-- PERSONA (18): 10 clientes + 8 vendedores.
INSERT INTO Persona (dni, nombres, apellidos, correo, telefono_persona, fecha_nacimiento) VALUES
(40111001, 'María Belén', 'Gómez', 'mbelen.gomez@mail.com', '3624100001', '1990-03-14'),
(40111002, 'Lucas', 'Fernández', 'lucas.fernandez@mail.com', '3624100002', '1985-07-22'),
(40111003, 'Sofía', 'Ramírez', 'sofia.ramirez@mail.com', '3624100003', '1998-11-05'),
(40111004, 'Martín', 'Acosta', 'martin.acosta@mail.com', '3624100004', '1976-01-30'),
(40111005, 'Camila', 'Benítez', 'camila.benitez@mail.com', '3624100005', '2001-09-18'),
(40111006, 'Diego', 'Sánchez', 'diego.sanchez@mail.com', '3624100006', '1969-12-02'),
(40111007, 'Valentina', 'Ortiz', 'valen.ortiz@mail.com', '3624100007', '1994-05-27'),
(40111008, 'Joaquín', 'Villalba', 'joaquin.villalba@mail.com', '3624100008', '1988-08-09'),
(40111009, 'Agustina', 'Romero', 'agus.romero@mail.com', '3624100009', '1959-04-16'),
(40111010, 'Nicolás', 'Duarte', 'nico.duarte@mail.com', '3624100010', '1992-10-11'),
(30222001, 'Carolina', 'Molina', 'carolina.molina@sanasana.com', '3624200001', '1987-02-19'),
(30222002, 'Federico', 'Pereyra', 'federico.pereyra@sanasana.com', '3624200002', '1991-06-03'),
(30222003, 'Lucía', 'Cabrera', 'lucia.cabrera@sanasana.com', '3624200003', '1995-12-24'),
(30222004, 'Andrés', 'Núñez', 'andres.nunez@sanasana.com', '3624200004', '1983-09-07'),
(30222005, 'Florencia', 'Ledesma', 'flor.ledesma@sanasana.com', '3624200005', '1997-01-15'),
(30222006, 'Gustavo', 'Insaurralde', 'gustavo.insa@sanasana.com', '3624200006', '1980-05-29'),
(30222007, 'Paula', 'Medina', 'paula.medina@sanasana.com', '3624200007', '1993-03-21'),
(30222008, 'Ramiro', 'Godoy', 'ramiro.godoy@sanasana.com', '3624200008', '1989-11-13');
GO

-- CLIENTE (10)
INSERT INTO Cliente (dni, direccion) VALUES
(40111001, 'Av. 25 de Mayo 1250, Resistencia'),
(40111002, 'Juan B. Justo 340, Resistencia'),
(40111003, 'Los Pinos 88, Barranqueras'),
(40111004, 'Av. Sarmiento 2100, Resistencia'),
(40111005, 'Perón 765, Resistencia'),
(40111006, 'Güemes 412, Fontana'),
(40111007, 'Av. Alberdi 1590, Resistencia'),
(40111008, 'Mitre 230, Barranqueras'),
(40111009, 'San Martín 980, Resistencia'),
(40111010, 'Belgrano 615, Puerto Vilelas');
GO

-- VENDEDOR (8)
INSERT INTO Vendedor (cod_vendedor, dni) VALUES
(1, 30222001),
(2, 30222002),
(3, 30222003),
(4, 30222004),
(5, 30222005),
(6, 30222006),
(7, 30222007),
(8, 30222008);
GO

-- PRODUCTO (12): stock = stock actual de cada producto.
INSERT INTO Producto (cod_producto, nombre_producto, descripcion, categoria, precio_unitario, stock, lote) VALUES
(1, 'Ibuprofeno 400 mg', 'Caja x 20 comprimidos, antiinflamatorio', 'Analgésicos', 2850.00, 61, 'L2601A'),
(2, 'Paracetamol 500 mg', 'Caja x 16 comprimidos, analgésico', 'Analgésicos', 1900.00, 98, 'L2601B'),
(3, 'Amoxicilina 500 mg', 'Caja x 21 cápsulas, antibiótico', 'Antibióticos', 6400.00, 39, 'L2602A'),
(4, 'Omeprazol 20 mg', 'Caja x 28 cápsulas, protector gástrico', 'Digestivos', 4200.00, 47, 'L2602B'),
(5, 'Loratadina 10 mg', 'Caja x 10 comprimidos, antialérgico', 'Antialérgicos', 2300.00, 51, 'L2603A'),
(6, 'Alcohol en gel 250 ml', 'Antiséptico de manos', 'Higiene', 1750.00, 97, 'L2603B'),
(7, 'Protector solar FPS 50', 'Crema facial y corporal 120 ml', 'Dermocosmética', 9800.00, 21, 'L2604A'),
(8, 'Vitamina C 1 g', 'Tubo x 10 comprimidos efervescentes', 'Suplementos', 3100.00, 58, 'L2604B'),
(9, 'Jarabe para la tos', 'Frasco 120 ml, expectorante', 'Respiratorios', 3650.00, 68, 'L2605A'),
(10, 'Termómetro digital', 'Termómetro clínico con estuche', 'Insumos', 5200.00, 34, 'L2605C'),
(11, 'Gasas estériles 10x10', 'Sobre x 10 unidades', 'Insumos', 980.00, 149, 'L2605B'),
(12, 'Enalapril 10 mg', 'Caja x 30 comprimidos, antihipertensivo', 'Cardiovasculares', 3900.00, 38, 'L2606A');
GO

-- PROVEEDOR (8)
INSERT INTO proveedor (cuit, nombre, razon_social, direccion, telefono_proveedor, tipo_proveedor) VALUES
('30712345671', 'Droguería del Norte',  'Droguería del Norte S.R.L.',   'Ruta 11 km 5, Resistencia',      '3624300001', 'Droguería'),
('30712345682', 'FarmaLitoral',         'FarmaLitoral S.A.',            'Av. Alvear 1450, Corrientes',    '3794300002', 'Droguería'),
('30712345693', 'Laboratorios Andina',  'Laboratorios Andina S.A.',     'Parque Industrial, Rosario',     '3414300003', 'Laboratorio'),
('30712345704', 'BioSalud',             'BioSalud Argentina S.R.L.',    'Av. Corrientes 3200, CABA',      '1143000004', 'Laboratorio'),
('30712345715', 'DermaCare',            'DermaCare Cosméticos S.A.',    'Av. Cabildo 2500, CABA',         '1143000005', 'Dermocosmética'),
('30712345726', 'Insumos Médicos NEA',  'Insumos Médicos NEA S.R.L.',   'Av. Chaco 900, Resistencia',     '3624300006', 'Insumos'),
('30712345737', 'VitaPlus',             'VitaPlus Suplementos S.A.',    'Ruta 9 km 12, Córdoba',          '3514300007', 'Suplementos'),
('30712345748', 'Distribuidora Guaraní','Distribuidora Guaraní S.A.',   'Av. Uriburu 720, Posadas',       '3764300008', 'Droguería');
GO

-- PEDIDO (10)
INSERT INTO Pedido (cod_pedido, fecha_pedido, cantidad_entregada, cuit, cod_producto) VALUES
(1, '2026-08-05', 60, '30712345671', 1),
(2, '2026-08-06', 100, '30712345671', 2),
(3, '2026-08-12', 40, '30712345693', 3),
(4, '2026-08-14', 50, '30712345682', 4),
(5, '2026-08-20', 50, '30712345704', 5),
(6, '2026-08-22', 100, '30712345726', 6),
(7, '2026-08-25', 20, '30712345715', 7),
(8, '2026-09-02', 60, '30712345737', 8),
(9, '2026-09-09', 150, '30712345726', 11),
(10, '2026-09-16', 40, '30712345748', 12);
GO

-- VENTA (12): 12 ventas realizadas en diferentes fechas.
INSERT INTO Venta (cod_venta, fecha_venta, metodo_pago, nro_receta, cod_vendedor, dni) VALUES
(1, '2026-09-01', 'Efectivo', NULL, 1, 40111001),
(2, '2026-09-02', 'Tarjeta de débito', NULL, 2, 40111002),
(3, '2026-09-03', 'Obra social', 'REC-0001', 3, 40111009),
(4, '2026-09-05', 'Tarjeta de crédito', NULL, 1, 40111003),
(5, '2026-09-08', 'Mercado Pago', NULL, 4, 40111004),
(6, '2026-09-10', 'Transferencia', 'REC-0002', 5, 40111006),
(7, '2026-09-12', 'Efectivo', NULL, 2, 40111005),
(8, '2026-09-15', 'Código QR', NULL, 6, 40111007),
(9, '2026-09-17', 'Obra social', 'REC-0003', 3, 40111008),
(10, '2026-09-20', 'Cuenta corriente', NULL, 7, 40111010),
(11, '2026-09-24', 'Tarjeta de débito', NULL, 8, 40111001),
(12, '2026-09-28', 'Tarjeta de crédito', 'REC-0004', 1, 40111004);
GO

-- DETALLE_VENTA (26): linea_venta cuenta desde 1 dentro de cada venta.
INSERT INTO Detalle_venta (cod_venta, linea_venta, cod_producto, cant_comprada, precio_unitario) VALUES
(1, 1, 2, 2, 1800.00),
(1, 2, 6, 1, 1750.00),
(2, 1, 1, 1, 2700.00),
(2, 2, 11, 3, 980.00),
(3, 1, 3, 1, 6400.00),
(3, 2, 4, 1, 4000.00),
(4, 1, 5, 2, 2300.00),
(4, 2, 8, 1, 3100.00),
(5, 1, 7, 1, 9800.00),
(5, 2, 6, 2, 1750.00),
(6, 1, 12, 2, 3800.00),
(6, 2, 2, 1, 1900.00),
(7, 1, 9, 1, 3500.00),
(7, 2, 8, 2, 3100.00),
(8, 1, 10, 1, 5200.00),
(8, 2, 11, 2, 980.00),
(9, 1, 3, 2, 6200.00),
(9, 2, 1, 1, 2850.00),
(9, 3, 4, 1, 4200.00),
(10, 1, 2, 3, 1900.00),
(10, 2, 5, 1, 2300.00),
(11, 1, 7, 1, 9800.00),
(11, 2, 8, 1, 3100.00),
(12, 1, 12, 1, 3900.00),
(12, 2, 4, 2, 4200.00),
(12, 3, 9, 1, 3650.00);
GO

Pruebas de restricciones (todas deben fallar)

-- 1. Método de pago inválido
INSERT INTO Venta (cod_venta, fecha_venta, metodo_pago, cod_vendedor, dni)
VALUES (99, '2026-09-30', 'Bitcoin', 1, 40111001);

-- 2. Lote repetido
INSERT INTO Producto (cod_producto, descripcion, categoria, precio_unitario, nombre_producto, stock, lote)
VALUES (99, 'x', 'y', 1, 'x', 1, 'L2601A');

-- 3. Número de receta repetido
INSERT INTO Venta (cod_venta, fecha_venta, metodo_pago, nro_receta, cod_vendedor, dni)
VALUES (99, '2026-09-30', 'Efectivo', 'REC-0001', 1, 40111001);

-- 4. Producto inexistente en el detalle
INSERT INTO Detalle_venta (cod_venta, linea_venta, cod_producto, cant_comprada, precio_unitario)
VALUES (1, 9, 999, 1, 10);

-- 5. Número de línea repetido dentro de la misma venta
INSERT INTO Detalle_venta (cod_venta, linea_venta, cod_producto, cant_comprada, precio_unitario)
VALUES (1, 1, 3, 1, 100);

-- 6. Persona cargada dos veces como vendedor
INSERT INTO Vendedor (cod_vendedor, dni) VALUES (99, 30222001);

-- 7. Stock negativo
UPDATE Producto SET stock = -1 WHERE cod_producto = 1;

-- 8. Borrar un cliente que tiene ventas
DELETE FROM Cliente WHERE dni = 40111001;
```

| Prueba | Restricción | Resultado esperado |
|---|---|---|
| 1 | ck_venta_metodo_pago | Conflicto con la restricción CHECK |
| 2 | UQ_lote | Violación de la restricción UNIQUE KEY |
| 3 | UQ_nro_receta | Violación de la restricción UNIQUE KEY |
| 4 | FK_DETALLE_VENTA_PRODUCTO | Conflicto con la restricción FOREIGN KEY |
| 5 | PK_DETALLE_VENTA | Violación de la restricción PRIMARY KEY |
| 6 | UQ_vendedor_dni | Violación de la restricción UNIQUE KEY |
| 7 | ck_producto_stock | Conflicto con la restricción CHECK |
| 8 | FK_VENTA_CLIENTE | Conflicto con la restricción REFERENCE |
