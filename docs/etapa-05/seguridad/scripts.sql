/* =========================================================================
   ETAPA V - TEMA 4: MANEJO DE PERMISOS A NIVEL DE USUARIOS Y ROLES
   Proyecto: Farmacia Sana-Sana (Equipo 43)
   Motor: SQL Server 2019 / 2022 (Express)

   SCRIPT DE IMPLEMENTACIÓN
   Requiere el Tema 1 (usa el procedimiento dbo.sp_InsertarProducto).
   Las pruebas de cada caso están en demostracion_seguridad.sql.

   Contenido (sigue el orden de la consigna):
     0. Verificar que el servidor esté en MODO MIXTO de autenticación
     1. Permisos a nivel de USUARIOS
          usr_admin   -> administrador de la base (rol fijo db_owner)
          usr_lector  -> solo lectura (rol fijo db_datareader)
                         + EXECUTE sobre sp_InsertarProducto
     2. Permisos a nivel de ROLES
          rol_consulta_catalogo -> rol creado por nosotros: SOLO lectura de
                                   Producto y Proveedor
          usr_consulta_con_rol  -> es miembro del rol
          usr_consulta_sin_rol  -> NO es miembro de ningún rol

   Las contraseñas son de ejemplo (cumplen la política de Windows).
   ========================================================================= */

/* =========================================================================
   0. MODO DE AUTENTICACIÓN
   SQL Server tiene dos modos:
     - Solo Windows: únicamente se entra con una cuenta de Windows.
     - Mixto (Windows + SQL Server): además se pueden crear LOGINS con
       usuario y contraseña propios del motor. Es el que necesitamos.

   SERVERPROPERTY('IsIntegratedSecurityOnly'):
     1 = solo Windows   -> hay que cambiarlo
     0 = modo mixto     -> correcto

   Cómo cambiarlo si da 1 (SSMS):
     clic derecho sobre el servidor > Propiedades > Seguridad >
     "Modo de autenticación de SQL Server y de Windows" > Aceptar,
     y REINICIAR el servicio (clic derecho sobre el servidor > Reiniciar).
   ========================================================================= */
USE master;
GO

SELECT CASE SERVERPROPERTY('IsIntegratedSecurityOnly')
           WHEN 1 THEN 'Solo autenticación de Windows: cambiar a modo mixto'
           WHEN 0 THEN 'Modo mixto (Windows + SQL Server): correcto'
       END AS modo_autenticacion;
GO

/* =========================================================================
   1. PERMISOS A NIVEL DE USUARIOS
   Primero se crea el LOGIN (nivel servidor: permite conectarse a la
   instancia) y después el USUARIO (nivel base: permite entrar a
   Farmacia_SanaSana). Un login sin usuario no puede usar la base.
   ========================================================================= */
IF SUSER_ID('login_admin') IS NULL
    CREATE LOGIN login_admin WITH PASSWORD = 'Admin#SanaSana2026',
         DEFAULT_DATABASE = Farmacia_SanaSana, CHECK_POLICY = ON;
IF SUSER_ID('login_lector') IS NULL
    CREATE LOGIN login_lector WITH PASSWORD = 'Lector#SanaSana2026',
         DEFAULT_DATABASE = Farmacia_SanaSana, CHECK_POLICY = ON;
GO

USE Farmacia_SanaSana;
GO

IF USER_ID('usr_admin')  IS NULL CREATE USER usr_admin  FOR LOGIN login_admin;
IF USER_ID('usr_lector') IS NULL CREATE USER usr_lector FOR LOGIN login_lector;
GO

-- 1.a Usuario ADMINISTRADOR de la base.
--     db_owner es un rol fijo de SQL Server: puede hacer TODO dentro de
--     esta base (leer, escribir, crear tablas, dar permisos...).
ALTER ROLE db_owner ADD MEMBER usr_admin;
GO

