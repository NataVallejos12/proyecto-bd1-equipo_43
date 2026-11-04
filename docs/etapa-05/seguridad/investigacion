
# Etapa V — Tema 4: Manejo de permisos a nivel de usuarios y roles

Proyecto Farmacia Sana-Sana — Equipo 43 — Bases de Datos I (UNNE)
Motor: SQL Server (T-SQL)

## 1. Definición y objetivo

La seguridad de una base de datos controla quién puede conectarse y qué operaciones puede hacer. SQL Server la maneja en dos niveles:

- **Login (inicio de sesión):** nivel servidor. Permite conectarse a la instancia. Puede ser una cuenta de Windows o un usuario y contraseña propios de SQL Server.
- **Usuario:** nivel base de datos. Se asocia a un login y permite entrar a una base concreta. Un login sin usuario no puede usar la base.

Los permisos (`GRANT`, `DENY`, `REVOKE`) se asignan directamente a un usuario o a un **rol**, que es un grupo de permisos con nombre. El objetivo es aplicar el **principio de mínimo privilegio**: cada persona puede hacer solo lo que su tarea necesita.

## 2. Ventajas y aplicaciones

- Protegen la información sensible, como los datos personales de clientes y las ventas.
- Evitan modificaciones accidentales o no autorizadas, por ejemplo un cambio de precios.
- Permiten asignar responsabilidades según el perfil: administrador, vendedor o empleado de consultas.
- Los roles simplifican la administración: los permisos se definen una vez y después solo se agregan o quitan usuarios.
- Combinados con procedimientos almacenados, permiten que un usuario haga una operación controlada sin tener acceso directo a la tabla.

## 3. Implementación en SQL Server

Script de implementación: [`sql/tecnico/seguridad/seguridad.sql`](../../../sql/tecnico/seguridad/seguridad.sql)

### Modo de autenticación

SQL Server puede trabajar en modo **solo Windows** o en **modo mixto** (Windows y SQL Server). Para crear usuarios con contraseña propia del motor se necesita el modo mixto. Se verifica con `SERVERPROPERTY('IsIntegratedSecurityOnly')`: 1 es solo Windows y 0 es modo mixto. Se cambia en Propiedades del servidor, Seguridad, y requiere reiniciar el servicio.

### Permisos a nivel de usuarios

| Login / usuario | Permisos |
|---|---|
| `login_admin` / `usr_admin` | Rol fijo `db_owner`: puede hacer todo dentro de la base |
| `login_lector` / `usr_lector` | Rol fijo `db_datareader`: solo lectura de todas las tablas. Además, `GRANT EXECUTE` sobre `dbo.sp_InsertarProducto` (Tema 1) |

**Encadenamiento de propiedad (ownership chaining):** cuando un procedimiento y la tabla que usa tienen el mismo dueño (`dbo`), SQL Server verifica solo el permiso `EXECUTE` sobre el procedimiento y no vuelve a verificar el `INSERT` sobre la tabla. Por eso el usuario de solo lectura no puede insertar directamente, pero sí a través del procedimiento, que además aplica las reglas de negocio.

### Permisos a nivel de roles

| Elemento | Configuración |
|---|---|
| `rol_consulta_catalogo` | Rol creado por el equipo: `GRANT SELECT` sobre `Producto` y `Proveedor` |
| `usr_consulta_con_rol` | Miembro del rol |
| `usr_consulta_sin_rol` | Sin rol ni permisos |

### Cómo se prueba

La demostración se ejecuta como administrador y usa `EXECUTE AS LOGIN` para actuar como cada usuario, y `REVERT` para volver. Cada intento que debe fallar está dentro de `TRY/CATCH` para mostrar el error del motor. Al final, `fn_my_permissions` muestra los permisos efectivos de cada usuario.

Script de demostración: [`sql/tecnico/seguridad/demostracion_seguridad.sql`](../../../sql/tecnico/seguridad/demostracion_seguridad.sql)

## 4. Caso concreto en el sistema de ventas

- El **administrador** de la farmacia gestiona toda la base.
- Un **empleado de carga** puede consultar datos y dar de alta productos, pero solo a través de `sp_InsertarProducto`, que valida precio, stock y nombre. No puede insertar directamente ni borrar productos.
- Un **empleado de consultas** atiende preguntas de precios y disponibilidad: puede leer el catálogo de productos y los proveedores, pero no ve las ventas ni puede modificar precios.

## 5. Requisitos para ejecutar

