# Normalizacion
---
## 1FN (Primera Forma Normal):
    Es el requisito fundamental para que una estructura de datos pueda considerarse una relación en el modelo relacional [1]. Una relación está en 1FN si y solo si: 
1. Cada celda de la tabla contiene un solo valor.
2. Todos sus atributos son atómicos (indivisibles).
3. No existen grupos repetitivos de atributos [1, 2]. 
    La 1era forma normal en la situacion de farmacia se ve en todas las tablas porque cada tabla tiene sus atributos atomicos y no hay grupos repetidos.
  Ejemplo:
DETALLE_VENTA: En vez de que VENTA tenga una columna con productos como si fuera una lista,se creo una tabla aparte donde cada fila representa un solo producto dentro de cada venta(cod_venta,cod_producto,cant_comprada,subtotal,precio_unitario).
---
## 2FN (Segunda Forma Normal):
    Para que una relacion este en Segunda Forma Normal (2FN) debe estar en 1FN y todos sus atributos no clave deben tener dependencia Funcional Completa de la clave primaria.Esto significa que no debe existir ninguna dependencia funcional parcial  en la que un subconjunto de la clave primaria determine un atributo no clave.
    Un ejemplo de 2FN es la misma tabla DETALLE_VENTA: Que tiene clave primaria compuesta {cod_venta,cod_producto}.Los atributos no clave (cant_comprada,subtotal,precio_unitario)dependen de la combinacion completa de ambos campos: Cant_Compradad y subtotal necesitan saber que venta y que producto y precio_unitario tambien porque puede variar segun cuando se hizo esa venta puntual
---
## 3FN (Tercera Forma Normal):
    Una relacion esta en Tercera Forma Normal (3FN) si esta en 2FN y no contiene dependencias funcionales transitiva.
Una dependencia transitiva se da cuando un atributo no clave depende de otro atributo no clave.
    En la situacion Farmacia la 3FN se ve en la relacion PERSONA/CLIENTE/VENDEDOR y en PRODUCTO/PROVEEDOR:
1.CLIENTE y VENDEDOR no repiten nombre,apellido,correo,telefono,fecha de nacimiento.Solo tienen el dni como FK (Clave Foranea) hacia PERSONA.
2.PEDIDO tiene como PK (clave primaria) cod_abastecimiento y en vez de guardar el nombre o direccion del proveedor (que dependen de cuit, no de cod_abastecimiento) o la descripcion/precio del producto (que dependen de cod_producto, no de cod_abastecimiento),solo guarda las FK cuit y cod_producto. 

