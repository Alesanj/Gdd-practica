/* Realizar una consulta SQL que permita saber los clientes que
compraron por encima del promedio de compras (fact_total) de todos
los clientes del 2012.

De estos clientes mostrar para el 2012:
1.El código del cliente
2.La razón social del cliente
3.Código de producto que en cantidades más compro.
4,El nombre del producto del punto 3.
5,Cantidad de productos distintos comprados por el cliente,
6.Cantidad de productos con composición comprados por el cliente,

EI resultado deberá ser ordenado poniendo primero aquellos clientes
que compraron más de entre 5 y 10 productos distintos en el 2012 */

--Entiendo que se pide a los que en en total compraron mas que el promedio
SELECT	c.clie_codigo
		,c.clie_razon_social
		,(
			SELECT TOP 1 subp.prod_codigo
			FROM Cliente subc 
			JOIN Factura subf ON subf.fact_cliente = subc.clie_codigo
			JOIN Item_Factura subit ON subf.fact_tipo = subit.item_tipo AND subf.fact_sucursal = subit.item_sucursal AND subf.fact_numero = subit.item_numero AND YEAR(subf.fact_fecha) = 2012 
			JOIN Producto subp ON subp.prod_codigo = subit.item_producto
			WHERE c.clie_codigo = subc.clie_codigo 
			GROUP BY subp.prod_codigo , subc.clie_codigo
			ORDER BY SUM(subit.item_cantidad) DESC
		) AS prod_mas_comprado_cod

		,(
			SELECT TOP 1 subp.prod_detalle
			FROM Cliente subc 
			JOIN Factura subf ON subf.fact_cliente = subc.clie_codigo
			JOIN Item_Factura subit ON subf.fact_tipo = subit.item_tipo AND subf.fact_sucursal = subit.item_sucursal AND subf.fact_numero = subit.item_numero AND YEAR(subf.fact_fecha) = 2012 
			JOIN Producto subp ON subp.prod_codigo = subit.item_producto
			WHERE c.clie_codigo = subc.clie_codigo  
			GROUP BY subp.prod_detalle , subc.clie_codigo
			ORDER BY SUM(subit.item_cantidad) DESC
		) AS prod_mas_comprado_cod

		,(	SELECT	SUM(subf.fact_total) FROM Factura subf
			JOIN Cliente subc ON subc.clie_codigo = subf.fact_cliente
			WHERE subc.clie_codigo = c.clie_codigo
			GROUP BY subc.clie_codigo
		) AS MONTO_CLIENTE_ANUAL

		,(SELECT AVG(f2.fact_total) FROM Factura f2 WHERE YEAR(f2.fact_fecha) = 2012) AS PROMEDIO_COMPRAS_ANUAL
		,COUNT(DISTINCT pr.prod_codigo) AS prod_distintos
		,COUNT(DISTINCT compo.comp_producto) AS prod_compuestos
		,ROW_NUMBER() OVER(PARTITION BY CASE WHEN (COUNT(DISTINCT pr.prod_codigo) > 5 AND COUNT(DISTINCT pr.prod_codigo) < 10) THEN 1 ELSE 0 END ORDER BY c.clie_razon_social) AS RN
FROM Cliente c
LEFT JOIN Factura f ON f.fact_cliente = c.clie_codigo AND YEAR(f.fact_fecha) = 2012
JOIN Item_Factura it ON f.fact_tipo = it.item_tipo AND f.fact_sucursal=it.item_sucursal AND f.fact_numero = it.item_numero
JOIN Producto pr ON pr.prod_codigo = it.item_producto
LEFT JOIN Composicion compo ON compo.comp_producto = pr.prod_codigo
GROUP BY c.clie_codigo
		,c.clie_razon_social
HAVING (SELECT	SUM(subf.fact_total) FROM Factura subf
			JOIN Cliente subc ON subc.clie_codigo = subf.fact_cliente
			WHERE subc.clie_codigo = c.clie_codigo
			GROUP BY subc.clie_codigo) > (SELECT AVG(f2.fact_total) FROM Factura f2 WHERE YEAR(f2.fact_fecha) = 2012)

-- Todavia no se como resolver esto del ordenamiento, deberia hacer una particion?
ORDER BY CASE WHEN (COUNT(DISTINCT pr.prod_codigo)) > 5 AND (COUNT(DISTINCT pr.prod_codigo)) < 10 
			  THEN 2 
			  ELSE 1
			  END
			  	

------------------
SELECT * FROM Producto WHERE prod_codigo = '00001705'


	(
	SELECT	subp.prod_codigo
			,subc.clie_codigo
			,subp.prod_detalle
			,SUM(subit.item_cantidad) 
	FROM Cliente subc 
	JOIN Factura subf ON subf.fact_cliente = subc.clie_codigo
	JOIN Item_Factura subit ON subf.fact_tipo = subit.item_tipo AND subf.fact_sucursal = subit.item_sucursal AND subf.fact_numero = subit.item_numero
	JOIN Producto subp ON subp.prod_codigo = subit.item_producto
	GROUP BY subp.prod_codigo ,subp.prod_detalle, subc.clie_codigo
	ORDER BY 4 DESC
	)
