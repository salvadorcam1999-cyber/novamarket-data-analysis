# NovaMarket — Sistema de Inteligencia de Clientes y Ventas para E-commerce

Proyecto de análisis de datos de un e-commerce desarrollado de extremo a extremo utilizando PostgreSQL, Python, Pandas y Power BI.

## Objetivo

Analizar el comportamiento de clientes, productos y ventas para generar indicadores comerciales y visualizaciones que permitan identificar patrones de compra, desempeño por categoría, rentabilidad y evolución temporal.

## Alcance del proyecto

- 300,000 órdenes
- 10,000 clientes
- 500 productos
- 719,850 líneas de venta
- Periodo histórico: septiembre de 2023 a agosto de 2026

## Flujo de trabajo

PostgreSQL → Python/Pandas → Power BI

### 1. PostgreSQL

Se realizó el modelado y preparación de los datos, incluyendo:

- Diseño de tablas dimensionales y de hechos
- Validación de calidad de datos
- Identificación de registros duplicados y valores nulos
- Limpieza y preparación de los datos
- Consultas SQL para análisis comercial

Los scripts se encuentran en la carpeta [SQL](./SQL).

### 2. Python y Pandas

Se utilizó Python para:

- Conexión con PostgreSQL
- Carga y exploración de datos
- Análisis estadístico y exploratorio
- Preparación de métricas comerciales
- Análisis de ventas por categoría y método de pago
- Análisis de clientes y productos
- Generación de archivos preparados para Power BI
- Validación de resultados

El notebook se encuentra en la carpeta [Pitón](./Pitón).

### 3. Power BI

Se desarrolló un dashboard para analizar:

- Desempeño comercial
- Comportamiento y segmentación de clientes
- Desempeño y rentabilidad de productos
- Evolución mensual de ventas y órdenes

Las capturas del dashboard se encuentran en [Power BI](./PowerBI).

## Principales indicadores

- Ventas netas: 4.13 mil millones
- Órdenes: 300,000
- Clientes: 10,000
- Productos: 500
- Unidades vendidas: aproximadamente 4 millones
- Margen: 25.55%

## Herramientas

- PostgreSQL
- SQL
- Python
- Pandas
- NumPy
- Matplotlib
- Power BI
- DAX
- Power Query

## Estructura del repositorio

```text
Power BI/   → Dashboard y capturas
Pitón/      → Notebook de análisis
SQL/        → Scripts SQL del proyecto
data/       → Información y documentación de datos
imágenes/   → Recursos gráficos
