/* 5. Realizar una consulta que muestre código de artículo, detalle y cantidad de egresos de
stock que se realizaron para ese artículo en el año 2012 (egresan los productos que
fueron vendidos). Mostrar solo aquellos que hayan tenido más egresos que en el 2011.*/
USE GD2015C1
GO
SELECT * FROM Producto


SELECT 
	prod.prod_codigo
	,prod.prod_detalle
	,SUM(ISNULL(item.item_cantidad,0)) AS CANTIDAD2012
	,(SELECT SUM(ISNULL(subitem.item_cantidad,0))
		FROM Factura subf
		JOIN Item_Factura subitem ON subf.fact_tipo = subitem.item_tipo AND subf.fact_sucursal = subitem.item_sucursal AND subf.fact_numero = subitem.item_numero AND YEAR(subf.fact_fecha) = 2011
		RIGHT JOIN Producto subprod ON subprod.prod_codigo = subitem.item_producto
		WHERE subprod.prod_codigo = prod.prod_codigo
		GROUP BY subprod.prod_codigo
	) AS CANTIDAD_2011
FROM Factura f
JOIN Item_Factura item ON f.fact_tipo = item.item_tipo AND f.fact_sucursal=item.item_sucursal AND f.fact_numero = item.item_numero AND YEAR(f.fact_fecha) = 2012
RIGHT JOIN Producto prod ON prod.prod_codigo = item.item_producto
GROUP BY prod.prod_codigo, prod.prod_detalle
HAVING SUM(ISNULL(item.item_cantidad,0)) >= (SELECT SUM(ISNULL(subitem.item_cantidad,0))
		FROM Factura subf
		JOIN Item_Factura subitem ON subf.fact_tipo = subitem.item_tipo AND subf.fact_sucursal = subitem.item_sucursal AND subf.fact_numero = subitem.item_numero AND YEAR(subf.fact_fecha) = 2011
		RIGHT JOIN Producto subprod ON subprod.prod_codigo = subitem.item_producto
		WHERE subprod.prod_codigo = prod.prod_codigo
		GROUP BY subprod.prod_codigo
	)
ORDER BY 2

