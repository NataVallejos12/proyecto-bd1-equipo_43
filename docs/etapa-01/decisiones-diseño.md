# Decisiones de Diseño
Durante el analisis del caso de estudio ,el grupo 43 tomo las siguientes decisiones de diseño para el modelado de la base de datos:

### 1. Especializacion de Persona
Se opto por utilizar una **jerarquia (especializacion)** para entidad "Persona".
* **Justificacion:** Las reglas de negocio establecen que toda persona registrada tiene atributos comun (DNI,Nombre,Apellido,etc),pero obligatoriamente debe asumir el rol de "Cliente" o "Vendedor" y bajo ninguna circunstancia puede ser ambos a la vez(disjunto).

### 2. Historico de Precios en Ventas
Se agrego el atributo "precio_unitario" en una entidad debil/interseccion "Detalle_Venta".
* **Justificacion:** El precio de los productos en las farmacias fluctua constantemente.Al registrar el precio en el detalle al momento de la transaccion,garantizamos que las consultas de ventas historicas no se alteren si el "precio_unitario" en la entidad "Producto" se actualiza.

### 3. Manejo de Recetas Medicas
El atributo "numero_receta" fue ubicado en la relacion del detalle de la venta (o en una entidad dependiente,segun la diagramacion especifica).
* **Justificacion:**  Es un atributo que solo tiene valor condicionado al tipo de producto que se esta vendiendo.Dejarlo a nivel de la cabecera de la "Venta" obligatoria a que toda la venta sea bajo receta,cuando en realidad una misma venta puede tener un analgesico de venta libre y un antibiotico con una receta.

### 4. Punto de pedido y Automatizacion
La regla que indica que un pedido de compra se realiza si el stock es "5 o menos" se modela conceptualmente pero requerira en el diseño fisico la imimplementacion de un **Trigger (Disparador)** o un procedimiento almacenado.
***Justificacion:** A nivel de modelo Entidad_Relacion, Solo documentamos la relacion entre "Producto" ,"Pedido" y "Proveedor".La logica de evaluacion matematica ("Stock <= 5") pertenece a la capa de reglas activas de la base de datos. 

