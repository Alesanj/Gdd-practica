/* 
1. Realizar una consulta SQL que permita saber si un cliente compro un producto en todos los meses del 2012.

Además, mostrar para el 2012: 
1. El cliente
2. La razón social del cliente
3. El producto comprado
4. El nombre del producto
5. Cantidad de productos distintos comprados por el cliente.
6. Cantidad de productos con composición comprados por el cliente.

El resultado deberá ser ordenado poniendo primero aquellos clientes que compraron más de 10 productos distintos en el 2012. 
*/
------------------------------------------------------------------------------------------------------------------------------
SELECT 
	cli.clie_codigo
	,cli.clie_razon_social
	,COUNT(DISTINCT p.prod_codigo) AS cant_prod_distintos
	,ISNULL((SELECT COUNT(DISTINCT subcompo.comp_producto) 
		FROM Cliente subcli
		LEFT JOIN Factura subf ON subf.fact_cliente = subcli.clie_codigo AND YEAR(subf.fact_fecha) = 2012
		JOIN Item_Factura subitem ON subf.fact_tipo = subitem.item_tipo AND subf.fact_sucursal = subitem.item_sucursal AND subf.fact_numero = subitem.item_numero
		JOIN Producto subp ON subp.prod_codigo = subitem.item_producto 
		JOIN Composicion subcompo ON subcompo.comp_producto = subp.prod_codigo
		WHERE subcli.clie_codigo = cli.clie_codigo
		GROUP BY subcli.clie_codigo),0) AS cant_prod_compuestos
	,CASE WHEN (	SELECT COUNT(	
			DISTINCT MONTH(fact_fecha))
			FROM Cliente subcli
			LEFT JOIN Factura subf ON subf.fact_cliente = subcli.clie_codigo AND YEAR(subf.fact_fecha) = 2012
			WHERE subcli.clie_codigo = cli.clie_codigo
			GROUP BY subcli.clie_codigo
	) = 12 THEN 1 ELSE 0 END AS compro_todos_los_meses
FROM Cliente cli
LEFT JOIN Factura f ON f.fact_cliente = cli.clie_codigo AND YEAR(f.fact_fecha) = 2012
JOIN Item_Factura item ON f.fact_tipo = item.item_tipo AND f.fact_sucursal=item.item_sucursal AND f.fact_numero = item.item_numero
JOIN Producto p ON p.prod_codigo = item.item_producto
GROUP BY cli.clie_codigo,cli.clie_razon_social
ORDER BY 1
------------------------------------------------------------------------------------------------------------------------------

--Con esta consulta en realidad puedo ver que no hay clientes que hayan comprado en todos los meses del 2012
SELECT DISTINCT
		clie_codigo,
		MONTH(fact_fecha)
FROM Cliente
JOIN Factura ON clie_codigo = fact_cliente
WHERE YEAR(fact_fecha) = 2012
ORDER BY 2 DESC 
------------------------------------------------------------------------------------------------------------------------------
SELECT 
	cli.clie_codigo
	,cli.clie_razon_social
FROM Cliente cli
LEFT JOIN Factura f ON f.fact_cliente = cli.clie_codigo AND YEAR(f.fact_fecha) = 2012
JOIN Item_Factura item ON f.fact_tipo = item.item_tipo AND f.fact_sucursal=item.item_sucursal AND f.fact_numero = item.item_numero
JOIN Producto p ON p.prod_codigo = item.item_producto
GROUP BY cli.clie_codigo,cli.clie_razon_social
ORDER BY 1

-- Con esta query podemos determinar cuantos productos compuestos tiene un producto, solo joineamos con composicion
-- y los registros que quedan son los que estan compuestos, puedo agrupar por prod_codigo y contar cuantos prod tiene 
SELECT prod_codigo, count(comp_producto)
FROM Producto
JOIN Composicion ON prod_codigo = comp_producto
GROUP BY prod_codigo

-- Entonces puedo "aplicarla" a los productos que estan en la factura del cliente y luego agruparlas por cliente 
SELECT	subcli.clie_codigo
		,COUNT(DISTINCT subcompo.comp_producto) 
FROM Cliente subcli
LEFT JOIN Factura f ON f.fact_cliente = subcli.clie_codigo AND YEAR(f.fact_fecha) = 2012
JOIN Item_Factura item ON f.fact_tipo = item.item_tipo AND f.fact_sucursal=item.item_sucursal AND f.fact_numero = item.item_numero
JOIN Producto subp ON subp.prod_codigo = item.item_producto
JOIN Composicion subcompo ON subcompo.comp_producto = subp.prod_codigo
GROUP BY subcli.clie_codigo


	
SELECT	
		subcli.clie_codigo 
		,subp.prod_detalle
		,COUNT(subp.prod_codigo)
FROM Cliente subcli
LEFT JOIN Factura f ON f.fact_cliente = subcli.clie_codigo AND YEAR(f.fact_fecha) = 2012
JOIN Item_Factura item ON f.fact_tipo = item.item_tipo AND f.fact_sucursal=item.item_sucursal AND f.fact_numero = item.item_numero
JOIN Producto subp ON subp.prod_codigo = item.item_producto
GROUP BY subcli.clie_codigo, subp.prod_detalle
ORDER BY 3 DESC 
