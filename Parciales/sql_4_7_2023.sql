/*1. (4/7/2023)
Se solicita estadística por Año y familia, para ello se deberá mostrar.
Año, Código de familia, Detalle de familia, cantidad de facturas, cantidad
de productos con COmposición vendidOs, monto total vendido.
 Solo se deberán considerar las familias que tengan al menos un producto con
composición y que se hayan vendido conjuntamente (en la misma factura)
con otra familia distinta.
NOTA: No se permite el uso de sub-selects en el FROM ni funciones
definidas por el usuario para este punto,
*/

SELECT	YEAR(f.fact_fecha)
		,fam.fami_id
		,fam.fami_detalle
		,COUNT(DISTINCT f.fact_numero) AS cant_facturas
		,ISNULL((
				SELECT 
				COUNT(DISTINCT subcompo.comp_producto)
				FROM Factura subf
				JOIN Item_Factura subit ON subit.item_sucursal = subf.fact_sucursal AND subit.item_tipo = subf.fact_tipo AND subit.item_numero = subf.fact_numero
				JOIN Producto subp ON subit.item_producto = subp.prod_codigo
				JOIN Familia subfam ON subfam.fami_id = subp.prod_familia
				JOIN Composicion subcompo ON subcompo.comp_producto = subp.prod_codigo
				WHERE subfam.fami_id = fam.fami_id AND YEAR(subf.fact_fecha) = YEAR(f.fact_fecha)
				GROUP BY 
				YEAR(subf.fact_fecha), subfam.fami_id
		),0)
		,SUM(f.fact_total) AS MONTO_TOTAL
		FROM Factura f
		JOIN Item_Factura it ON it.item_sucursal = f.fact_sucursal AND it.item_tipo = f.fact_tipo AND it.item_numero = f.fact_numero
		JOIN Producto p ON it.item_producto = p.prod_codigo
		JOIN Familia fam ON fam.fami_id = p.prod_familia
		GROUP BY 
		YEAR(f.fact_fecha)
		,fam.fami_id
		,fam.fami_detalle
		HAVING (
				SELECT 
					COUNT(DISTINCT subcompo.comp_producto)
				FROM Factura subf
				JOIN Item_Factura subit ON subit.item_sucursal = subf.fact_sucursal AND subit.item_tipo = subf.fact_tipo AND subit.item_numero = subf.fact_numero
				JOIN Producto subp ON subit.item_producto = subp.prod_codigo
				JOIN Familia subfam ON subfam.fami_id = subp.prod_familia
				JOIN Composicion subcompo ON subcompo.comp_producto = subp.prod_codigo
				WHERE subfam.fami_id = fam.fami_id AND YEAR(subf.fact_fecha) = YEAR(f.fact_fecha)
				GROUP BY 
				YEAR(subf.fact_fecha), subfam.fami_id
		) >= 1
