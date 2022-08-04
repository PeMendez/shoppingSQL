--Abro la consola cmd de mi pc, pongo psql -U postgres 
--Entra a la base de datos de postgres.
--creo la base de datos con esta sentencia : 
CREATE DATABASE tp_mendez ;
--despues pongo este comando: '\c tp_mendez' para entrar en la base de datos que acabo de crear, luego creo las tablas en orden respetando las FK. 
--En mi caso empecé por las relaciones cliente e informacion_medica que no tenian ninguna FK. 
--Luego seguí con empleado, agregándole la FK con informacion_medica pero obviando la FK con tienda, ya que aun no la he creado. 
--Creo la relación tienda respetando la FK con empleado. 
--Luego la relación producto respetando la FK con tienda anteriormente creada.
--Luego la relación venta también respetando las PK y FK corres|pondientes. 
--Por último le agrego a la relación empleado la FK con tienda. 
--Para cargar el archivo desde la consola usé estos comandos: 
--psql -h localhost -p 5432 -U postgres < c:/'LA UBICACION DEL ARCHIVO DDL.sql'
--y Luego esta para cargar las consultas:
--psql -h localhost -p 5432 -U postgres tp_mendez< c:/'LA UBICACION DEL ARCHIVO DML.sql'

\c tp_mendez

--creo la relacion cliente 
CREATE TABLE cliente ( 
	id SERIAL PRIMARY KEY, 
	nombre VARCHAR(20),
	fecha_nac DATE,
	telefono INT,
	dni INT
	) ;

--creo la relacion informacion medica 
CREATE TABLE informacion_medica(
	id SERIAL PRIMARY KEY,
	grupo_sanguineo VARCHAR(5),
	alergias VARCHAR(200) NULL,
	obra_social VARCHAR(20) NULL
	);

--creo  la relacion empleado
CREATE TABLE empleado (
	id SERIAL PRIMARY KEY,
	nombre VARCHAR(20),
	telefono INT,
	direccion VARCHAR(20),
	id_tienda INT,
	rol VARCHAR(20),
	inf_medica INT,
	FOREIGN KEY (inf_medica) REFERENCES informacion_medica(id)
	);

--creo la relacion tienda
CREATE TABLE tienda (
	id SERIAL PRIMARY KEY,
	nombre VARCHAR(20),
	local INT,
	encargado INT, 
	FOREIGN KEY (encargado) REFERENCES empleado(id)
	);

--creo la relacion producto 
CREATE TABLE producto(
	id SERIAL PRIMARY KEY,
	tienda INT,
	tipo VARCHAR(20),
	nombre VARCHAR(20),
	precio INT,
	FOREIGN KEY (tienda) REFERENCES tienda(id)
	);

--creo la relacion venta 
CREATE TABLE venta(
	cliente INT,
	producto INT,
	tienda INT,	
	fecha DATE,
	descuentos INT NULL,
	PRIMARY KEY (cliente, producto, tienda),
	FOREIGN KEY (cliente) REFERENCES cliente(id),
	FOREIGN KEY (producto) REFERENCES producto(id),
	FOREIGN KEY (tienda) REFERENCES tienda(id)
	);

--agrego la FK en empleado ahora que ya esta creada la relacion tienda
ALTER TABLE empleado
ADD CONSTRAINT id_tienda
FOREIGN KEY (id_tienda) REFERENCES tienda(id) ;

--agrego una columna a la relacion informacion_medica 
ALTER TABLE informacion_medica
ADD COLUMN contacto_emergencia VARCHAR(20) NULL ;

--creo la relacion local
CREATE TABLE local (
	id SERIAL PRIMARY KEY,
	sector VARCHAR(20),
	tamanho DECIMAL
	);

--agrego la FK en tienda ahora que ya esta creada la relacion local
ALTER TABLE tienda
ADD CONSTRAINT local
FOREIGN KEY (local) REFERENCES local(id) ;

--inserto datos a la relacion cliente
INSERT INTO cliente (nombre, fecha_nac, telefono, dni)
	VALUES	('Sophie Suarez', '04/01/1990', '42328998', '32543678'),
		('Lautaro Diaz', '25/05/1989', '1567980043', '30567987'),
		('Jonathan Alberti', '01/12/1989', '42514956','34987657'),
		('Eva Fernandez', '27/07/1990', '43568901', '37983261'),
		('Lilian Lopez', '10/05/1962', '43744768', '22202477'),
		('Alejandro Bruno', '28/05/1989', '42760098', '35762125'),
		('Ornella Mendez', '30/05/1993', '1540621653', '37786217'); 

--inserto datos a la relacion informacion_medica 
INSERT INTO informacion_medica (grupo_sanguineo, alergias, obra_social, contacto_emergencia)
	VALUES	('A+', 'mani', 'OSDE', 'siri@gmail.com'),
		('0-', NULL, 'UP', 'susi@outlook.com'),
		('0+', NULL, 'Accord Salud', 'maria@gmail.com'),
		('0+', 'kiwi, picadura de abeja', 'OSECAC', NULL),
		('A-', 'tomate', 'OSDE', 'ayuda@gmail.com'),
		('AB-', NULL, 'Accord Salud', 'pepito@hotmail.com'),
		('B+', 'penisilina', 'OSPERYH', 'cargar@despues.com'),
		('0+', NULL, 'OSDE', NULL),
		('AB+', NULL, 'OSDE', 'lala@hotmail.com'),
		('0-', 'frutilla', 'OSDE', 'cargar@despues.com');

