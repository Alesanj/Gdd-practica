/*
3. Cree el/los objetos de base de datos necesarios para implantar la siguiente regla
“Ningún jefe puede tener un salario mayor al 20% de las suma de los salarios de
sus empleados totales (directos + indirectos)”. Se sabe que en la actualidad dicha
regla se cumple y que la base de datos es accedida por n aplicaciones de
diferentes tipos y tecnologías*/USE GD2015C1
GOCREATE TRIGGER Ejercicio13V1 -- Sin terminarON EmpleadoAFTER INSERT ASBEGIN	CREATE TABLE #empleados(	empleado numeric(6,0),	nivel int,	)	INSERT INTO #empleados(empleado,nivel)	SELECT * FROM inserted i	JOIN Empleado e2 ON e2.empl_jefe = i.empl_codigo	WHERE i.empl_jefe IS NOT NULL	IF EXISTS (SELECT FROM inserted i)		END	GOCREATE TRIGGER ejercicio13_profe
ON Empleado
AFTER INSERT, UPDATE
AS BEGIN
IF UPDATE(empl_codigo) or UPDATE(empl_jefe) or UPDATE(empl_salario)
BEGIN
DECLARE @cantidad INT
DECLARE @nivel INT = 0
DECLARE @salarioMaximo DECIMAL(12,2)
CREATE TABLE #tr_empleado
(supervisado numeric(6,0),
nivel int)
IF EXISTS (SELECT 1 FROM inserted WHERE empl_codigo = empl_jefe)
BEGIN
	ROLLBACK TRANSACTION
	RETURN
END

INSERT INTO #tr_empleado
SELECT empl_jefe, @nivel
FROM inserted
WHERE empl_jefe IS NOT NULL

SET @cantidad = @@ROWCOUNT
WHILE @cantidad > 0
BEGIN
	INSERT INTO #tr_empleado
	SELECT e.empl_jefe, @nivel + 1
	FROM Empleado e INNER JOIN #tr_empleado t ON t.supervisado = e.empl_codigo
	WHERE t.nivel = @nivel AND e.empl_jefe IS NOT NULL
	SET @cantidad = @@ROWCOUNT
	SET @nivel = @nivel + 1
END -- WHILE

SELECT @salarioMaximo = MAX(empl_salario) FROM empleado e INNER JOIN #tr_empleado t ON e.empl_codigo = t.supervisado
IF EXISTS (SELECT 1 FROM inserted i where i.empl_salario * 1.2 > @salarioMaximo)
BEGIN
ROLLBACK TRANSACTION
RETURN
END
END -- IF PPAL
END -- TRIGGER