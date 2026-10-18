
# Base Datos 1 Gr.43
Proyecto  Final de Base de Datos 1 Comision3 Gr.43.

## 1_Integrantes

<!-- Completar con nombre, apellido y usuario de GitHub de cada integrante -->

| Nombre y Apellido | Usuario GitHub |
|---|---|
|       Medina Cristian David       | cristianmedinaa  |
|Quintana Flores Lautaro Sebastian  | lautaroflores31-dot |
|       RAMIREZ JOSE EMILIANO       | RamirezJoseEmiliano |
|          ROMANI VALENTINO         | valrom12 |
|  VALLEJOS AQUINO NATANIEL ADRIEL  | NataVAllejos12 |
---
## 2_Presentacion y Contexto
Este proyecto Farmacia es un Sistema que esta diseño para facilitar la gestión y supervisión de ventas de medicamentos o productos de una farmacia

El sistema permitira al farmacéutico un uso eficiente a la base de datos farmacia implementando el manejo de tablas.Para  administrar la comercialización de productos y vencimientos, así como el proceso de reabastecimiento de stock.

---
## 3_Problemática
Uno de los principales problemas identificados en la Farmacia Sana-Sana es la dificultad para mantener un control preciso y actualizado del stock y de los lotes de los productos. Los productos pueden tener distintos orígenes y destinos: ingresan al inventario a través de los pedidos a proveedores y salen mediante las ventas a clientes.

La falta de un registro integrado puede generar diferencias entre el inventario físico y el registrado. Esto provoca problemas al momento de realizar nuevas ventas, al no saber con certeza qué cantidad hay disponible y de qué lote. También aumenta el riesgo de no reponer a tiempo los productos con poco stock y de vender productos vencidos.

A esto se suma la necesidad de controlar las ventas de medicamentos que requieren receta, y de conservar el precio al que se vendió cada producto, ya que el precio de lista puede cambiar con el tiempo.

### Solución propuesta

La Farmacia Sana-Sana propone centralizar el registro de las operaciones de venta y de reabastecimiento. De este modo se controlan los movimientos de inventario y se actualizan las cantidades disponibles como consecuencia de cada operación: el stock se descuenta del lote correspondiente con cada venta y se suma cuando se recibe un pedido de un proveedor.

El sistema define un punto de reorden: cuando el stock de un producto llega a 5 unidades o menos, se genera un nuevo pedido de compra al proveedor. Esto evita quedarse sin mercadería y reduce la venta de productos vencidos.

Además, el sistema conserva el precio unitario de cada producto al momento de realizar la venta, evitando que modificaciones posteriores en el precio de lista afecten el historial de operaciones anteriores. También registra el número de receta en las ventas de productos que lo requieren, lo que permite controlar la venta bajo receta.

---

## 4_Alcance del Sistema 
El sistema farmacia podra gestionar :
| Area | Funcionalidad |
|---|---|
|     Personas     |Registro y diferenciación de Clientes y Vendedore  |
| Inventario y Catálogo  | Administracion de productos y Seguimiento de stock |
|     Ventas    |Registro ,Manejo y Control de ventas de medicamento bajo receta |
|     Proveedores y Compras    | Mantenimiento de Informacion y Generacion de pedidos |

---
## 5_Documentacion
Toda la documentacion de este proyecto se encuentra organizada por etapas en la carpeta [docs/](docs).

---
### Etapa 01- Requirimientos
En esta etapa se busca identificar al sistema con su descripcion del caso y las reglas de negocio que definen la organizacion de la Farmacia.
| Documento | Descripcion |
|---|---|
|     [Descripción del caso](docs/etapa-01/descripcion-caso.md)|Descripcion del caso|
| [Alcance del proyecto](docs/etapa-01/alcance.md) | Define los limites del sistema enfocadada en DER  |
| [Decisiones de Diseño](docs/etapa-01/decisiones-diseño.md) | Desiciones del grupo para el sistema  |
| [Reglas de negocio](docs/etapa-01/reglas-negocio.md) | Consideraciones o reglas del sistema |

---

### Etapa 02 - Modelo Logico Conceptual
En esta etapa se busca pasar de la descripcion del caso de manera conceptual a diagramarlo en un modelo de entidad Relacion.
| Documento | Descripcion |
|---|---|
|[Diagrama Entidad Relacion](docs/etapa-02/der/Farmacia_SanaSana_DER.png)|DER del sistema Farmacia|
|[Modelo Relacional](docs/etapa-02/modelo-relacional.md)|Características estructural y logica de los datos|
|[Normalizacion](docs/etapa-02/normalizacion.md)|Proceso de organizacion de los datos|

---
### Etapa 03 - Modelo Logico Conceptual
En esta etapa llevamos los datos de nuestro sistema a una implementación física mediante lineas de comandos SQL.
| Documento | Descripcion |
|---|---|
|[Implementacion](docs/etapa-03/implementación.md)| Estructura del sistema Farmacia SQL|
|[Pruebas Validacion](docs/etapa-03/pruebas-validacion.md)|Registros de prueba|
|[Restricciones de Integridad](docs/etapa-03/restricciones-integridad.md)|Restricciones y manejo de integridad de los datos |

---
### Etapa 04 - Consultas
En esta etapa hacemos manejo de la informacion de del sistema. Realizando consultas para obtener  respuestas a necesidades concretas del negocio.<br>
Esta tabla maneja archivos que estan en la carpeta [docs/](docs) que a su vez trabajaba con la carpeta [sql/](sql) donde se ve la implementacion de las [consultas](sql/consultas).
| Documento | Descripcion |
|---|---|
|[Comprobante de venta](sql/consultas/comprobante_venta.sql)| Detalles de venta y estrategia implementada |
|[Consulta de negocio avanzada](docs/etapa-04/consulta-avanzada.md)|Detalla el uso de consultas relacionando mas tablas|
|[Informe de ventas](docs/etapa-04/informe-ventas.md)|Resuelve la venta por categoria o por vendedor en fecha|

---

## 📂 Estructura del repositorio

```
proyecto-bd1-equipo-43
  │
  ├──📁 docs
  │   ├──📁 etapa-01
  │   │   ├──📄 Descripción del caso
  │   │   └──📄 Reglas de negocio
  │   │
  │   ├── 📁 etapa-02
  │   │   ├──🖼️ Diagrama Entidad-Relación (DER)
  │   │   ├──📄 Modelo relacional
  │   │   └──📄 Normalización
  │   │
  │   ├── 📁 etapa-03
  │   │   ├── 📄 Implementacion
  │   │   ├── 📄 Pruebas Validacion
  │   │   └── 📄 Restricciones de Integridad
  │   │
  │   ├──  📁 etapa-04/
  │   │   ├──📄 Comprobante de venta
  │   │   ├──📄 Consulta de negocio avanzada
  │   │   └──📄 Informe de ventas
  │   │ 
  │   ├── 📁 etapa-05/
  │   │   ├──📄 Descripción breve
  │   │   ├──📄 Script SQL de implementación
  │   │   ├──📄 Resumen explicativo
  │   │   └──📄 Temas técnicos
  │   │ 
  │   ├── 📁 sql/
  │   │   ├── 📁 ddl/
  │   │   └──📄 Crear BD
  │   ├── 📁 dml/
  │   │   └── 📄 Datos de prueba
  │   ├──📁 consultas/
  │   │   ├── 📄 Comprobante de venta
  │   │   ├── 📄 Consulta avanzada
  │   └── └── 📄 Informe de ventas
  └──📄 README.md
```
