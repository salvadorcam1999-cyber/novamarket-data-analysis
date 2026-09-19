-- ============================================================
-- NovaMarket - Limpieza y transformación
-- ============================================================

-- 1. Eliminación de registros duplicados.
-- La limpieza se basa en conservar una sola ocurrencia de cada fila idéntica.
CREATE TABLE fact_ventas_limpia AS
SELECT DISTINCT *
FROM fact_ventas;

-- 2. Tratamiento de descuentos NULL.
-- La regla de negocio utilizada en el proyecto interpreta un NULL como
-- una transacción sin descuento, por lo que se reemplaza por 0.
CREATE TABLE fact_ventas_final AS
SELECT
    orden_id,
    linea_orden_id,
    fecha_compra,
    cliente_id,
    producto_id,
    cantidad,
    COALESCE(descuento, 0) AS descuento,
    precio_final_unitario,
    metodo_pago
FROM fact_ventas_limpia;

-- 3. Validación posterior del tratamiento de NULL en descuentos.
SELECT COUNT(*) AS descuentos_nulos_final
FROM fact_ventas_final
WHERE descuento IS NULL;

-- 4. Distribución de descuentos no nulos
SELECT
    descuento,
    COUNT(*) AS registros
FROM fact_ventas_limpia
WHERE descuento IS NOT NULL
GROUP BY descuento
ORDER BY descuento;

-- 5. Distribución inicial de precios
SELECT
    MIN(precio_final_unitario) AS precio_minimo,
    MAX(precio_final_unitario) AS precio_maximo,
    AVG(precio_final_unitario) AS precio_promedio,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY precio_final_unitario) AS mediana
FROM fact_ventas_final;

-- 6. Límites IQR para precio_final_unitario
WITH estadisticas AS (
    SELECT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY precio_final_unitario) AS q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY precio_final_unitario) AS q3
    FROM fact_ventas_final
)
SELECT
    q1,
    q3,
    (q3 - q1) AS iqr,
    q1 - 1.5 * (q3 - q1) AS limite_inferior,
    q3 + 1.5 * (q3 - q1) AS limite_superior
FROM estadisticas;

-- 7. Impacto de cantidades atípicas (> 15.5)
SELECT
    COUNT(*) AS registros_atipicos,
    SUM(cantidad * precio_final_unitario) AS ventas_atipicas
FROM fact_ventas_final
WHERE cantidad > 15.5;

-- 8. Detalle de registros atípicos por cantidad
SELECT
    orden_id,
    linea_orden_id,
    fecha_compra,
    cliente_id,
    producto_id,
    cantidad,
    precio_final_unitario,
    descuento,
    metodo_pago
FROM fact_ventas_final
WHERE cantidad > 15.5
ORDER BY cantidad DESC
LIMIT 20;

-- 9. Distribución de cantidades atípicas
SELECT
    cantidad,
    COUNT(*) AS registros
FROM fact_ventas_final
WHERE cantidad > 15.5
GROUP BY cantidad
ORDER BY cantidad DESC;

-- 10. Estandarización de estados de clientes.
CREATE TABLE dim_clientes_final AS
SELECT
    cliente_id,
    nombre_completo,
    email,
    genero,
    fecha_registro,
    ciudad,
    CASE
        WHEN UPPER(TRIM(estado)) IN ('CDMX', 'CIUDAD DE MÉXICO')
            THEN 'Ciudad de México'
        WHEN UPPER(TRIM(estado)) IN ('EDOMEX', 'ESTADO DE MÉXICO')
            THEN 'Estado de México'
        WHEN UPPER(TRIM(estado)) = 'GUANAJUATO'
            THEN 'Guanajuato'
        WHEN UPPER(TRIM(estado)) = 'JALISCO'
            THEN 'Jalisco'
        WHEN UPPER(TRIM(estado)) = 'NUEVO LEÓN'
            THEN 'Nuevo León'
        ELSE TRIM(estado)
    END AS estado
FROM dim_clientes;

-- 11. Validación de la estandarización
SELECT
    estado,
    COUNT(*) AS clientes
FROM dim_clientes_final
GROUP BY estado
ORDER BY clientes DESC;

-- 12. Exclusión de valores atípicos de cantidad.
-- El umbral de 15.5 unidades fue el límite superior utilizado en el proyecto.
CREATE TABLE fact_ventas_analitica AS
SELECT *
FROM fact_ventas_final
WHERE cantidad <= 15.5;

-- 13. Validación de la tabla analítica final
SELECT
    COUNT(*) AS total_registros,
    COUNT(*) FILTER (WHERE descuento IS NULL) AS descuentos_nulos,
    COUNT(*) FILTER (WHERE cantidad <= 0) AS cantidades_invalidas,
    COUNT(*) FILTER (WHERE precio_final_unitario <= 0) AS precios_invalidos,
    COUNT(*) FILTER (WHERE cantidad > 15.5) AS cantidades_atipicas
FROM fact_ventas_analitica;
