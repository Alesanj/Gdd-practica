-- Ejercicio de practica parcial 24/06/2023 Lacquantini

-- 1. Realizar una consulta SQL que permita saber si un cliente compro un producto en todos los meses del 2012.

-- Además, mostrar para el 2012: 

-- 1. El cliente
-- 2. La razón social del cliente
-- 3. El producto comprado
-- 4. El nombre del producto
-- 5. Cantidad de productos distintos comprados por el cliente.
-- 6. Cantidad de productos con composición comprados por el cliente.

-- El resultado deberá ser ordenado poniendo primero aquellos clientes que compraron más de 10 productos distintos en el 2012. 

-- Nota: No se permiten select en el from, es decir, select … from (select …) as T,...
USE GD2015C1
GO

SELECT 
    t_cliente.clie_codigo,
    t_cliente.clie_razon_social ,
    t_
    MONTH(t_factura.fact_fecha),
    YEAR(t_factura.fact_fecha),
    COUNT( MONTH(t_factura.fact_fecha)) as CANT
FROM Cliente t_cliente 
JOIN Factura t_factura ON t_factura.fact_cliente = t_cliente.clie_codigo
JOIN P
GROUP BY t_cliente.clie_codigo, MONTH(t_factura.fact_fecha), YEAR(t_factura.fact_fecha), CANT
HAVING YEAR(t_factura.fact_fecha) = 2012 AND COUNT( MONTH(t_factura.fact_fecha)) = 12
ORDER BY 1,2

JOIN Composicion t_composicion ON t_composicion.comp_producto = t_producto.prod_codigo


-- una resolucion

SELECT 
	cli.clie_codigo,
	clie_razon_social,
	p.prod_codigo,
	p.prod_detalle,
	(
		SELECT
			count(distinct ifac2.item_producto)
		FROM Factura f2
		JOIN Item_Factura ifac2
			ON f2.fact_sucursal = ifac2.item_sucursal
			AND f2.fact_numero = ifac2.item_numero
			AND f2.fact_tipo = ifac2.item_tipo
		WHERE year(f2.fact_fecha) = '2012'
				AND f2.fact_cliente = cli.clie_codigo
	) as cant_productos_distintos_cliente,
	(
		SELECT
			sum(ifac2.item_cantidad)
		FROM Factura f2
		JOIN Item_Factura ifac2
			ON f2.fact_sucursal = ifac2.item_sucursal
			AND f2.fact_numero = ifac2.item_numero
			AND f2.fact_tipo = ifac2.item_tipo
		JOIN Composicion com
			ON com.comp_producto = ifac2.item_producto
		WHERE year(f2.fact_fecha) = '2012'
				AND f2.fact_cliente = cli.clie_codigo
	) as cant_productos_composicion_cliente
FROM Cliente cli
JOIN Factura f
	ON cli.clie_codigo = f.fact_cliente
JOIN Item_Factura ifac
	ON f.fact_sucursal = ifac.item_sucursal
	AND f.fact_numero = ifac.item_numero
	AND f.fact_tipo = ifac.item_tipo
JOIN Producto p
	ON ifac.item_producto = p.prod_codigo
WHERE year(f.fact_fecha) = '2012'
GROUP BY
	cli.clie_codigo,
	clie_razon_social,
	p.prod_codigo,
	p.prod_detalle
HAVING
	count(distinct month(f.fact_fecha)) = 12
ORDER BY 	CASE WHEN 	(
		SELECT
			count(distinct ifac2.item_producto)
		FROM Factura f2
		JOIN Item_Factura ifac2
			ON f2.fact_sucursal = ifac2.item_sucursal
			AND f2.fact_numero = ifac2.item_numero
			AND f2.fact_tipo = ifac2.item_tipo
		WHERE year(f2.fact_fecha) = '2012'
				AND f2.fact_cliente = cli.clie_codigo
	) = 10 THEN 1 ELSE 0 END  DESC


    -- 2. Implementar una regla de negocio de validación en línea que permita implementar una lógica de control 
    -- de precios en las ventas. Se deberá poder seleccionar una lista de rubros y aquellos productos de los rubros 
    -- que sean los seleccionados no podrán aumentar por mes más de un 2 %. En caso que no se tenga referencia del mes
    --  anterior no validar dicha regla.

	-- Solucion 1
	ALTER TABLE Rubro ADD validar_incremento INT DEFAULT 0
