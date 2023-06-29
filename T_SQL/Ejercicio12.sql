USE GD2015C1
GO
/*

12. Cree el/los objetos de base de datos necesarios para que nunca un producto
pueda ser compuesto por s� mismo. Se sabe que en la actualidad dicha regla se
cumple y que la base de datos es accedida por n aplicaciones de diferentes tipos
y tecnolog�as. No se conoce la cantidad de niveles de composici�n existentes.

*/


--Creo que esta primer solucion en realidad solo sirve para verificar que no haya repeticiones en el primer nivel
CREATE TRIGGER ejercicio12
ON Composicion 
AFTER INSERT AS
BEGIN
	IF EXISTS ( 
		SELECT 1 FROM 
		inserted i 
		JOIN Producto p1 ON p1.prod_codigo = i.comp_componente
		JOIN Composicion c2 ON c2.comp_producto = p1.prod_codigo
		WHERE c2.comp_componente = i.comp_producto
	)
	BEGIN
		ROLLBACK
		RETURN
	END

END
GO

-- Recursividad? SolucionV2 - Sin terminar

CREATE PROCEDURE verificarComposicion(@productoId CHAR(8), @prodComponente CHAR(8))
AS BEGIN
	IF (@productoId = @prodComponente OR @productoId IN (SELECT id_producto FROM #ProductosVerificados))
		RETURN 0;
	
	WITH CTE_Componentes AS (
		SELECT comp_componente
		FROM Composicion
		WHERE comp_producto = @prodComponente
	)
	INSERT INTO #ProductosVerificados(id_producto)
	VALUES (@prodComponente)

END

CREATE TRIGGER ejercicio12v2
ON Composicion 
AFTER INSERT AS
BEGIN
	SELECT dbo.verificarComposicion(i.comp_producto,i.comp_componente) FROM inserted i

END
GO

-- Elementos de prueba 
SELECT * FROM Producto WHERE prod_codigo = 'M0000001';
SELECT * FROM Producto WHERE prod_codigo = 'M0000002';
SELECT * FROM Composicion where comp_producto = 'M0000001'
INSERT INTO Composicion (comp_producto,comp_componente,comp_cantidad)VALUES ('M0000001','M0000001',2) --no deberia funcionar
INSERT INTO Composicion (comp_producto,comp_componente,comp_cantidad)VALUES ('M0000001','M0000002',3) -- deberia funcionar
GO
-- Solucion V3 (funciona) creo una tabla temporal donde voy almacenando los valores de todos los componentes en todos los niveles y luego verifico que mi prod
-- inicial no se encuentre ahi
-- La variable @@ROWCOUNT nos dice la cantidad de elementos que se afectaraon por un (UPDATE/INSERT/DELET) 
-- Entonces puedo usar esto para ver que siempre haya mas niveles para revisar, no se inserten mas elementos en la tabla temporal es porque no habia mas niveles
ALTER TRIGGER ejercicio12v3
ON Composicion 
AFTER INSERT AS
BEGIN
	CREATE TABLE #TempTableComponentes(
	id_componente CHAR(8),
	nivel int
	)
	DECLARE @Cantidad int;
	DECLARE @NivelActual int;

	SET @NivelActual = 0 ;

	IF EXISTS (SELECT 1 FROM inserted WHERE comp_producto = comp_componente)
	BEGIN
		ROLLBACK;
		RETURN;
	END
	INSERT INTO #TempTableComponentes(id_componente,nivel)
	SELECT i.comp_producto,0
	FROM inserted i
	INNER JOIN Composicion c1 on i.comp_producto = c1.comp_producto
	SET @Cantidad = 1;

	WHILE @Cantidad > 0
	BEGIN
		INSERT INTO #TempTableComponentes(id_componente,nivel)
		SELECT comp.comp_componente, @NivelActual + 1
		FROM #TempTableComponentes temp
		INNER JOIN Composicion comp ON comp.comp_producto = temp.id_componente
		WHERE temp.nivel = @NivelActual
		
		SET @NivelActual = @NivelActual + 1;
		SET @Cantidad = @@ROWCOUNT
		print(@Cantidad) 
	END

	IF EXISTS(SELECT 1 FROM inserted i WHERE i.comp_producto IN (SELECT temp.id_componente FROM #TempTableComponentes temp))
	BEGIN
		ROLLBACK;
		RETURN;
	END;
END
GO

-- SOLUCION PROFE
CREATE TRIGGER ejercicio12_profe ON Composicion AFTER INSERT, UPDATE AS 
BEGIN
	IF UPDATE(comp_producto) or UPDATE(comp_componente) 
	BEGIN 
		DECLARE @cantidad INT = 1 
		DECLARE @nivel INT = 0
	
		CREATE TABLE #tr_composicion (
		componente char(8)
		 nivel int
		 )

		IF EXISTS (SELECT 1 FROM inserted WHERE comp_producto = comp_componente)
		BEGIN
			ROLLBACK TRANSACTION
			RETURN
		END
		INSERT INTO #tr_composicion
		SELECT comp_componente, @nivel
		FROM inserted

		WHILE @cantidad > 0
		BEGIN
			INSERT INTO #tr_composicion
			SELECT comp_componente, @nivel + 1
			FROM Composicion c 
			INNER JOIN #tr_composicion t ON t.componente = c.comp_producto
			WHERE t.nivel = @nivel

			SET @cantidad = @@ROWCOUNT
			SET @nivel = @nivel + 1

		END -- WHILE

		IF EXISTS (SELECT 1 FROM inserted i INNER JOIN #tr_composicion t ON i.comp_producto = t.componente)
		BEGIN
			ROLLBACK TRANSACTION
			RETURN
		END
	END -- IF PPAL
END --TRIGGER