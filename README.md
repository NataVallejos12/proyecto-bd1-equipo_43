
# Base Datos 1 Gr.43
Proyecto  Final de Base de Datos 1 Comision3 Gr.43.

## Integrantes

<!-- Completar con nombre, apellido y usuario de GitHub de cada integrante -->

| Nombre y Apellido | Usuario GitHub |
|---|---|
|       Medina Cristian David       | cristianmedinaa  |
|Quintana Flores Lautaro Sebastian  | lautaroflores31-dot |
|       RAMIREZ JOSE EMILIANO       | RamirezJoseEmiliano |
|          ROMANI VALENTINO         | valrom12 |
|  VALLEJOS AQUINO NATANIEL ADRIEL  | NataVAllejos12 |
---
## Presentacion y Contexto
Este proyecto Farmacia es un Sistema que esta diseño para facilitar la gestión y supervisión de ventas de medicamentos o productos de una farmacia

El sistema permitira al farmacéutico un uso eficiente a la base de datos farmacia implementando el manejo de tablas.Para  administrar la comercialización de productos y vencimientos, así como el proceso de reabastecimiento de stock.

---
## Problemática
Uno de los principales problemas identificados en la Farmacia Sana-Sana es la dificultad para mantener un control preciso y actualizado del stock y de los lotes de los productos. Los productos pueden tener distintos orígenes y destinos: ingresan al inventario a través de los pedidos a proveedores y salen mediante las ventas a clientes.

La falta de un registro integrado puede generar diferencias entre el inventario físico y el registrado. Esto provoca problemas al momento de realizar nuevas ventas, al no saber con certeza qué cantidad hay disponible y de qué lote. También aumenta el riesgo de no reponer a tiempo los productos con poco stock y de vender productos vencidos.

A esto se suma la necesidad de controlar las ventas de medicamentos que requieren receta, y de conservar el precio al que se vendió cada producto, ya que el precio de lista puede cambiar con el tiempo.

### Solución propuesta

La Farmacia Sana-Sana propone centralizar el registro de las operaciones de venta y de reabastecimiento. De este modo se controlan los movimientos de inventario y se actualizan las cantidades disponibles como consecuencia de cada operación: el stock se descuenta del lote correspondiente con cada venta y se suma cuando se recibe un pedido de un proveedor.

El sistema define un punto de reorden: cuando el stock de un producto llega a 5 unidades o menos, se genera un nuevo pedido de compra al proveedor. Esto evita quedarse sin mercadería y reduce la venta de productos vencidos.

Además, el sistema conserva el precio unitario de cada producto al momento de realizar la venta, evitando que modificaciones posteriores en el precio de lista afecten el historial de operaciones anteriores. También registra el número de receta en las ventas de productos que lo requieren, lo que permite controlar la venta bajo receta.

---

## Alcance del Sistema 
El sistema farmacia podra gestionar :
| Area | Funcionalidad |
|---|---|
|     Personas     |Registro y diferenciación de Clientes y Vendedore  |
| Inventario y Catálogo  | Administracion de productos y Seguimiento de stock |
|     Ventas    |Registro ,Manejo y Control de ventas de medicamento bajo receta |
|     Proveedores y Compras    | Mantenimiento de Informacion y Generacion de pedidos |

---

```
proyecto-bd1-equipo-43/
│<br>
├──  📁 docs/<br>
│   ├── 📁  etapa-01/<br>
│   │  ├──📄  [Descripción del caso](docs/etapa-01/descripcion-caso.md)<br>
│   │  ├──📄  [Reglas de Negocio](docs/etapa-01/reglas-negocio.md)<br>
│   ├── 📁 etapa-02/<br>
│   │  ├──📄  [Diagrama Entidad-Relación (DER)](docs/etapa-02/der/der.png)<br>
│   │  ├──📄  [Modelo Relacional](docs/etapa-02/modelo-relacional.md)<br>
│   │  ├──📄  [Normalización](docs/etapa-02/normalizacion.md)<br>
│   ├── 📁  etapa-03/<br>
│   │  ├──📄  [Script DDL](sql/ddl/crear_bd.sql)<br>
│   │  ├──📄  [Script DML](sql/dml/datos_prueba.sql) <br>
│   ├── 📁  etapa-04/<br>
│   │  ├──📄  [Comprobante de Venta](sql/consultas/comprobante_venta.sql)<br>
│   │  ├──📄  [Consulta de Negocio Avanzada](sql/consultas/consulta_avanzada.sql) <br>
│   │  ├──📄  [Informe de Venta](sql/consultas/informe_ventas.sql)<br>
│   └── 📁  etapa-05/<br>
│   │  ├──📄  Descripción breve<br>
│   │  ├──📄 Script SQL de implementación<br>
│   │  ├──📄 Script SQL o resumen explicativo<br>
│   │  ├──📄 Temas técnicos<br>
│<br>
├── 📁  sql/<br>
│   ├── 📁 ddl/<br>
│   ├────📄  [Crear BD](sql/ddl/crear_bd.sql)<br>
│   ├── 📁 dml/<br>
│   ├────📄 [Datos de Prueba](sql/dml/datos_prueba.sql)<br>
│   └── tecnico/<br>
│<br>
└──📄 README.md
```