GO

CREATE TRIGGER ej2_parcial
ON Item_Factura
AFTER INSERT, UPDATE
AS
BEGIN
	DECLARE @precio_comprado DECIMAL(12,2)
	DECLARE @prod_comprado CHAR(8)
	DECLARE @item_tipo CHAR(1)
	DECLARE @item_sucursal CHAR(4)
	DECLARE @item_numero CHAR(8)
	DECLARE @item_cantidad DECIMAL(12,2)
	
	DECLARE @precio_item_mes_pasado DECIMAL(12,2)

	DECLARE mi_cursor_ej2_parcial CURSOR
	FOR
		SELECT 
			item_producto,
			item_precio,
			item_tipo,
			item_sucursal,
			item_numero,
			item_cantidad
		FROM inserted i
		JOIN Producto p
			ON p.prod_codigo = i.item_producto
		JOIN Rubro r
			ON r.rubr_id = p.prod_rubro
		WHERE r.validar_incremento = 1

	OPEN mi_cursor_ej2_parcial

	FETCH mi_cursor_ej2_parcial INTO
		@prod_comprado,
		@precio_comprado,
		@item_tipo,
		@item_sucursal,
		@item_numero,
		@item_cantidad
	

	WHILE @@FETCH_STATUS = 0
	BEGIN
		

		SET @precio_item_mes_pasado = (
										SELECT 
											avg(ifac.item_precio)
										FROM Factura f
										JOIN Item_Factura ifac
											ON f.fact_sucursal = ifac.item_sucursal
											AND f.fact_numero = ifac.item_numero
											AND f.fact_tipo = ifac.item_tipo
										WHERE ifac.item_producto = @prod_comprado
										AND MONTH(f.fact_fecha) = MONTH(DATEADD(month, -1, GETDATE()))
										AND YEAR(f.fact_fecha) = YEAR(DATEADD(month, -1, GETDATE()))
										)

		
			IF (@precio_item_mes_pasado IS NOT NULL) AND (@precio_comprado / @precio_item_mes_pasado * 100) > 102
				BEGIN
					PRINT ('Se ha superado el límite máximo de aumento de un producto')
					DELETE FROM Item_Factura WHERE item_tipo = @item_tipo AND item_sucursal = @item_sucursal AND item_numero = @item_numero
					DELETE FROM Factura WHERE fact_tipo = @item_tipo AND fact_sucursal = @item_sucursal AND fact_numero = @item_numero
				END

		FETCH mi_cursor_ej2_parcial INTO
		@prod_comprado,
		@precio_comprado,
		@item_tipo,
		@item_sucursal,
		@item_numero,
		@item_cantidad
	END

	CLOSE mi_cursor_ej2_parcial
	DEALLOCATE mi_cursor_ej2_parcial

END

-- Solucionn 2

ALTER TRIGGER control_precio
ON Item_Factura
AFTER INSERT, UPDATE
AS
BEGIN TRANSACTION
	
	IF EXISTS(
		SELECT 1 FROM inserted
		JOIN Producto p on p.prod_codigo = item_producto
		JOIN Rubro_Validacion_Precios on rubr_id = prod_rubro
		WHERE item_precio > (
			(SELECT AVG(i.item_precio * 1.2) FROM Item_Factura i
			JOIN Factura f ON  f.fact_numero = i.item_numero AND f.fact_sucursal = i.item_sucursal AND f.fact_tipo = i.item_tipo
			WHERE	i.item_producto = p.prod_codigo AND
					MONTH(f.fact_fecha) = MONTH(DATEADD(MONTH,-1,f.fact_fecha)) AND
					YEAR(f.fact_fecha) = YEAR(DATEADD(MONTH,-1,f.fact_fecha)) AND
					i.item_precio IS NOT NULL 
			)
		)
	)
	BEGIN 
		ROLLBACK
		RETURN
	END
COMMIT
