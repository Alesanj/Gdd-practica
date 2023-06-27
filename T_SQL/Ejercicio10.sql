-- 10. Crear el/los objetos de base de datos que ante el intento de borrar un artículo
-- verifique que no exista stock y si es así lo borre en caso contrario que emita un
-- mensaje de error.
USE GD2015C1
GO
--
--ELEMENTOS DE PRUEBA

INSERT INTO Producto(prod_codigo,prod_detalle)
	VALUES('M0000001','PRUEBA_TRIGGER')

INSERT INTO Producto(prod_codigo,prod_detalle)
	VALUES('M0000002','PRUEBA_TRIGGER2')
INSERT INTO STOCK(stoc_producto,stoc_deposito,stoc_cantidad)
	VALUES('M0000002','00',10)

SELECT * FROM Producto WHERE prod_codigo = 'M0000001'
SELECT * FROM Producto WHERE prod_codigo = 'M0000002'

SELECT * FROM STOCK WHERE stoc_producto = 'M0000001'
SELECT * FROM STOCK WHERE stoc_producto = 'M0000002'


GO
----------------------------------------------

ALTER TRIGGER Ejercicio10 --Funciona
ON Producto
INSTEAD OF DELETE AS 
BEGIN
	IF EXISTS(SELECT 1 
			FROM deleted 
			JOIN STOCK ON deleted.prod_codigo = STOCK.stoc_producto)
	BEGIN
	PRINT('NO SE PUEDE ELIMINAR ESTE PRODUCTO YA QUE TIENE STOCK ASOCIADO')
	ROLLBACK TRANSACTION
	RETURN
	END 

	DELETE FROM STOCK WHERE STOCK.stoc_producto IN (SELECT d.prod_codigo FROM deleted d);
	DELETE FROM Producto WHERE Producto.prod_codigo IN (SELECT d.prod_codigo FROM deleted d);
END

DELETE FROM Producto WHERE prod_codigo = 'M0000001'
DELETE FROM Producto WHERE prod_codigo = 'M0000002'

DELETE FROM Producto WHERE prod_codigo IN ('M0000001','M0000002')


GO
----------------------------------------------------
CREATE TRIGGER ejercicio10_PROFE
ON Producto
INSTEAD OF DELETE
AS
BEGIN
      IF EXISTS (SELECT 1 FROM STOCK s where s.stoc_producto IN 
	  (SELECT prod_codigo FROM deleted) AND isnull(s.stoc_cantidad,0) > 0)
	   BEGIN
	       ROLLBACK TRANSACTION
		   RETURN
       END

	  DELETE FROM STOCK where stoc_producto in (SELECT prod_codigo FROM deleted)
	  DELETE FROM Producto where prod_codigo in (SELECT prod_codigo FROM deleted)
END
