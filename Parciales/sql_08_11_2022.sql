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
USE GD2015C1
GO
SELECT 
	cli.clie_codigo
	,cli.clie_razon_social
	,COUNT(DISTINCT p.prod_codigo) AS cant_prod_distintos
	,COUNT(DISTINCT compo.comp_producto)AS cant_prod_compuestossss
	,(	SELECT TOP 1	
		 subp.prod_codigo
		FROM Cliente subcli
		LEFT JOIN Factura f ON f.fact_cliente = subcli.clie_codigo AND YEAR(f.fact_fecha) = 2012
		JOIN Item_Factura item ON f.fact_tipo = item.item_tipo AND f.fact_sucursal=item.item_sucursal AND f.fact_numero = item.item_numero
		JOIN Producto subp ON subp.prod_codigo = item.item_producto
		WHERE subcli.clie_codigo = cli.clie_codigo
		GROUP BY subcli.clie_codigo,subp.prod_codigo
		ORDER BY SUM(item.item_cantidad) DESC 
	) AS prod_mas_vendido_codigo

	,(	SELECT TOP 1	
		 subp.prod_detalle
		FROM Cliente subcli
		LEFT JOIN Factura f ON f.fact_cliente = subcli.clie_codigo AND YEAR(f.fact_fecha) = 2012
		JOIN Item_Factura item ON f.fact_tipo = item.item_tipo AND f.fact_sucursal=item.item_sucursal AND f.fact_numero = item.item_numero
		JOIN Producto subp ON subp.prod_codigo = item.item_producto
		WHERE subcli.clie_codigo = cli.clie_codigo
		GROUP BY subcli.clie_codigo,subp.prod_detalle
		ORDER BY SUM(item.item_cantidad) DESC 
	) AS prod_mas_vendido_detalle

	,CASE WHEN (SELECT COUNT(	
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
LEFT JOIN Composicion compo ON compo.comp_producto = p.prod_codigo
GROUP BY cli.clie_codigo,cli.clie_razon_social
ORDER BY 3 DESC
		
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
		,FLOOR(SUM(item.item_cantidad))
FROM Cliente subcli
LEFT JOIN Factura f ON f.fact_cliente = subcli.clie_codigo AND YEAR(f.fact_fecha) = 2012
JOIN Item_Factura item ON f.fact_tipo = item.item_tipo AND f.fact_sucursal=item.item_sucursal AND f.fact_numero = item.item_numero
JOIN Producto subp ON subp.prod_codigo = item.item_producto
GROUP BY subcli.clie_codigo, subp.prod_detalle
ORDER BY 3 DESC 

/*2. Implementar una regla de negocio de validación en línea que permita
implementar una lógica de control de precios en las ventas. Se deberá
poder seleccionar una lista de rubros y aquellos productos de los rubros
que sean los seleccionados no podrán aumentar por mes más de un 2
%. En caso que no se tenga referencia del mes anterior no validar
dicha regla. */


