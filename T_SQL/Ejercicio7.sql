/*
7. Hacer un procedimiento que dadas dos fechas complete la tabla Ventas. Debe
insertar una línea por cada artículo con los movimientos de stock generados por
las ventas entre esas fechas. La tabla se encuentra creada y vacía.

*/
USE GD2015C1
GO

ALTER PROCEDURE Ejercicio7V1(@fecha1 NVARCHAR, @fecha2 NVARCHAR) 
AS
BEGIN
	DECLARE @Convertido1 smalldatetime;
	DECLARE @Convertido2 smalldatetime;

	SET @Convertido1 = CONVERT(datetime,@fecha1, 120)
	SET @Convertido2 = CONVERT(datetime,@fecha2, 120)

	CREATE TABLE #VENTAS( 
	codigo int IDENTITY PRIMARY KEY,
	detalle char(50),
	cantidad_mov decimal(12,2),
	precio_venta decimal(12,2),
	renglon int,
	ganancia decimal(12,2)
	)

	INSERT INTO #VENTAS(codigo,detalle,cantidad_mov,precio_venta,renglon,ganancia)
	SELECT	item.item_producto, 
			pr.prod_detalle,
			sum(item.item_cantidad),
			avg(item.item_precio),
			(ROW_NUMBER() OVER (ORDER BY item.item_producto)) AS RN,
			f.fact_total - (item.item_cantidad * item.item_precio)
	FROM Factura f
	JOIN  Item_Factura item ON f.fact_tipo = item.item_tipo and f.fact_sucursal = item.item_sucursal and f.fact_numero = item.item_numero
	JOIN Producto pr ON pr.prod_codigo = item_producto
	WHERE f.fact_fecha BETWEEN @Convertido1 AND @Convertido2
	-- WHERE f.fact_fecha BETWEEN @fecha1 AND @fecha2
	GROUP BY item.item_producto, pr.prod_detalle,f.fact_total,item.item_cantidad,item.item_precio
	SELECT * FROM #VENTAS
	DROP TABLE #VENTAS

--	2010-01-23 00:00:00
--	2010-10-29 00:00:00
END
GO
EXEC Ejercicio7V1 '2010-01-23 00:00:00','2010-10-29 00:00:000'



CREATE PROCEDURE Ejercicio7_profe (@fechaDesde date, @fechaHasta date)
AS
BEGIN
DELETE FROM ejercicio7
INSERT INTO ejercicio7 (renglon, prod_codigo, prod_detalle, movimientos, promedio)
SELECT ROW_NUMBER() OVER (ORDER BY p.prod_codigo) AS renglon,
p.prod_codigo, p.prod_detalle, SUM(i.item_cantidad) AS movimientos,
SUM(i.item_precio * i.item_cantidad) / SUM(i.item_cantidad) AS precioPromedio
FROM PRODUCTO p INNER JOIN Item_Factura i ON p.prod_codigo = i.item_producto
INNER JOIN Factura f ON f.fact_tipo = i.item_tipo and f.fact_sucursal = i.item_sucursal and f.fact_numero = i.item_numero
WHERE f.fact_fecha BETWEEN CONVERT(smalldatetime, '2010-01-23 00:00:00', 120) AND CONVERT(smalldatetime,'2010-10-29 00:00:000', 120)
GROUP BY p.prod_codigo, p.prod_detalle
END -- PROCEDURE}