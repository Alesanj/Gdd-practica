/*
1. Realizar una consulta SOL que retorne para los 10 clientes que más
compraron en el 2012 y que fueron atendldos por más de 3 vendedores
distintos:

• Apellido y Nombro del Cliento.
• Cantidad de Productos distmtos comprados en el 2012,
• Cantidad de unidades compradas dentro del pomer semestre del 2012.

•El resultado deberá mostrar ordenado ta cantidad de ventas descendente
	del 2012 de cada cliente, en caso de igualdad de ventasi ordenar porcódigo de cliente.

NOTA: No se permite el uso de sub-setects en el FROM ni funciones definidas por el usuario para este punto,
*/

SELECT TOP 10 c.clie_codigo
		,c.clie_razon_social
		,SUM(DISTINCT it.item_cantidad) AS cant_comprada
		,COUNT(DISTINCT it.item_producto) AS cant_prod_dist
		,(
			SELECT SUM(subit.item_cantidad)
			FROM Cliente subc 
			JOIN Factura subf ON subf.fact_cliente = subc.clie_codigo
			JOIN Item_Factura subit ON subit.item_tipo = subf.fact_tipo AND subit.item_sucursal = subf.fact_sucursal AND subit.item_numero = subf.fact_numero AND YEAR(subf.fact_fecha) = 2012 AND MONTH(subf.fact_fecha) <= 6
			WHERE subc.clie_codigo = c.clie_codigo
			GROUP BY subc.clie_codigo
		) AS cant_comprada_primer_semestre
		,COUNT (DISTINCT c.clie_vendedor) AS cant_vendedores
		, COUNT(DISTINCT f.fact_numero) cant_ventas
FROM Cliente c
JOIN Factura f ON f.fact_cliente = c.clie_codigo
JOIN Item_Factura it ON it.item_tipo = f.fact_tipo AND it.item_sucursal = f.fact_sucursal AND it.item_numero = f.fact_numero AND YEAR(f.fact_fecha) = 2012
GROUP BY c.clie_codigo, c.clie_razon_social
ORDER BY SUM(it.item_cantidad) DESC, c.clie_codigo

SELECT TOP 10
 	c.clie_razon_social,
 	COUNT(DISTINCT itf.item_producto) AS 'Cantidad de productos',
 	SUM(
 		CASE
	 		WHEN MONTH(f.fact_fecha) <= 6 THEN itf.item_cantidad
	 		ELSE 0
	 	END
 	) as 'Unidades compradas'
	,COUNT(DISTINCT f.fact_vendedor)
 FROM Factura f 
 JOIN Cliente c ON c.clie_codigo = f.fact_cliente
 JOIN Item_Factura itf ON itf.item_numero = f.fact_numero
 WHERE
 	YEAR(f.fact_fecha) = 2012
 GROUP BY c.clie_codigo, c.clie_razon_social
 -- HAVING COUNT(DISTINCT f.fact_vendedor) > 3
 ORDER BY SUM(itf.item_cantidad) DESC, c.clie_codigo
 GO

 SELECT *
		FROM Producto p
		JOIN Item_Factura it ON p.prod_codigo = it.item_producto
		JOIN Factura f ON f.fact_tipo = it.item_tipo AND f.fact_sucursal = it.item_sucursal AND f.fact_numero = it.item_numero
GO
 /* Stored procedure que reciba un codigo de prod y una fdehca y devuelva la mayor cantidad de dias consecutivos a partir de esa fecha, que el producto 
 tuvo al menos la venta de una unidad en el dia, el sistema de ventas esta online 24/7 por lo que se debe evaular todos los dias incluyendo feriados*/
 -- Supongo que deberia contar la cantidad de dias consecutivos hasta que no ya hubo una venta, de lo contrario tendria que recorrer hasta la fecha del dia de hoy?
 CREATE FUNCTION TuvoAlMenosUnaVentaEnElDia(@prod_codigo CHAR(8), @fecha DATE) RETURNS BIT
 AS BEGIN
	DECLARE @cantidad INT
	SET @cantidad = 0

		SELECT @cantidad = COUNT(DISTINCT p.prod_codigo)
		FROM Producto p
		JOIN Item_Factura it ON p.prod_codigo = it.item_producto
		JOIN Factura f ON f.fact_tipo = it.item_tipo AND f.fact_sucursal = it.item_sucursal AND f.fact_numero = it.item_numero
		WHERE f.fact_fecha = @fecha

	DECLARE @tuvo_venta BIT
	SET @tuvo_venta = CASE WHEN @cantidad > 0 THEN 1 ELSE 0 END
	RETURN @tuvo_venta
 END
 GO

 CREATE PROCEDURE cantidad_dias_consecutivos(@prod_codigo CHAR(8), @fecha DATE)
 AS BEGIN
	DECLARE @cant_max_dias_consecutivos INT
	SET @cant_max_dias_consecutivos = 0

	DECLARE @tuvo_venta BIT
	SET @tuvo_venta = 1

	WHILE dbo.TuvoAlMenosUnaVentaEnElDia(@prod_codigo,@fecha) = 1
	BEGIN
		WHILE @tuvo_venta = 1
		BEGIN
		DECLARE @dias_consecutivos INT
		SET @dias_consecutivos = 0

		IF(dbo.TuvoAlMenosUnaVentaEnElDia(@prod_codigo, @fecha) = 1)
		BEGIN 
			SET @dias_consecutivos = @dias_consecutivos + 1		
			SET @fecha = DATEADD(DAY,1,@FECHA)
		END
		ELSE 
		BEGIN 
			IF (@dias_consecutivos > @cant_max_dias_consecutivos)
				SET @cant_max_dias_consecutivos = @dias_consecutivos
		END
	END
 END