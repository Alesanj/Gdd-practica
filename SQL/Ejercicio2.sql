-- 2) Mostrar el código, detalle de todos los artículos vendidos en el año 2012 ordenados por
--	cantidad vendida.
use GD2015C1

SELECT
	producto.prod_codigo,
	producto.prod_detalle,
	sum(itemFactura.item_cantidad) as cantidad_vendida
FROM Producto producto 
	JOIN Item_Factura itemFactura ON producto.prod_codigo = itemFactura.item_producto 
	JOIN Factura factura ON itemFactura.item_tipo = factura.fact_tipo AND itemFactura.item_sucursal = factura.fact_sucursal AND itemFactura.item_numero = factura.fact_numero
WHERE year(factura.fact_fecha) = 2012
group by producto.prod_codigo,prod_detalle
ORDER BY cantidad_vendida ASC;
