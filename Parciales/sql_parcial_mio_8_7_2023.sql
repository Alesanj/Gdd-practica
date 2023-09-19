USE GD2015C1
GO

/* Se pide que realice un reporte generado por una sola query que de cortes de informacion por periodos
(anual,semestral y bimestral). Un corte por el año, un corte por el semestre el año y un corte por bimestre el año. 
En el corte por año mostrar las ventas totales realizadas por año, la cantidad de rubros distintos comprados por año, 
la cantidad de productos con composicion distintos comporados por año y la cantidad de clientes que compraron por año.
Luego, en la informacion del semestre mostrar la misma informacion, es decir, las ventas totales por semestre, cantidad de rubros 
por semestre, etc. y la misma logica por bimestre. El orden tiene que ser cronologico.
*/

SELECT	'Anual' AS TIPO
		,YEAR(f.fact_fecha) as Intervalo
		,SUM(f.fact_total) AS TOTAL
		,COUNT(f.fact_cliente) AS Clientes -- No se me pide la cantidad de clientes distintos
		, (SELECT COUNT(DISTINCT subr.rubr_id) 
					FROM Rubro subr
					JOIN Producto subpr ON subpr.prod_rubro = subr.rubr_id
					JOIN Item_Factura subit ON subit.item_producto = subpr.prod_codigo
					JOIN Factura subf ON subf.fact_sucursal = subit.item_sucursal AND subf.fact_tipo = subit.item_tipo AND subf.fact_numero = subit.item_numero 
					WHERE YEAR(subf.fact_fecha) = YEAR(f.fact_fecha)
		) AS Cant_rubros_dist
		,(SELECT COUNT(DISTINCT subcompo.comp_producto) 
					FROM Rubro subr
					JOIN Producto subpr ON subpr.prod_rubro = subr.rubr_id
					JOIN Item_Factura subit ON subit.item_producto = subpr.prod_codigo
					JOIN Factura subf ON subf.fact_sucursal = subit.item_sucursal AND subf.fact_tipo = subit.item_tipo AND subf.fact_numero = subit.item_numero 
					JOIN Composicion subcompo ON subcompo.comp_producto = subpr.prod_codigo
					WHERE YEAR(subf.fact_fecha) = YEAR(f.fact_fecha)
		) as Productos_comp
		FROM Factura f
		GROUP BY YEAR(f.fact_fecha)
UNION
SELECT	'Bimestral' AS TIPO
		,FLOOR((DATEPART(MONTH, f.fact_fecha) + 1) / 2.0) AS Intervalo
		,SUM(f.fact_total) AS TOTAL
		,COUNT(f.fact_cliente) AS Clientes -- No se me pide la cantidad de clientes distintos
		, (SELECT COUNT(DISTINCT subr.rubr_id) 
					FROM Rubro subr
					JOIN Producto subpr ON subpr.prod_rubro = subr.rubr_id
					JOIN Item_Factura subit ON subit.item_producto = subpr.prod_codigo
					JOIN Factura subf ON subf.fact_sucursal = subit.item_sucursal AND subf.fact_tipo = subit.item_tipo AND subf.fact_numero = subit.item_numero 
					WHERE FLOOR((DATEPART(MONTH, subf.fact_fecha) + 1) / 2.0) = FLOOR((DATEPART(MONTH, f.fact_fecha) + 1) / 2.0) AND YEAR(subf.fact_fecha) = YEAR(f.fact_fecha)

		) AS Cant_rubros_dist
		,(SELECT COUNT(DISTINCT subcompo.comp_producto) 
					FROM Rubro subr
					JOIN Producto subpr ON subpr.prod_rubro = subr.rubr_id
					JOIN Item_Factura subit ON subit.item_producto = subpr.prod_codigo
					JOIN Factura subf ON subf.fact_sucursal = subit.item_sucursal AND subf.fact_tipo = subit.item_tipo AND subf.fact_numero = subit.item_numero 
					JOIN Composicion subcompo ON subcompo.comp_producto = subpr.prod_codigo
					WHERE FLOOR((DATEPART(MONTH, subf.fact_fecha) + 1) / 2.0) = FLOOR((DATEPART(MONTH, f.fact_fecha) + 1) / 2.0) AND YEAR(subf.fact_fecha) = YEAR(f.fact_fecha)
		) as Productos_comp
		FROM Factura f
		GROUP BY DATEPART (YEAR, fact_fecha),FLOOR((DATEPART(MONTH, f.fact_fecha) + 1) / 2.0)
UNION
SELECT	'SEMESTRAL' AS TIPO
		,FLOOR((DATEPART(MONTH, f.fact_fecha) + 5) / 6.0) AS Intervalo
		,SUM(f.fact_total) AS TOTAL
		,COUNT(f.fact_cliente) AS Clientes -- No se me pide la cantidad de clientes distintos
		, (SELECT COUNT(DISTINCT subr.rubr_id) 
					FROM Rubro subr
					JOIN Producto subpr ON subpr.prod_rubro = subr.rubr_id
					JOIN Item_Factura subit ON subit.item_producto = subpr.prod_codigo
					JOIN Factura subf ON subf.fact_sucursal = subit.item_sucursal AND subf.fact_tipo = subit.item_tipo AND subf.fact_numero = subit.item_numero 
					WHERE FLOOR((DATEPART(MONTH, f.fact_fecha) + 5) / 6.0) = FLOOR((DATEPART(MONTH, f.fact_fecha) + 5) / 6.0) AND YEAR(subf.fact_fecha) = YEAR(f.fact_fecha)

		) AS Cant_rubros_dist
		,(SELECT COUNT(DISTINCT subcompo.comp_producto) 
					FROM Rubro subr
					JOIN Producto subpr ON subpr.prod_rubro = subr.rubr_id
					JOIN Item_Factura subit ON subit.item_producto = subpr.prod_codigo
					JOIN Factura subf ON subf.fact_sucursal = subit.item_sucursal AND subf.fact_tipo = subit.item_tipo AND subf.fact_numero = subit.item_numero 
					JOIN Composicion subcompo ON subcompo.comp_producto = subpr.prod_codigo
					WHERE FLOOR((DATEPART(MONTH, f.fact_fecha) + 5) / 6.0) = FLOOR((DATEPART(MONTH, f.fact_fecha) + 5) / 6.0) AND YEAR(subf.fact_fecha) = YEAR(f.fact_fecha)
		) as Productos_comp
		FROM Factura f
		GROUP BY DATEPART (YEAR, fact_fecha),FLOOR((DATEPART(MONTH, f.fact_fecha) + 5) / 6.0)