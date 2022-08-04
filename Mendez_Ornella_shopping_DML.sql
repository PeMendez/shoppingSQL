--1. Busque los id, nombre y tel�fono de los empleados cuya contacto no est� cargado o tiene el correo cargar@despues.com para as� poder contactarlos.

SELECT e.id, e.nombre, e.telefono 
FROM empleado e
JOIN informacion_medica m ON e.inf_medica = m.id  
WHERE contacto_emergencia IS NULL OR contacto_emergencia = 'cargar@despues.com' ;

--2. Conseguir la informaci�n de contacto de aquellos clientes que son mayores de 50 o compraron productos de tipo �Tercera edad�.

SELECT c.nombre, c.telefono, date_part('year',age(fecha_nac)), p.tipo 
FROM cliente c 
JOIN venta v ON c.id = v.cliente 
JOIN producto p ON v.producto = p.id 
WHERE date_part('year',age(fecha_nac))> 50 OR p.tipo = 'Tercera Edad' ;

--3. Cantidad de ventas hechas este a�o de producto de tipo �Perfume� y el precio promedio que se dio entre todas las tiendas

SELECT p.tipo, COUNT(venta) AS cant_ventas, round(avg(precio - descuentos),2)  AS precio_promedio 
FROM venta 
JOIN producto p ON producto = p.id 
WHERE extract('year' from fecha) = '2020' AND tipo = 'Perfume' 
GROUP BY p.tipo ;

--4. Obtener aquellos empleados que tengan como grupo sangu�neo O- ordenados por apellido y por tienda de forma ascendente

SELECT e.* 
FROM empleado e
JOIN informacion_medica i ON e.inf_medica = i.id 
WHERE grupo_sanguineo = '0-'
ORDER BY nombre ASC, id_tienda ASC ;

--5. Seleccione aquellas camisas cuyo precio superen los $ 800 que no hayan sido vendidas en el mes de octubre 2020.

SELECT p.* 
FROM producto p
WHERE tipo = 'Camisa' AND precio > 800
EXCEPT 
SELECT p.* 
FROM producto p
JOIN venta ON id = producto 
WHERE tipo = 'Camisa' AND extract('year' from fecha) = '2020' AND extract('month' from fecha) = '08' ;

--6. Seleccione aquellas tiendas que hayan realizado un descuento de 50% sobre sandalias 'El pie fresco' � �La separadedos� y que ademas haya hecho descuentos en cualquier zapatilla

SELECT t.* 
FROM tienda t
JOIN producto p ON t.id = p.tienda 
JOIN venta v ON p.id = v.producto 
WHERE v.descuentos = p.precio / 2 AND p.nombre = 'El pie fresco' OR p.nombre = 'el separadedos'
INTERSECT 
SELECT t.*
FROM tienda t
JOIN producto p ON t.id = p.tienda 
JOIN venta v ON p.id = v.producto 
WHERE v.descuentos IS NOT NULL AND p.tipo = 'Zapatilla' ;

--7. Seleccione aquellas tiendas que vendan trajes, pero no corbatas

SELECT t.*
FROM tienda t 
JOIN producto p ON t.id = p.tienda 
WHERE tipo = 'Traje' 
EXCEPT 
SELECT t.*
FROM tienda t 
JOIN producto p ON t.id = p.tienda 
WHERE tipo = 'Corbata' ;

--8. Obtener las 3 tiendas que tengan los productos m�s caros.

SELECT DISTINCT t.*, max(p.precio)
FROM tienda t 
JOIN producto p ON t.id = p.tienda
GROUP BY t.id
ORDER BY max(p.precio) DESC
LIMIT 3 ;

--9. Obtener el promedio de precio del perfume 'Aromas del arrabal' de acuerdo al tama�o del local

SELECT p.nombre, tamanho, round(avg(precio),2) AS precio_promedio 
FROM producto p
JOIN tienda t ON p.tienda = t.id 
JOIN local l ON t.local = l.id
WHERE p.tipo = 'Perfume' AND p.nombre = 'Aromas del arrabal'
GROUP BY tamanho, p.nombre ;

--10. Crear una vista que muestre las 5 tiendas que hayan realizado la mayor cantidad de ventas y sumatoria de pesos m�s alta en el mes de septiembre de 2020 ordenada por ambas
 
CREATE VIEW tiendas_mas_exitosas_septiembre AS
SELECT t.*, COUNT(v.*) AS cantidad_ventas, sum(p.precio -v.descuentos) AS sumatoria_pesos
FROM tienda t
JOIN producto p ON t.id = p.tienda
JOIN venta v ON t.id = v.tienda
WHERE date_part('month', fecha) = '09'
GROUP BY t.id
ORDER BY cantidad_ventas DESC, sumatoria_pesos DESC 
LIMIT 5 ;

--Chequeo que la vista se haya creado bien y que me devuelva lo pedido. 

SELECT * 
FROM tiendas_mas_exitosas_septiembre ; 

--11. Identificar a los clientes que hayan gastado mas de $ 100.000 mensuales (nombre, dni y tel�fono y la sumatoria de compras aplicados los descuentos)

SELECT c.nombre, c.dni, c.telefono, sum(p.precio - v.descuentos) AS gasto_mensual 
FROM cliente c
JOIN venta v ON c.id = v.cliente 
JOIN producto p ON v.producto = p.id 
GROUP BY c.nombre, c.dni, c.telefono, date_part('month', fecha)
HAVING sum(p.precio - v.descuentos) > '100000' ;

--12. Obtener los empleados que trabajan en alguna de las 5 tiendas m�s exitosas

SELECT e.*, tiendas_mas_exitosas.*
FROM empleado e 
JOIN (
	SELECT t.*, sum(p.precio -v.descuentos) AS sumatoria_pesos
	FROM tienda t
	JOIN producto p ON t.id = p.tienda
	JOIN venta v ON t.id = v.tienda
	GROUP BY t.id
	ORDER BY sumatoria_pesos DESC  
	LIMIT 5 ) as tiendas_mas_exitosas ON e.id_tienda = tiendas_mas_exitosas.id 
ORDER BY sumatoria_pesos DESC ; 

--13. Es necesario identificar a los empleados convivientes, es decir que viven en la misma direccion

SELECT e.nombre , conv.nombre, e.direccion 
FROM empleado e
JOIN empleado conv ON e.direccion = conv.direccion  
WHERE e.nombre < conv.nombre ;

--14. A partir del DNI de un cliente se busca obtener todos los puntos que ha acumulado. 

SELECT c.dni, COUNT(v.*) AS puntos_acumulados
FROM cliente c
JOIN venta v ON c.id = v.cliente 
JOIN producto p ON v.producto = p.id 
WHERE p.precio - v.descuentos > 500
GROUP BY c.dni, date_part('year', fecha) ;

--15. Por cuestiones CoVID-19, debemos identificar las tiendas cuyo n�mero de local sea par para que pueda
--abrir los d�as mi�rcoles, viernes y domingo, y las impares martes, jueves y s�bado. Los dias lunes el
--shopping no abrir�. La consulta debe calcular los d�as de apertura que se asignan como texto, y ordenarla
--por fecha de apertura. La leyenda debe ser �miercoles, viernes y domingo�, y �martes, jueves y s�bado� y la
--columna se llamar� dias_de_actividad.

SELECT *,
	CASE
           WHEN (id % 2) = 0 THEN 'miercoles, viernes y domingo'
           ELSE 'martes, jueves y sabado'
	END dias_de_actividad
FROM tienda 
ORDER BY dias_de_actividad ;

