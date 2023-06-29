/* 4. Realizar una consulta que muestre para todos los artículos código, detalle y cantidad de
artículos que lo componen. Mostrar solo aquellos artículos para los cuales el stock
promedio por depósito sea mayor a 100.
*/
USE GD2015C1
GO

SELECT 
	p.prod_codigo
	,p.prod_detalle
	,COUNT(*) AS cant_componentes
	,(SELECT
		AVG(stoc_cantidad)
		FROM  Producto subp
		JOIN STOCK ON stoc_producto = subp.prod_codigo 
		WHERE subp.prod_codigo = p.prod_codigo
		GROUP BY prod_codigo
		)		
FROM Composicion comp
JOIN Producto p ON comp.comp_producto = p.prod_codigo
JOIN Producto pc ON pc.prod_codigo = comp.comp_componente
GROUP BY p.prod_codigo, p.prod_detalle
-- Tabla para comprobar los promedios por deposito
SELECT 
		prod_codigo
		,prod_detalle
		,AVG(stoc_cantidad)
FROM  Producto  
LEFT JOIN STOCK ON stoc_producto = prod_codigo 
GROUP BY prod_codigo,prod_detalle
ORDER BY 2

