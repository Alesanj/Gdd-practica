-- 1) Mostrar el código, razón social de todos los clientes cuyo límite de crédito sea mayor o
-- igual a $ 1000 ordenado por código de cliente.

use GD2015C1

select c.clie_codigo, 
	   c.clie_razon_social 
from Cliente c 
where c.clie_limite_credito >= 1000
order by c.clie_codigo ASC

-- Obtener productos con su familia y su rubro
SELECT 
	p.prod_codigo,
	p.prod_detalle,
	f.fami_detalle,
	r.rubr_detalle
from Producto p JOIN Familia f ON p.prod_familia = f.fami_id 
				JOIN Rubro r ON p.prod_rubro = r.rubr_id

-- Quiero obtener de todos los productos compuestos, el nombre del producto, el nombre del componente, la cantidad
Select 
	p1.prod_detalle,
	p2.prod_detalle,
	c1.comp_cantidad
FROM Composicion c1 JOIN Producto p1 ON c1.comp_producto = p1.prod_codigo 
					JOIN Producto p2 ON p2.prod_codigo = c1.comp_componente

-- Consulta que me devuelva codigo de empleado, nombre de empleado y el jefe
SELECT 
	e1.empl_codigo,
	e1.empl_nombre,
	j.empl_nombre
FROM Empleado e1 JOIN Empleado j ON e1.empl_jefe = j.empl_codigo;

Select * from Cliente 
