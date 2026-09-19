-- ============================================================
-- NovaMarket - Análisis de negocio
-- ============================================================

-- 1. KPIs generales
SELECT
    SUM(cantidad * precio_final_unitario * (1 - descuento)) AS ventas_totales,
    SUM(cantidad) AS unidades_vendidas,
    COUNT(DISTINCT orden_id) AS ordenes_totales,
    SUM(cantidad * precio_final_unitario * (1 - descuento))
        / NULLIF(COUNT(DISTINCT orden_id), 0) AS ticket_promedio
FROM fact_ventas_analitica;

-- 2. Evolución anual de ventas, unidades y órdenes
SELECT
    EXTRACT(YEAR FROM fecha_compra) AS anio,
    SUM(cantidad * precio_final_unitario * (1 - descuento)) AS ventas,
    SUM(cantidad) AS unidades,
    COUNT(DISTINCT orden_id) AS ordenes
FROM fact_ventas_analitica
GROUP BY EXTRACT(YEAR FROM fecha_compra)
ORDER BY anio;

-- 3. Ventas por categoría
SELECT
    p.categoria,
    SUM(f.cantidad * f.precio_final_unitario * (1 - f.descuento)) AS ventas,
    SUM(f.cantidad) AS unidades,
    COUNT(DISTINCT f.orden_id) AS ordenes
FROM fact_ventas_analitica f
JOIN dim_productos p
    ON f.producto_id = p.producto_id
GROUP BY p.categoria
ORDER BY ventas DESC;

-- 4. Top 10 productos por ventas
SELECT
    p.producto_id,
    p.nombre_producto,
    p.categoria,
    SUM(f.cantidad * f.precio_final_unitario * (1 - f.descuento)) AS ventas,
    SUM(f.cantidad) AS unidades
FROM fact_ventas_analitica f
JOIN dim_productos p
    ON f.producto_id = p.producto_id
GROUP BY
    p.producto_id,
    p.nombre_producto,
    p.categoria
ORDER BY ventas DESC
LIMIT 10;

-- 5. Top 10 clientes por gasto
SELECT
    f.cliente_id,
    c.nombre_completo,
    c.ciudad,
    c.estado,
    COUNT(DISTINCT f.orden_id) AS ordenes,
    SUM(f.cantidad) AS unidades_compradas,
    SUM(f.cantidad * f.precio_final_unitario * (1 - f.descuento)) AS gasto_total
FROM fact_ventas_analitica f
JOIN dim_clientes_final c
    ON f.cliente_id = c.cliente_id
GROUP BY
    f.cliente_id,
    c.nombre_completo,
    c.ciudad,
    c.estado
ORDER BY gasto_total DESC
LIMIT 10;

-- 6. Ventas, clientes y órdenes por estado
SELECT
    c.estado,
    SUM(f.cantidad * f.precio_final_unitario * (1 - f.descuento)) AS ventas,
    COUNT(DISTINCT f.cliente_id) AS clientes,
    COUNT(DISTINCT f.orden_id) AS ordenes
FROM fact_ventas_analitica f
JOIN dim_clientes_final c
    ON f.cliente_id = c.cliente_id
GROUP BY c.estado
ORDER BY ventas DESC;

-- 7. Ventas por método de pago
SELECT
    metodo_pago,
    COUNT(DISTINCT orden_id) AS ordenes,
    SUM(cantidad) AS unidades,
    SUM(cantidad * precio_final_unitario * (1 - descuento)) AS ventas
FROM fact_ventas_analitica
GROUP BY metodo_pago
ORDER BY ventas DESC;

-- 8. Evolución mensual de ventas
SELECT
    DATE_TRUNC('month', fecha_compra)::date AS mes,
    SUM(cantidad * precio_final_unitario * (1 - descuento)) AS ventas,
    SUM(cantidad) AS unidades,
    COUNT(DISTINCT orden_id) AS ordenes
FROM fact_ventas_analitica
GROUP BY DATE_TRUNC('month', fecha_compra)
ORDER BY mes;

-- 9. Top 5 meses por ventas
WITH ventas_mensuales AS (
    SELECT
        DATE_TRUNC('month', fecha_compra)::date AS mes,
        SUM(cantidad * precio_final_unitario * (1 - descuento)) AS ventas
    FROM fact_ventas_analitica
    GROUP BY DATE_TRUNC('month', fecha_compra)
)
SELECT
    mes,
    ventas
FROM ventas_mensuales
ORDER BY ventas DESC
LIMIT 5;

-- 10. Bottom 5 meses por ventas
WITH ventas_mensuales AS (
    SELECT
        DATE_TRUNC('month', fecha_compra)::date AS mes,
        SUM(cantidad * precio_final_unitario * (1 - descuento)) AS ventas
    FROM fact_ventas_analitica
    GROUP BY DATE_TRUNC('month', fecha_compra)
)
SELECT
    mes,
    ventas
FROM ventas_mensuales
ORDER BY ventas ASC
LIMIT 5;

-- 11. Desempeño comercial por categoría con ticket promedio
SELECT
    p.categoria,
    SUM(f.cantidad * f.precio_final_unitario * (1 - f.descuento)) AS ventas,
    COUNT(DISTINCT f.orden_id) AS ordenes,
    SUM(f.cantidad) AS unidades,
    SUM(f.cantidad * f.precio_final_unitario * (1 - f.descuento))
        / NULLIF(COUNT(DISTINCT f.orden_id), 0) AS ticket_promedio
FROM fact_ventas_analitica f
JOIN dim_productos p
    ON f.producto_id = p.producto_id
GROUP BY p.categoria
ORDER BY ventas DESC;

-- 12. Crecimiento anual de ventas mediante LAG()
WITH ventas_anuales AS (
    SELECT
        EXTRACT(YEAR FROM fecha_compra)::int AS anio,
        SUM(cantidad * precio_final_unitario * (1 - descuento)) AS ventas
    FROM fact_ventas_analitica
    GROUP BY EXTRACT(YEAR FROM fecha_compra)
), crecimiento AS (
    SELECT
        anio,
        ventas,
        LAG(ventas) OVER (ORDER BY anio) AS ventas_anio_anterior
    FROM ventas_anuales
)
SELECT
    anio,
    ventas,
    ventas_anio_anterior,
    CASE
        WHEN ventas_anio_anterior IS NULL OR ventas_anio_anterior = 0 THEN NULL
        ELSE (ventas - ventas_anio_anterior) * 100.0 / ventas_anio_anterior
    END AS crecimiento_pct
FROM crecimiento
ORDER BY anio;

-- 13. Ventas netas y efecto de descuentos
SELECT
    SUM(cantidad * precio_final_unitario * (1 - descuento)) AS ventas_netas,
    SUM(cantidad * precio_final_unitario) AS ventas_brutas,
    SUM(cantidad * precio_final_unitario * descuento) AS descuento_total
FROM fact_ventas_analitica;
