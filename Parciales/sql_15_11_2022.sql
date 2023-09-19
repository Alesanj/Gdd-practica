/*
I, Realizar una consulta SQL que permita saber los clientes que
compraron todos los rubros disponibles del sistema en el 2012.
De estos clientes mostrar, siempre para el 2012:
1.El código del cliente
2.Código de producto que en cantidades más compro.
3.El nombre del producto del punto 3.
4,Cantidad de productos distintos comprados por el cliente.
5.Cantidad de productos con composición comprados por el ciiente.

El resultado deberá ser ordenado por razón social del cliente
alfabéticamente primero y luego, los clientes que compraron entre un
20 % y 30% del total facturado en el 2012 primero, luego, los restantes,
*/
USE GD2015C1
GO
-- Vemos que ningun cliente compro en todos los rubros (hay 31)
SELECT clie_razon_social
		,count(DISTINCT rubr_detalle)
FROM Cliente 
JOIN Factura ON clie_codigo = fact_cliente
JOIN Item_Factura it ON it.item_tipo = fact_tipo AND it.item_sucursal = fact_sucursal AND it.item_numero = fact_numero
JOIN Producto pr ON pr.prod_codigo = it.item_producto
JOIN Rubro ON rubr_id = pr.prod_rubro
GROUP BY clie_razon_social
ORDER BY 2 DESC

SELECT * FROM Rubro
--------------------------------------------------------------------
SELECT * FROM Producto
SELECT	
		ROW_NUMBER() OVER (
			PARTITION BY CASE
				WHEN (SUM(DISTINCT f.fact_total) > (0.2 * (SELECT SUM(fact_total) FROM Factura WHERE YEAR(fact_fecha) = 2012)))
					AND (SUM(DISTINCT f.fact_total) < (0.3 * (SELECT SUM(fact_total) FROM Factura WHERE YEAR(fact_fecha) = 2012)))
				THEN 1
				ELSE 0
			END
			ORDER BY c.clie_codigo
		) AS RN
		,c.clie_codigo 
		,c.clie_razon_social
		,COUNT(DISTINCT pr.prod_codigo) AS cant_prod_distintos
		,COUNT(DISTINCT compo.comp_producto) AS cant_prod_compuestos
		, (
				SELECT TOP 1 subpr.prod_codigo
				FROM Cliente subc
				JOIN Factura subf ON subc.clie_codigo = subf.fact_cliente
				JOIN Item_Factura subit ON subit.item_tipo = subf.fact_tipo AND subit.item_sucursal = subf.fact_sucursal AND subit.item_numero = subf.fact_numero AND YEAR(subf.fact_fecha) = 2012
				JOIN Producto subpr ON subpr.prod_codigo = subit.item_producto
				WHERE subc.clie_codigo = c.clie_codigo
				GROUP BY subpr.prod_codigo
				ORDER BY SUM(subit.item_cantidad) DESC
		)
		, (
				SELECT TOP 1 subpr.prod_detalle 
				FROM Cliente subc
				JOIN Factura subf ON subc.clie_codigo = subf.fact_cliente
				JOIN Item_Factura subit ON subit.item_tipo = subf.fact_tipo AND subit.item_sucursal = subf.fact_sucursal AND subit.item_numero = subf.fact_numero AND YEAR(subf.fact_fecha) = 2012
				JOIN Producto subpr ON subpr.prod_codigo = subit.item_producto
				WHERE subc.clie_codigo = c.clie_codigo
				GROUP BY subpr.prod_detalle
				ORDER BY SUM(subit.item_cantidad) DESC
		)
		,CASE WHEN(
			SELECT COUNT(DISTINCT rubr_id) 
			FROM Cliente subc 
			JOIN Factura ON clie_codigo = fact_cliente
			JOIN Item_Factura it ON it.item_tipo = fact_tipo AND it.item_sucursal = fact_sucursal AND it.item_numero = fact_numero
			JOIN Producto pr ON pr.prod_codigo = it.item_producto
			JOIN Rubro ON rubr_id = pr.prod_rubro
			WHERE subc.clie_codigo = c.clie_codigo
		) = 23 THEN 1 ELSE 0 END AS compro_en_todos_los_rubros
FROM Cliente c 
LEFT JOIN Factura f ON f.fact_cliente = c.clie_codigo
JOIN Item_Factura it ON it.item_tipo = f.fact_tipo AND it.item_sucursal = f.fact_sucursal AND it.item_numero = f.fact_numero AND YEAR(f.fact_fecha) = 2012
JOIN Producto pr ON pr.prod_codigo = it.item_producto
LEFT JOIN Composicion compo ON compo.comp_producto = pr.prod_codigo
GROUP BY c.clie_codigo, c.clie_razon_social


ORDER BY c.clie_razon_social

--------------------------------------------------------------------
SELECT
	c.clie_codigo,
	(
		SELECT TOP 1 itf2.item_producto FROM Item_Factura itf2
		JOIN Factura f2 ON f2.fact_numero = itf2.item_numero AND f2.fact_cliente = c.clie_codigo
		GROUP BY itf2.item_producto
		ORDER BY SUM(itf2.item_cantidad)
	) as cod_producto_mas_comprado,
	(
		SELECT TOP 1 p2.prod_detalle FROM Item_Factura itf2
		JOIN Factura f2 ON f2.fact_numero = itf2.item_numero AND f2.fact_cliente = c.clie_codigo
		JOIN Producto p2 ON p2.prod_codigo = itf2.item_producto
		GROUP BY itf2.item_producto, p2.prod_codigo, p2.prod_detalle
		ORDER BY SUM(itf2.item_cantidad)
	) as producto_mas_comprado,
	COUNT(DISTINCT itf.item_producto) as productos_distintos,
	COUNT(DISTINCT co.comp_producto) as productos_con_composicion
FROM Item_Factura itf
JOIN Factura f ON f.fact_numero = itf.item_numero
JOIN Cliente c ON f.fact_cliente = c.clie_codigo
JOIN Producto p ON p.prod_codigo = itf.item_producto
JOIN Rubro r ON r.rubr_id = p.prod_rubro
LEFT JOIN Composicion co ON co.comp_producto = p.prod_codigo
WHERE YEAR(f.fact_fecha) = 2012
GROUP BY c.clie_codigo, c.clie_razon_social
HAVING COUNT(DISTINCT r.rubr_id) = (SELECT COUNT(*) FROM Rubro)
ORDER BY c.clie_razon_social,
CASE 
	WHEN SUM(f.fact_total)
		BETWEEN 0.2 * (SELECT SUM(f.fact_total) FROM Factura f WHERE YEAR(f.fact_fecha) = 2012)
		AND 0.3 * (SELECT SUM(f.fact_total) FROM Factura f WHERE YEAR(f.fact_fecha) = 2012)
			THEN 1
	ELSE 2
END