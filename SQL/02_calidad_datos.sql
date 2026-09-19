-- ============================================================
-- NovaMarket - Calidad y validación de datos
-- ============================================================

-- 1. Detección de registros duplicados en fact_ventas
SELECT
    orden_id,
    linea_orden_id,
    fecha_compra,
    cliente_id,
    producto_id,
    cantidad,
    descuento,
    precio_final_unitario,
    metodo_pago,
    COUNT(*) AS veces_repetido
FROM fact_ventas
GROUP BY
    orden_id,
    linea_orden_id,
    fecha_compra,
    cliente_id,
    producto_id,
    cantidad,
    descuento,
    precio_final_unitario,
    metodo_pago
HAVING COUNT(*) > 1;

-- 2. Impacto de los duplicados sobre las ventas
SELECT
    SUM(cantidad * precio_final_unitario) AS ventas_sin_duplicados
FROM (
    SELECT DISTINCT
        orden_id,
        linea_orden_id,
        fecha_compra,
        cliente_id,
        producto_id,
        cantidad,
        descuento,
        precio_final_unitario,
        metodo_pago
    FROM fact_ventas
) AS ventas_unicas;

-- 3. Valores NULL en descuentos
SELECT COUNT(*) AS descuentos_nulos
FROM fact_ventas
WHERE descuento IS NULL;

-- 4. Valores NULL en email de clientes
SELECT COUNT(*) AS emails_nulos
FROM dim_clientes
WHERE email IS NULL;

-- 5. Cadenas vacías en email
SELECT COUNT(*) AS emails_vacios
FROM dim_clientes
WHERE email = '';

-- 6. Información disponible de clientes con email NULL
SELECT
    COUNT(*) AS clientes_email_nulo,
    COUNT(nombre_completo) AS nombre_completo_disponible,
    COUNT(ciudad) AS ciudad_disponible,
    COUNT(estado) AS estado_disponible
FROM dim_clientes
WHERE email IS NULL;

-- 7. Unicidad de cliente_id
SELECT
    COUNT(*) AS clientes_totales,
    COUNT(DISTINCT cliente_id) AS clientes_unicos
FROM dim_clientes;

-- 8. Fechas de registro NULL
SELECT COUNT(*) AS fechas_registro_nulas
FROM dim_clientes
WHERE fecha_registro IS NULL;

-- 9. Campos críticos NULL en ventas
SELECT
    COUNT(*) FILTER (WHERE fecha_compra IS NULL) AS fechas_nulas,
    COUNT(*) FILTER (WHERE cliente_id IS NULL) AS clientes_nulos,
    COUNT(*) FILTER (WHERE producto_id IS NULL) AS productos_nulos
FROM fact_ventas;

-- 10. Cantidades inválidas
SELECT COUNT(*) AS cantidades_invalidas
FROM fact_ventas
WHERE cantidad <= 0;

-- 11. Precios inválidos
SELECT COUNT(*) AS precios_invalidos
FROM fact_ventas
WHERE precio_final_unitario <= 0;

-- 12. Valores de descuento fuera de rango
SELECT
    COUNT(*) FILTER (WHERE descuento < 0) AS descuentos_negativos,
    COUNT(*) FILTER (WHERE descuento > 1) AS descuentos_mayores_100
FROM fact_ventas;

-- 13. Porcentaje de descuentos NULL
SELECT
    COUNT(*) AS descuentos_nulos,
    COUNT(*) * 100.0 / (SELECT COUNT(*) FROM fact_ventas) AS porcentaje_nulos
FROM fact_ventas
WHERE descuento IS NULL;

-- 14. Unicidad de las líneas de venta
-- Validación adicional de duplicidad con la llave de línea observada.
SELECT
    COUNT(*) AS total_registros,
    COUNT(DISTINCT linea_orden_id) AS lineas_unicas
FROM fact_ventas;

-- Los análisis de IQR, valores atípicos de cantidad y validación posterior
-- se ejecutan después de crear las tablas limpias en 03_limpieza.sql.