-- 1.b Usuario de SOLO LECTURA.
--     db_datareader es un rol fijo: da SELECT sobre todas las tablas y
--     vistas de la base, y nada más (ni INSERT, ni UPDATE, ni DELETE).
ALTER ROLE db_datareader ADD MEMBER usr_lector;
GO

-- 1.c Permiso de EJECUCIÓN sobre el procedimiento creado en el Tema 1.
--     El usuario NO puede insertar en Producto, pero SÍ puede ejecutar el
--     procedimiento que inserta (ver "encadenamiento de propiedad" en
--     investigacion.md).
GRANT EXECUTE ON dbo.sp_InsertarProducto TO usr_lector;
GO

/* =========================================================================
   2. PERMISOS A NIVEL DE ROLES
   Un ROL es un grupo de permisos con nombre. Se dan los permisos al rol
   una sola vez y después se agregan o quitan usuarios. Si mañana entra
   otro empleado de consulta, alcanza con un ALTER ROLE ... ADD MEMBER.
   ========================================================================= */
USE master;
GO

IF SUSER_ID('login_consulta_con_rol') IS NULL
    CREATE LOGIN login_consulta_con_rol WITH PASSWORD = 'Consulta1#SanaSana2026',
         DEFAULT_DATABASE = Farmacia_SanaSana, CHECK_POLICY = ON;
IF SUSER_ID('login_consulta_sin_rol') IS NULL
    CREATE LOGIN login_consulta_sin_rol WITH PASSWORD = 'Consulta2#SanaSana2026',
         DEFAULT_DATABASE = Farmacia_SanaSana, CHECK_POLICY = ON;
GO

USE Farmacia_SanaSana;
GO

IF USER_ID('usr_consulta_con_rol') IS NULL CREATE USER usr_consulta_con_rol FOR LOGIN login_consulta_con_rol;
IF USER_ID('usr_consulta_sin_rol') IS NULL CREATE USER usr_consulta_sin_rol FOR LOGIN login_consulta_sin_rol;
GO

-- 2.a Rol que SOLO permite leer algunas tablas: el catálogo de productos
--     y los proveedores (lo que necesita, por ejemplo, un empleado que
--     atiende consultas de precios y disponibilidad).
IF DATABASE_PRINCIPAL_ID('rol_consulta_catalogo') IS NULL
    CREATE ROLE rol_consulta_catalogo;
GO

GRANT SELECT ON dbo.Producto  TO rol_consulta_catalogo;
GRANT SELECT ON dbo.Proveedor TO rol_consulta_catalogo;
GO

-- 2.b Solo UNO de los dos usuarios recibe el rol.
--     usr_consulta_sin_rol queda sin ningún permiso: puede conectarse a la
--     base pero no puede leer ninguna tabla.
ALTER ROLE rol_consulta_catalogo ADD MEMBER usr_consulta_con_rol;
GO

/* =========================================================================
   3. VERIFICACIÓN: qué permisos quedaron configurados
   ========================================================================= */
-- Miembros de cada rol
SELECT m.name AS usuario, r.name AS rol
FROM sys.database_role_members AS rm
JOIN sys.database_principals  AS r ON r.principal_id = rm.role_principal_id
JOIN sys.database_principals  AS m ON m.principal_id = rm.member_principal_id
WHERE m.name IN ('usr_admin', 'usr_lector', 'usr_consulta_con_rol', 'usr_consulta_sin_rol')
ORDER BY usuario;

-- Permisos otorgados directamente a usuarios y roles
SELECT pr.name            AS a_quien,
       pe.state_desc      AS estado,
       pe.permission_name AS permiso,
       OBJECT_NAME(pe.major_id) AS objeto
FROM sys.database_permissions AS pe
JOIN sys.database_principals  AS pr ON pr.principal_id = pe.grantee_principal_id
WHERE pr.name IN ('usr_lector', 'rol_consulta_catalogo')
  AND pe.class = 1           -- permisos sobre objetos (tablas, procedimientos)
ORDER BY a_quien, objeto;
GO
