USE GD2015C1
GO
/*1. Realizar una consulta SQL que muestre aquellos clientes que en 2
años consecutivos compraron.
De estos clientes mostrar
i. El código de cliente. !
ii. El nombre del cliente. !
iii. El numero de rubros que compro el cliente. !
iv. La cantidad de productos con composición que compro el cliente en el 2012. !

El resultado deberá ser ordenado por cantidad de facturas
del cliente en toda la historia, de manera ascendente.
Nota: No se permiten select en el from, es decir, select ... from (select ...) as T,*/

SELECT	c.clie_codigo
		,c.clie_razon_social
		,COUNT(DISTINCT r.rubr_detalle) as Rubros_comprados
		,(
			SELECT	COUNT(DISTINCT subcompo.comp_producto)
					FROM Cliente subc
					JOIN Factura subf ON subf.fact_cliente = subc.clie_codigo
					JOIN Item_Factura subit ON subit.item_tipo = subf.fact_tipo AND subit.item_sucursal = subf.fact_sucursal AND subit.item_numero = subf.fact_numero
					LEFT JOIN Composicion subcompo ON subcompo.comp_producto = subit.item_producto
					WHERE subc.clie_codigo = c.clie_codigo
			GROUP BY subc.clie_codigo
					
		) AS cant_prod_compo_2012
		FROM Cliente c
		JOIN Factura f ON f.fact_cliente = c.clie_codigo
		JOIN Item_Factura it ON it.item_tipo = f.fact_tipo AND it.item_sucursal = f.fact_sucursal AND it.item_numero = f.fact_numero
		JOIN Producto pr ON pr.prod_codigo = it.item_producto
		JOIN Rubro r ON r.rubr_id = pr.prod_rubro
		WHERE EXISTS (	SELECT 1	
								FROM Factura subf
								WHERE subf.fact_cliente = c.clie_codigo AND YEAR(subf.fact_fecha) IN (YEAR(f.fact_fecha)+1,YEAR(f.fact_fecha)-1)
						)
		GROUP BY c.clie_codigo, c.clie_razon_social
		ORDER BY (SELECT COUNT(fact_numero) FROM Factura WHERE fact_cliente = c.clie_codigo) ASC
GO
/*2. Implementar una regla de negocio para mantener siempre consistente
(actualizada bajo cualquier circunstancia) una nueva tabla llamada
PRODUCTOS_ VENDIDOS. En esta tabla debe registrar el periodo (YYYYMM),
el código de producto, el precio máximo de venta y las unidades vendidas.
Toda esta información debe estar por periodo
(YYYYMM).*/

CREATE TABLE PRODUCTOS_VENDIDOS (
	periodo CHAR(7),
	cod_prod CHAR(8),
	precio_max DECIMAL(18,2),
	u_vendidas INT,
)
GO
CREATE TRIGGER Ejercicio2 ON Factura AFTER UPDATE,INSERT
AS 
BEGIN
	declare @periodo CHAR(7)
	declare @cod_prod CHAR(8)
	declare @precio_max DECIMAL(18,2)
	declare @u_vendidas INT

	DECLARE curs CURSOR FOR SELECT 
			CONCAT(YEAR(i.fact_fecha),MONTH(i.fact_fecha))
			,it.item_producto
			,MAX(it.item_precio)
			,SUM(it.item_cantidad)
	FROM inserted i 
	JOIN Item_Factura it ON it.item_tipo = i.fact_tipo AND it.item_sucursal = i.fact_sucursal AND it.item_numero = i.fact_numero
	GROUP BY CONCAT(YEAR(i.fact_fecha),MONTH(i.fact_fecha)),it.item_producto

	OPEN curs 
	FETCH NEXT FROM curs INTO
	@periodo,
	@cod_prod,
	@precio_max,
	@u_vendidas

	WHILE @@FETCH_STATUS = 0
	BEGIN 
	IF EXISTS(SELECT 1 FROM PRODUCTOS_VENDIDOS pv WHERE pv.periodo = @periodo AND pv.cod_prod = @cod_prod)
	BEGIN
		DECLARE @precio_viejo DECIMAL(12,2)
		SET @precio_viejo = (SELECT precio_max FROM PRODUCTOS_VENDIDOS)

		IF(@precio_viejo > @precio_max)
		BEGIN
			UPDATE PRODUCTOS_VENDIDOS 
			SET u_vendidas = u_vendidas + @u_vendidas
			WHERE periodo = @periodo AND cod_prod = @cod_prod
			COMMIT
	END

	ELSE
	BEGIN
		UPDATE PRODUCTOS_VENDIDOS
		SET precio_max = @precio_max,
			u_vendidas = u_vendidas + @u_vendidas
		WHERE periodo = @periodo AND cod_prod = @cod_prod
		COMMIT
	END

	END
	ELSE
	BEGIN
	INSERT INTO PRODUCTOS_VENDIDOS VALUES(
	@periodo,
	@cod_prod,
	@precio_max,
	@u_vendidas
	)
	COMMIT
	END

	FETCH NEXT FROM curs INTO @periodo, @cod_prod, @precio_max, @u_vendidas
	END

	CLOSE curs
	DEALLOCATE curs


END -- Trigger


DROP TRIGGER Ejercicio2

-- Pruebas
INSERT INTO Factura(fact_cliente,)

SELECT * FROM Factura


