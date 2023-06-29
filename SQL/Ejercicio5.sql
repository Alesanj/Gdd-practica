/* 5. Realizar una consulta que muestre código de artículo, detalle y cantidad de egresos de
stock que se realizaron para ese artículo en el año 2012 (egresan los productos que
fueron vendidos). Mostrar solo aquellos que hayan tenido más egresos que en el 2011.*/
USE GD2015C1
GO

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
ORDER BY 3 DESC

-- version del profesor mas performante porque no tiene subselect, Mas eficiente
SELECT 
 p1.prod_codigo,
 p1.prod_detalle,
 SUM(
  CASE WHEN YEAR(fact_fecha) = 2012 THEN item_cantidad 
    ELSE 0 
  END 
 ) as cant_vendida
FROM Producto p1
JOIN Item_Factura i1 on i1.item_producto = p1.prod_codigo
JOIN Factura f1 
  on i1.item_numero = f1.fact_numero 
 and i1.item_sucursal = f1.fact_sucursal 
 and i1.item_tipo = f1.fact_tipo
WHERE 
 YEAR(f1.fact_fecha) IN ( 2012 , 2011 )
GROUP BY 
 p1.prod_codigo,
 p1.prod_detalle
HAVING 
  SUM(
   CASE WHEN YEAR(fact_fecha) = 2012 THEN item_cantidad 
     ELSE 0 
   END 
  ) > 
  ISNULL(SUM(
   CASE WHEN YEAR(fact_fecha) = 2011 THEN item_cantidad 
     ELSE 0 
   END 
  ),0)
  ORDER BY cant_vendida DESC