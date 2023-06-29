/* 4. Realizar una consulta que muestre para todos los artículos código, detalle y cantidad de
artículos que lo componen. Mostrar solo aquellos artículos para los cuales el stock
promedio por depósito sea mayor a 100.
*/
USE GD2015C1
GO

SELECT * FROM Composicion WHERE comp_producto = 00006404
SELECT 
	p.prod_codigo
	,p.prod_detalle
	,COUNT(comp.comp_componente) AS cant_componentes
	,FLOOR(ISNULL((SELECT
		AVG(stoc_cantidad)
		FROM  Producto subp
		JOIN STOCK ON stoc_producto = subp.prod_codigo 
		WHERE subp.prod_codigo = p.prod_codigo
		GROUP BY prod_codigo
		),0)) AS PROMEDIO

FROM Producto p
LEFT JOIN Composicion comp ON comp.comp_producto = p.prod_codigo
LEFT JOIN Producto pc ON pc.prod_codigo = comp.comp_componente
GROUP BY p.prod_codigo, p.prod_detalle
HAVING (ISNULL((SELECT
		AVG(stoc_cantidad)
		FROM  Producto subp
		JOIN STOCK ON stoc_producto = subp.prod_codigo 
		WHERE subp.prod_codigo = p.prod_codigo
		GROUP BY prod_codigo
		),0)) > 100
ORDER BY 3 DESC

-- Tabla para comprobar los promedios por deposito
SELECT 
		prod_codigo
		,prod_detalle
		,AVG(stoc_cantidad)
FROM  Producto  
JOIN STOCK ON stoc_producto = prod_codigo 
GROUP BY prod_codigo,prod_detalle
ORDER BY 2

