-- 3. Realizar una consulta que muestre código de producto, nombre de producto y el stock
-- total, sin importar en que deposito se encuentre, los datos deben ser ordenados por
-- nombre del artículo de menor a mayor

--Tablas a trabajar: Producto, Stock, al no tener en cuenta a deposito 
use GD2015C1
GO

SELECT * FROM Producto;

SELECT producto.prod_codigo, 
	   producto.prod_detalle, 
	   SUM(stock.stoc_cantidad)
FROM Producto producto 
	INNER JOIN Stock stock ON producto.prod_codigo = stock.stoc_producto -- Hasta aca me devolveria una tabla con todos los productos y sus cantidades pero separadas por oficina
GROUP BY producto.prod_codigo, producto.prod_detalle					 -- Aca estaria como unificando por codigo y detalle, sin importarme el deposito y sumando la agrpacion que me queda
ORDER BY producto.prod_detalle ASC;