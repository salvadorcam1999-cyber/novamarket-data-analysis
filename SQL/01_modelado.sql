-- ============================================================
-- NovaMarket - Modelado SQL
-- Proyecto: Sistema de Inteligencia de Clientes y Ventas
-- Motor: PostgreSQL
-- ============================================================

-- Dimensión de clientes
CREATE TABLE dim_clientes (
    cliente_id INTEGER PRIMARY KEY,
    nombre_completo VARCHAR(150),
    email VARCHAR(150),
    genero VARCHAR(20),
    fecha_registro DATE,
    ciudad VARCHAR(100),
    estado VARCHAR(100)
);

-- Dimensión de productos
CREATE TABLE dim_productos (
    producto_id INTEGER PRIMARY KEY,
    nombre_producto VARCHAR(150),
    categoria VARCHAR(100),
    costo NUMERIC(12,2),
    precio_lista NUMERIC(12,2)
);

-- Hechos transaccionales
CREATE TABLE fact_ventas (
    orden_id INTEGER,
    linea_orden_id INTEGER,
    fecha_compra TIMESTAMP,
    cliente_id INTEGER,
    producto_id INTEGER,
    cantidad INTEGER,
    descuento NUMERIC(5,2),
    precio_final_unitario NUMERIC(12,2),
    metodo_pago VARCHAR(50)
);

-- Nota:
-- Las relaciones analíticas del modelo estrella se construyen a partir de
-- cliente_id y producto_id. En el proyecto original las claves externas
-- se utilizaron de forma lógica para las consultas y el modelo BI.
