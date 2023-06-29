/*6. Mostrar para todos los rubros de art�culos c�digo, detalle, cantidad de art�culos de ese
rubro y stock total de ese rubro de art�culos. Solo tener en cuenta aquellos art�culos que
tengan un stock mayor al del art�culo �00000000� en el dep�sito �00�.*/
SELECT	r.rubr_id
		,r.rubr_detalle 
		,COUNT(r.rubr_id) AS cant_articulos
		,ISNULl((
			SELECT 
			SUM(stoc_cantidad)
			FROM Rubro subr
			JOIN Producto subpr ON subpr.prod_rubro = subr.rubr_id
			JOIN STOCK ON stoc_producto = subpr.prod_codigo
			WHERE subr.rubr_id = r.rubr_id
			GROUP BY (subr.rubr_id) 
		),0) AS cant_stock
		FROM Rubro r
JOIN Producto pr ON pr.prod_rubro = r.rubr_id
GROUP BY r.rubr_id, r.rubr_detalle
HAVING ISNULl((
			SELECT 
			SUM(stoc_cantidad)
			FROM Rubro subr
			JOIN Producto subpr ON subpr.prod_rubro = subr.rubr_id
			JOIN STOCK ON stoc_producto = subpr.prod_codigo
			WHERE subr.rubr_id = r.rubr_id
			GROUP BY (subr.rubr_id) 
		),0) > (SELECT stoc_cantidad FROM STOCK WHERE stoc_producto = '00000000' AND stoc_deposito = '00')
ORDER BY 1