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
