-- TODOS LOS PRODUCTOS (EM REALIDAD DECIMOS QUE UN COMBO TAMBIEN ES UN PRODUCTO)
SELECT * FROM Producto

-- VEMOS TODAS LAS COMPOSICIONES
SELECT * FROM Composicion
--ACA TENEMOS QUE TIENE UN comp_componente y un comp_producto
-- EN REALIDAD CON COMP_COMPONENTE ES ALGO MEDIO RECURSIVO, REPRESENTA A UN PRODUCTO(PERO COMO DECIAMOS UN PRODUCTO PUEDE TENER ADENTRO OTROS PRODUCTOS)
-- EN RESUMEN UN COMP_COMPENENTE ES EL COMPONENTE DE OTRO PRODUCTO
-- ENTONCES HACIENDO UN JOIN PRODUCTO PODEMOS VER COMO SE LLAMA A CADA PRODUCTO (EN UNA ESPECIE DE PRIMER NIVEL) 
SELECT  prod_codigo,
		prod_detalle AS comp_producto,
		comp_componente AS comp_componente,
		comp_cantidad AS comp_cantidad
		 FROM Composicion
JOIN Producto ON prod_codigo = comp_producto

-- COMO VEMOS TENEMOS QUE EL PRODUCTO 1104 POR EJEMPLO TIENE ADENTRO DOS PRODUCTOS MAS, EL 1109 Y EL 1123, PODRIA HACER OTRO JOIN PARA VER DE QUE PRODUCTOS SE TRATA
-- YA ESTARIAMOS VIENDO COMO EL SEGUNDO NIVEL DE LA TABLA (A QUE PRODUCTOS HACEN REFERENCIA LOS PRIMEROS PRODUCTOS DE LA TABLA)
SELECT  p1.prod_codigo AS lvl0_prod_codigo,
		p1.prod_detalle AS lvl0_comp_producto,
		c1.comp_cantidad AS lvl0_cantidad,
		p2.prod_codigo AS lvl1_prod_codigo,
		p2.prod_detalle AS lvl1_prod_detalle
		 FROM Composicion c1
LEFT JOIN Producto p1 ON p1.prod_codigo = c1.comp_producto
LEFT JOIN Producto p2 ON p2.prod_codigo =c1.comp_componente

-- ESTE SERIA NUESTRO PRIMER NIVEL Y TAL VEZ NOS CONVENGA HACER LEFT JOINS PARA QUE CUANDO PRODUCTO SEA FINAL (ES DECIR NO TENGA MAS PRODUCTOS COMPUESTOS ADENTRO) 
-- NOS APAREZCA NULL, SI DEJAMOS EL JOIN SOLO NOS APARECERIAN LOS PRODUCTOS QUE SI TIENEN MAS PRODUCTOS ADENTRO
-- AHORA VEREMOS NUESTRO NIVEL 2, ES DECIR QUE PRODUCTOS COMPONEN A NUESTROS PRODUCTOS DE NIVEL 1

SELECT  p1.prod_codigo AS lvl0_prod_codigo,
		p1.prod_detalle AS lvl0_comp_producto,
		p2.prod_codigo AS lvl1_prod_codigo,
		p2.prod_detalle AS lvl1_prod_detalle,
		c1.comp_cantidad AS lvl1_cantidad,
		p3.prod_codigo AS lvl2_prod_codigo,
		p3.prod_detalle AS lvl2_prod_detalle,
		c2.comp_cantidad AS lvl2_cantidad
		 FROM Composicion c1
LEFT JOIN Producto p1 ON p1.prod_codigo = c1.comp_producto
LEFT JOIN Producto p2 ON p2.prod_codigo =c1.comp_componente
LEFT JOIN Composicion c2 ON p2.prod_codigo = c2.comp_producto
LEFT JOIN Producto p3 ON p3.prod_codigo = c2.comp_componente