--inserto datos a empleado sin el id de tienda, ya que todavia no le agregue ningun dato
INSERT INTO empleado (nombre, telefono, direccion, rol, inf_medica)
	VALUES	('Sara Lopez', '42345678', 'Victoria 43', 'cajero', '1'),
		('Pedro Gonzalez', '41234567', 'Carabelas 1020', 'vendedor', '2'),
		('Laura Acosta', '45679012', 'Backman 345', 'encargado', '3'),
		('Martin Alcorta', '46578902', 'Roca 123', 'vendedor', '4'),
		('Lucia Alberti', '42513456', 'Tacuari 783', 'cajero', '5'),
		('Rocio Suarez', '48903214', 'Juncal 32', 'encargado', '6'), 
		('Marcos Sanchez', '40986758', 'Backman 345', 'vendedor', '7'), 
		('Luis Gomez', '41781234', 'Almafuerte 789', 'encargado', '8'),
		('Sandra Bullock', '45678901', 'Lebensohn 342', 'encargado', '9'),
		('Victoria Beckam', '41234567', 'Juncal 32', 'encargado', '10');

--inserto datos a local
INSERT INTO local (sector, tamanho)
	VALUES 	('A', '100'),
		('A', '200'),
		('B', '150'),
		('C', '200'),
		('D', '200'),
		('E', '100'),
		('F', '150') ;

--inserto datos a tienda 
INSERT INTO tienda (nombre, local, encargado)
	VALUES 	('Rip Curl', '1', '10'),
		('Cristobal Colon', '2', '9'),
		('Viamo', '3', '8'),
		('Lady Stork', '4', '6'),
		('Billabong', '5', '3'),
		('Etiqueta Negra', '6', NULL),
		('La Perfumerie', '7', NULL);


--inserto datos a la relacion producto 
INSERT INTO producto (tienda, tipo, nombre, precio)
	VALUES	('5', 'Tercera Edad', 'Pinzado', '17000'),
		('7', 'Perfume', 'Aromas del arrabal', '20000'),
		('5', 'Camisa', 'Hawaian', '10000'),
		('3', 'Sandalia', 'El pie fresco', '15000'),
		('4', 'Sandalia', 'el separadedos', '18000'),
		('3', 'Zapatilla', 'Converse', '25000'),
		('6', 'Perfume', 'Elegant', '45000'),
		('6', 'Corbata', 'cuadros', '15000'),
		('2', 'Traje', 'Total black', '160000'),
		('1', 'Tercera Edad', 'Caminadora', '65000'),
		('6', 'Traje', 'Negro', '60000'), 
		('5', 'Perfume', 'Aromas del arrabal', '17000'),
		('2', 'Perfume', 'Aromas del arrabal', '15000'), 
		('6', 'Camisa', 'Lenhador', '5000');

--inserto datos a la relacion venta 
INSERT INTO venta (cliente, producto, tienda, fecha, descuentos)
	VALUES 	('5', '4', '3', '25/09/2020', '7500'),
		('1', '1', '5', '30/09/2020', '8000'),
		('3', '3', '5', '27/06/2020', '6000'),
		('2', '10', '1', '10/09/2020', '1000'),
		('2', '2', '7', '06/05/2020', '0'),
		('2', '6', '3', '15/08/2020', '2000'),
		('6', '5', '4', '03/04/2020', '1500'),
		('2', '7', '6', '15/08/2020', '1000'),
		('4', '7', '6', '05/09/2020', '0'),
		('7', '9', '2', '08/09/2020', '5000'),
		('1','14', '6', '10/08/2020', '0'); 


--actualizo en la relacion empleado el id_tienda en cada tupla. 
--Me pareció muy engorroso tener que hacer un update por cada tupla,
--tenía la opción de agregar la restricción al final y agregar todos los datos juntos.
--Pero si quería respetar el orden de los puntos no encontré una mejor forma para hacerlo la verdad.
 
UPDATE empleado SET id_tienda = '7'
WHERE id = '1' ;

UPDATE empleado SET id_tienda = '6'
WHERE id = '2' ;

UPDATE empleado SET id_tienda = '5'
WHERE id = '3' ;

UPDATE empleado SET id_tienda = '2'
WHERE id = '4' ;

UPDATE empleado SET id_tienda = '1'
WHERE id = '5' ;

UPDATE empleado SET id_tienda = '4'
WHERE id = '6' ;

UPDATE empleado SET id_tienda = '7'
WHERE id = '7' ;

UPDATE empleado SET id_tienda = '3'
WHERE id = '8' ;

UPDATE empleado SET id_tienda = '2'
WHERE id = '9' ;

UPDATE empleado SET id_tienda = '1'
WHERE id = '10' ;