- SQL Server 2016 SP1 o posterior (las pruebas se ejecutaron en SQL Server 2025, versión 17.0), configurado en **modo mixto**.
- SQL Server Management Studio (SSMS) para ejecutar los scripts y ver los resultados.
- Una cuenta con permisos de administrador del servidor: la implementación crea logins y la demostración usa `EXECUTE AS LOGIN`.
- No se necesita instalar nada adicional: los permisos y roles son parte de SQL Server.

Orden de ejecución:

1. `00_crear_bd_corregido.sql`: crea la base y las tablas.
2. `LoteCarga_Farmacia.sql`: carga los datos de prueba.
3. Implementación del Tema 1 (procedimientos y funciones): se usan `sp_InsertarProducto` y `sp_BorrarProducto`.
4. `sql/tecnico/seguridad/seguridad.sql`: crea logins, usuarios, el rol y los permisos.
5. `sql/tecnico/seguridad/demostracion_seguridad.sql`: se ejecuta por partes, con la limpieza al final.

## 6. Demostración y resultados

| Prueba | Usuario | Operación | Resultado esperado |
|---|---|---|---|
| 0 | Administrador | Verificar modo de autenticación | Modo mixto |
| 1.1 | `usr_admin` y `usr_lector` | `SELECT` sobre Producto | Ambos ven los 12 productos |
| 1.2 | `usr_admin` | `INSERT` directo en Producto | Permitido |
| 1.3 | `usr_lector` | `INSERT` directo en Producto | Denegado (error 229) |
| 1.4 | `usr_lector` | `INSERT` mediante `sp_InsertarProducto` | Permitido |
| 1.5 | `usr_lector` | `sp_InsertarProducto` con precio negativo | Rechazado por la regla de negocio (error 50001) |
| 1.6 | `usr_lector` | `EXEC sp_BorrarProducto` | Denegado (error 229) |
| 2.1 | `usr_consulta_con_rol` | `SELECT` sobre Producto | Permitido |
| 2.2 | `usr_consulta_sin_rol` | `SELECT` sobre Producto | Denegado (error 229) |
| 2.3 | `usr_consulta_con_rol` | `SELECT` sobre Venta | Denegado: la tabla no está en el rol |
| 2.4 | `usr_consulta_con_rol` | `UPDATE` sobre Producto | Denegado: el rol es de solo lectura |
| 2.5 | `usr_consulta_sin_rol` agregado al rol | `SELECT` sobre Producto | Permitido sin repetir los `GRANT` |

### Configuración de usuarios, roles y permisos
Modo mixto activo, usuarios con su rol y permisos otorgados.

![Configuración](evidencias/seguridad1_configuracion.jpeg)

### Parte 1 — Permisos a nivel de usuarios
Mensajes de las pruebas 1.2 a 1.6:

![Mensajes de la parte 1](evidencias/seguridad2_usuarios_mensajes.jpeg)

Ambos usuarios leen los 12 productos; quedan insertados el 9001 (admin, directo) y el 9002 (lector, por procedimiento):

![Resultados de la parte 1](evidencias/seguridad3_usuarios_resultados.jpeg)

### Parte 2 — Permisos a nivel de roles
Mensajes de las pruebas 2.1 a 2.5:

![Mensajes de la parte 2](evidencias/seguridad4_roles_mensajes.jpeg)

El usuario con rol lee los productos; al agregar al segundo usuario al rol, ve los 14 productos (12 + los 2 de prueba):

![Resultados de la parte 2](evidencias/seguridad5_roles_resultados.jpeg)

### Permisos efectivos de cada usuario

![Permisos efectivos](evidencias/seguridad6_permisos_efectivos.jpeg)

## 7. Conclusiones

1. El login permite conectarse al servidor y el usuario permite entrar a la base: se necesitan los dos.
2. Los roles fijos aplican el mínimo privilegio sin dar permisos uno por uno: `db_owner` puede todo y `db_datareader` solo leer (pruebas 1.2 y 1.3).
3. Un procedimiento almacenado funciona como una puerta controlada: el usuario de solo lectura no puede insertar directamente, pero sí a través del procedimiento (1.3 y 1.4), que sigue aplicando las reglas de negocio (1.5). El permiso `EXECUTE` es por procedimiento, no general (1.6).
4. Con un rol, el usuario miembro puede leer la tabla y el que no es miembro no (2.1 y 2.2). El rol limita tanto las tablas (2.3) como las operaciones (2.4), y dar el mismo acceso a otro usuario solo requiere agregarlo al rol (2.5).
5. El modo mixto es necesario para que los usuarios de SQL Server puedan conectarse con su contraseña. `EXECUTE AS` permite probarlos desde la cuenta del administrador.
6. Al ejecutar los scripts, los resultados coincidieron con los esperados en todas las pruebas, y al final se ejecutó la limpieza para dejar la base como estaba.
