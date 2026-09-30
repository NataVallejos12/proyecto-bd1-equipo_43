USE Farmacia_SanaSana;
GO

-- PERSONA (18): 10 clientes + 8 vendedores
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
