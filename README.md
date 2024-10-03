# Evaluación final - Módulo 5 - "SQL/PGSQL"

## Introducción

El presente trabajo es parte de los requisitos de evaluación al término del módulo 5, del bootcamp Full Stack Python, relativo a conocimientos de sql, aplicados sobre una base de datos postgreSQL v. 16.4, llamada "dvdrental".

## Análisis del requerimiento

Para los ejercicios propuestos se ha utilizado la base de datos de ejemplo, provista por pgSQL, "dvdrental", relacionada con el arrendamiento de películas.

Las tareas requeridas son:

1. **Cargar una base de datos desde un archivo:** Para el cumplimiento se ha procedido a realizar la actividad, importando el archivo proporcionado ".tar" a PostgreSQL.

![carga_bbdd](./img/restore_001.PNG)

2. **Escribir consultas SQL:** Se han debido crear consultas para realizar operaciones básicas de CRUD (Crear, Leer, Actualizar, Eliminar), y también consultas más complejas para obtener información específica.
 
3. **Comprender el modelo relacional:** Para poder armar las distintas consultas y operaciones sobre la base de datos, se ha analizado la estructura de la base de datos "dvdrental", las relaciones entre las tablas, restricciones y otros elementos que forman parte del esquema original.

4. **Documentar la base de datos:** Crear un diccionario de datos que describa las tablas y columnas.
Desglose de las Tareas a Realizar

Carga de la Base de Datos:

Descomprimir el archivo .tar.
Utilizar herramientas de PostgreSQL (como psql o pgAdmin) para importar la base de datos.
Consultar la documentación de PostgreSQLTutorial.com si se presentan dificultades.
Construcción de Consultas:

Operaciones CRUD:
INSERT: Crear nuevas filas en las tablas customer, staff y actor.
UPDATE: Modificar datos existentes en las tablas mencionadas.
DELETE: Eliminar filas de las tablas mencionadas.
Ejemplo:
SQL
-- Insertar un nuevo cliente
INSERT INTO customer (first_name, last_name, email)
VALUES ('John', 'Doe', 'johndoe@example.com');
Usa el código con precaución.

Consultas de selección:
Listar rentals por año y mes:
SQL
SELECT * FROM rental
WHERE extract(year from rental_date) = 2023
AND extract(month from rental_date) = 11;
Usa el código con precaución.

Listar pagos:
SQL
SELECT payment_id, payment_date, amount FROM payment;
Usa el código con precaución.

Listar películas:
SQL
SELECT * FROM film
WHERE release_year = 2006 AND rental_rate > 4.0;
Usa el código con precaución.

Diccionario de Datos:

Crear una tabla o documento que contenga:
Nombre de la tabla
Nombre de cada columna
Tipo de dato de cada columna
Si la columna permite valores nulos (NULL)
Consideraciones Adicionales
Modelo Relacional: Es fundamental comprender cómo se relacionan las tablas entre sí (claves primarias, claves foráneas) para poder realizar consultas más complejas.
Optimización de Consultas: Se pueden utilizar índices para mejorar el rendimiento de las consultas, especialmente en bases de datos grandes.
Seguridad: Es importante tener en cuenta la seguridad al trabajar con bases de datos, especialmente al otorgar permisos a los usuarios.
Documentación: Mantener una buena documentación de la base de datos es esencial para facilitar su mantenimiento y uso a largo plazo.
Herramientas Útiles
psql: El cliente de línea de comandos de PostgreSQL.
pgAdmin: Una herramienta gráfica de administración de PostgreSQL.
Diagramadores de bases de datos: Para visualizar el modelo relacional (por ejemplo, ERwin, MySQL Workbench).
Este análisis proporciona una base sólida para abordar el ejercicio propuesto. Al seguir estos lineamientos y utilizar las herramientas adecuadas, el estudiante podrá completar el ejercicio con éxito y adquirir una comprensión más profunda de las bases de datos relacionales. 

 /* ***********************************************
 *												  *
 *                                               *
 *      OPERACIONES PARA LA ENTIDAD CUSTOMER     *
 *                                               *
 *                                               *
 *************************************************

 ANTES DE EMPEZAR
 ****************

 Eliminar o reemplazar una función
 *********************************

Cada vez que una función se modifica, debe ser actualizada pero, para ello,
requiere ser eliminada previamente. Esta es una tarea habitual.

Se puede escribir a mano, o se puede usar la que provee el propio pg, haciendo
click derecho, luego Scripts/CREATE Script. Abrirá una pestaña con el código y,
en la parte superior, se hallará el código para dropear la función, sin cometer
errores de sintáxis.

Este es el último script para dropear la función que inserta nuevos registros,
que incluye todos los campos probados.

*/

-- Script DROP función INSERTAR
-- ****************************

DROP FUNCTION IF EXISTS public.f_insertar_cliente(character varying, 
character varying, character varying, character varying, character varying, 
integer, integer, character varying, character varying, integer);

/*

Luego de chequear varias veces, logré establecer los campos que son necesarios 
para conservar la integridad y respetar los constraints (por ejemplo, no nulo 
o requerido).

La lógica es simple, se capturan todos los datos necesarios, luego se insertan 
en el orden correcto, primero address y luego customer, así se garantiza que se
cumplan la integridad y las restricciones.

*/

-- FUNCTION: INSERTAR UN NUEVO CLIENTE (CREATE)
-- ********************************************

CREATE OR REPLACE FUNCTION f_insertar_cliente(
  _first_name VARCHAR(45),
  _last_name VARCHAR(45),
  _email VARCHAR(50),
  _address VARCHAR(50),
  _district VARCHAR(20),
  _city_id INT,
  _store_id INT,
  _postal_code VARCHAR(10),
  _phone VARCHAR(20),
  _active INT
) RETURNS VOID AS $$
DECLARE
  _address_id INT;
BEGIN
  -- Primero insertamos la dirección, si no existe.
  INSERT INTO address (address, district, city_id, postal_code, phone)
  VALUES (_address, _district, _city_id, _postal_code, _phone)
  RETURNING address_id INTO _address_id;
  -- Luego, podemos insertar un nuevo cliente sin errores
  INSERT INTO customer (first_name, last_name, email, address_id, store_id, active)
  VALUES (_first_name, _last_name, _email, _address_id, _store_id, _active);
END;
$$ LANGUAGE plpgsql;

/* Datos de ejemplo insertados
   ***************************

La primera versión funcional del insert, generó que el campo 'active' del registro
customer_id #602, quedase vacío (null), sin embargo, se aprovechará este error para 
aplicar el procedimiento de actualización o update en la sección siguiente

*/

SELECT f_insertar_cliente('Jorge', 'Cordova', 'jorge.cordova@mymail.com', 'Calle Siempreviva 123', 'Santiago', 1, 1, '12345', '9555-12121');
SELECT f_insertar_cliente('Jota', 'Juillerat', 'jota.juillerat@elmail.com', 'Calle Elm 456', 'Santiago', 1, 1, '67890', '9444-21212', 1);
SELECT f_insertar_cliente('Alejandro', 'Juille', 'alejuille@mumail.com', 'Calle Test 789', 'Santiago', 1, 1, '13579', '9333-31313', 1);
SELECT f_insertar_cliente('Ale', 'Cordova', 'ale_cordova@gmail.com', 'Calle Nueva 2354', 'Santiago', 1, 1, '75000', '9666-43434', 1);
SELECT f_insertar_cliente('Cindy Test', 'Gonzalez Test', 'cynthiatest@testmail.net', '753 Carlson Courts, MA 61349', 'Davidfort', 1, 1, '50600', '736.643.4357', 1);
SELECT f_insertar_cliente('Teresa Garcia Test', 'Test Brady', 'TereGarcia@example.net', '068 Samuel Islands Apt. 711, IN 45377', 'Joneston', 1, 1, '17589', '(905)654-0273', 0);

-- Listar los registros insertados
SELECT * FROM customer WHERE last_name = 'Cordova'
SELECT * FROM customer WHERE last_name = 'Juille'
SELECT * FROM customer WHERE last_name = 'Juillerat'
SELECT * FROM customer WHERE last_name = 'Juillerat' OR last_name = 'Juille' OR last_name = 'Cordova' 

-- Para comprobar que los registros se han agregado, 
-- también podemos listar los últimos registros de 
-- la tabla customer

SELECT * FROM customer
ORDER BY customer_id DESC LIMIT 5

-- La comprobación no es completa sin listar los cambios de la tabla "address".
-- Listamos las address de los últimos 5 registros agregados

SELECT * FROM address
ORDER BY address_id DESC LIMIT 5

-- Para indagar sobre las restricciones utilice la siguiente consulta
-- Extrae los nombres de las restricciones únicas definidas en la tabla 
-- "customer" o "address".
-- P.D: No sirvió de mucho, se entendería que no hay restricciones, más 
-- allá de not null o FK.

SELECT conname FROM pg_constraint WHERE contype = 'u' AND conrelid = 'customer'::regclass;
SELECT conname FROM pg_constraint WHERE contype = 'u' AND conrelid = 'address'::regclass;

/*

ELIMINAR UN CLIENTE FORMA MANUAL (DELETE CUSTOMER)
**************************************************

Forma simple, eliminamos el cliente con 2 consultas
Una para el customer y la otra para la dirección

Primero eliminamos el customer por su ID de customer
Se eliminará el customer_id = 603 

*/
-- Elimina el customer
DELETE FROM customer
    WHERE customer_id = 603; -- El address_id = 615

-- Segundo, eliminamos el address
DELETE FROM address
    WHERE address_id = 615; 

/*

ELIMINAR UN CLIENTE USANDO UNA FUNCIÓN
**************************************

Se crea la función "f_eliminar_cliente(integer)", que ELIMINA UN 
CLIENTE DE LA TABLA CUSTOMER.

Primero, se debe verificar si hay borrado en cascada, en su defecto,
se debe manejar el procedimiento (manual o a través de funciones) para 
no dejar datos inconsistentes o dark data.

La siguiente consulta, fue la primera versión que no borra la dirección, 
pero se dejó para mostrarla como error

*/

-- Primera versión (No borra address)

CREATE OR REPLACE FUNCTION f_eliminar_cliente(_customer_id INT)
RETURNS VOID AS $$
BEGIN
    DELETE FROM customer
    WHERE customer_id = _customer_id;
END;
$$ LANGUAGE plpgsql;

-- Ejecutamos la función y eliminamos un registro de la tabla customer por su id = 605

SELECT f_eliminar_cliente(605)

-- Como se observa, el script original, sólo eliminaba el customer, pero no su 
-- dirección (address), por lo que procedemos a eliminarla manualmente, antes de
-- corregir la función y luego, probaremos nuevamente con la nueva versión.

DELETE FROM address
    WHERE address_id = 617; -- El address_id correspondiente al customer_id 605

-- Eliminamos la función anterior, antes de guardar las modificaciones

DROP FUNCTION IF EXISTS f_eliminar_cliente(integer);

-- Función corregida, ahora si elimina el cliente y su dirección
-- La función recibe un customer_id, y lo primero que hace es buscar el address_id
-- por el customer_id y almacena el dato en una varible. Luego procesa la eliminación
-- de la dirección, que debe ser previo al customer y, finalmente, elimina el customer
-- por su customer_id.

CREATE OR REPLACE FUNCTION f_eliminar_cliente(_customer_id INT) 
RETURNS VOID AS $$
DECLARE
    _address_id INT;
BEGIN
    -- Primero, se debe obtener el address_id a partir del customer_id
    SELECT address_id INTO _address_id
    FROM customer
    WHERE customer_id = _customer_id;
    -- Segundo, se debe eliminar el cliente, antes que la dirección, por un constraint (FK)
    DELETE FROM customer
    WHERE customer_id = _customer_id;
    -- Finalmente, se puede eliminar la dirección
    DELETE FROM address
    WHERE address_id = _address_id;
END;
$$ LANGUAGE plpgsql;

-- Ejecutamos la eliminación de un registro
-- ****************************************

-- Eliminaremos el cliente customer_ id = 604 y su dirección asociada address_id = 616 
SELECT f_eliminar_cliente(604);  

/*
 ACTUALIZAR UN CLIENTE (UPDATE CUSTOMER)
 ***************************************

Se proponen 3 métodos para actualizar los registros
	- Forma simple.
	- Función con un parámetro
	- Función 2 con múltiples parámetros
	
Partiremos por la "Forma simple" o manual, que es usando un update y set, instrucción
con que la que actualizamos un registro de la tabla "customer", pero requerirá 
repetir la acción por cada modificación.

Sintáxis: UPDATE <nombre_tabla>
			SET <nombre_campo>= <valor?campo>
			WHERE <condicion>;

Para esta demostración, se usará el customer_id = 602 

*/

-- Haremos un update manual del registro customer_id = 602
-- Cambiaremos el correo "jorge.cordova@mymail.com", por el correo "jcordova@testupdate.com"

UPDATE customer
	SET 
		email = 'jcordova@testupdate.com'
   	WHERE customer_id = 602;

/*

  FUNCIÓN 1: Actualiza cliente pasando un parámetro de tipo texto
  ***************************************************************
  Párámetros: 
  		_customer_id : El id del customer, de tipo entero.
	    _columna     : El nombre de una columna cualquiera, tipo texto.
    	_valor       : Una cadena de texto con una valor, tipo texto.

  Retorna: Un mensaje de confirmación por consola.

  Excepción: Esta versión sólo es para campos de tipo texto, se puede hacer una
             variante, modificando el tipo de dato por boolean, numeric, integer

  Para evitar esto, que no es tan eficiente, en la siguiente versión, se agregará
  la lógica usando JSONB, para que recibe argumentos múltiples.

*/
-- Versión una columna dinámica
CREATE OR REPLACE FUNCTION f_actualiza_cliente(
    _customer_id INT,
    _columna TEXT,
    _valor TEXT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
  -- Se arma la consulta de actualización en forma dinámica
  EXECUTE format('UPDATE customer SET %I = %L WHERE customer_id = %L', _columna, _valor, _customer_id);
  -- Confirmar que la actualización se realizó
  RAISE NOTICE 'Customer ID: %, columna % actualizada con valor %', _customer_id, _columna, _valor;
END;
$$;

-- EJECUCIÓN
SELECT f_actualiza_cliente(607, 'first_name', 'Uso de Función UPDATE');



/*

  FUNCIÓN 2: Actualiza cliente pasando parámetros múltiples
  *********************************************************

  Párámetros: 
  		_customer_id   : El id del customer, de tipo entero.
	    _updates JSONB : Un conjunto de pares clave:valor

  Retorna: Un mensaje de confirmación por consola.

*/
-- Versión múltiples campos usando JSONB
CREATE OR REPLACE FUNCTION f_actualiza_cliente_multiple(
    _customer_id INT,
    _updates JSONB
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    _columna TEXT;
    _valor TEXT;
    _set_clauses TEXT := '';
BEGIN
    -- Invento para armar el SET de una consulta con múltiples columnas dinámicamente
    FOR _columna, _valor IN SELECT * FROM jsonb_each_text(_updates)
    LOOP
        _set_clauses := _set_clauses || format('%I = %L, ', _columna, _valor);
    END LOOP;
    -- Se eliminan caracteres como la última coma y espacio extra al formar la consulta
    _set_clauses := rtrim(_set_clauses, ', ');
    -- Ejecutamos la actualización para más de 1 columna
    EXECUTE format('UPDATE customer SET %s WHERE customer_id = %L', _set_clauses, _customer_id);
    -- Mensaje con confirmación
    RETURN format('Customer ID %s: columnas actualizadas con los valores %s', _customer_id, _set_clauses);
END;
$$;




/* ***********************************************************
   *                                                         *
   *            SECCION DE CONSULTAS PARAMÉTRICAS            *
   *                                                         *
   ***********************************************************
*/

-- Listar todas las “rental” con los datos del “customer” dado un año y mes.
/*
   CONSULTA 1): Traer todas las películas (film), lanzadas el año 2006 (release_year) 
             que tengan una calificación (rental_rate) mayor a 4.
   			 
   RETORNA : 336 registros.

año    mes  cantidad registros
2005	5	1156
2005	6	2311
2005	7	6709
2005	8	5686
2006	2	182
*/

-- Partimos averiguando la cardinalidad por año para armar consultas de film x año x rate
-- Sólo hay lanzamientos en el año 2007 y totalizan 336

SELECT release_year, COUNT(*) AS total_peliculas
FROM film
WHERE rental_rate > 4.0
GROUP BY release_year;

/*
release_year   total_peliculas
2006	       336
*/

-- Consulta simple ==> Año 2006 y calificación > 4 

SELECT release_year, COUNT(*) AS total_peliculas
FROM film
WHERE rental_rate > 4.0 AND release_year = 2006
GROUP BY release_year;

-- Podemos probar otro año para estar seguros

SELECT release_year, COUNT(*) AS total_peliculas
FROM film
WHERE rental_rate > 4.0 AND release_year = 2005
GROUP BY release_year;

-- (Extra) Sabiendo qué años tienen datos, podemos analizar con más detalle
-- y listar, por ejemplo, el detalle de los film (títulos), con calificación
-- mayor a 4.0 (rental_rate), lanzadas el año 2006 (release date), que es 
-- el único año que tiene datos.

SELECT film_id AS "Código de la Película", release_year AS "Año de lanzamiento", title AS "Título de la Película", rental_rate AS "Calificación"
FROM film
WHERE release_year = 2006 AND rental_rate > 4.0
ORDER BY title, rental_rate;

/* MUESTREO
   ********
código  Año		Título				Calificación 
2		2006	"Ace Goldfinger"	4.99
7		2006	"Airplane Sierra"	4.99
8		2006	"Airport Pollock"	4.99
10		2006	"Aladdin Calendar"	4.99
13		2006	"Ali Forever"		4.99
...		...		...					...
*/

-- También, podemos mejorar la consulta simple, encapsulándola en una función.
-- Así la podemos llamar desde un endpoint o insertarla en un código Python.

CREATE OR REPLACE FUNCTION f_listar_por_annio_y_rate2(
    _release_year INTEGER,
    _rental_rate NUMERIC
)
RETURNS TABLE (
    "Código de la Película" INTEGER,
    "Año de lanzamiento" INTEGER,
    "Título de la Película" character varying(255),
    "Calificación" NUMERIC
) 
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT film_id AS "Código de la Película", 
         release_year::INTEGER AS "Año de lanzamiento", 
         title AS "Título de la Película", 
         rental_rate AS "Calificación"
  FROM film
  WHERE release_year = _release_year AND rental_rate > _rental_rate
  ORDER BY title, rental_rate;
END;
$$;

-- Crea una tabla con los datos paramétricos
-- *****************************************
CREATE OR REPLACE FUNCTION f_listar_por_annio_y_rate(
    _var_annio INTEGER,
    _var_rate NUMERIC
)
RETURNS SETOF RECORD 
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT 
         film_id::INTEGER AS "Código de la Película", 
         release_year::INTEGER AS "Año de lanzamiento", 
         title::character varying(255) AS "Título de la Película", 
         rental_rate::NUMERIC AS "Calificación"
  FROM film
  WHERE release_year = _var_annio 
    AND rental_rate > _var_rate
  ORDER BY title, rental_rate;
END;
$$;

-- Si hay problemas y debemos modificar la función, recordar que se debe
-- dropear la función antes de guardarla nuevamente.

DROP FUNCTION IF EXISTS public.f_listar_por_annio_y_rate(integer, numeric);

-- Probramos las nuevas funciones

-- 1) Esta función permite personalizar los meses que se quiere listar y las columnas a mostrar
SELECT * FROM f_listar_por_annio_y_rate(2006, 4.0) AS (
    "Código de la Película" INTEGER, 
    "Año de lanzamiento" INTEGER, 
    "Título de la Película" character varying(255), 
    "Calificación" NUMERIC
);

-- 2) Esta función permite obtener una lista de listas con los datos (just for fun)
SELECT f_listar_por_annio_y_rate2(2006, 4.0);

-- Podemos hacer algunas averiguaciones adicionales, por ejemplo:
-- Listar todos los films agrupados por categoría, y calificación mayor que 4.

SELECT film.release_year AS "Año lanzamiento", category.name AS "Categoría", COUNT(*) AS "Total de Peliculas"
FROM film
INNER JOIN film_category ON film.film_id = film_category.film_id
INNER JOIN category ON film_category.category_id = category.category_id
WHERE rental_rate > 4.0 
GROUP BY category.name, film.release_year;

/* Listar todas las “rental” con los datos del “customer” dado un año y mes.
   CONSULTA : Traer todos los arrendamientos (rental) con los datos del cliente (customer), dado
   			  un mes y un año específico.
   			 
   RETORNA  : 336 registros.
*/
-- Lista peliculas por año y mes (Todos)
SELECT
    EXTRACT(YEAR FROM rental_date)  AS año,
    EXTRACT(MONTH FROM rental_date) AS mes,
    COUNT(*) AS cantidad_registros
FROM
    rental
GROUP BY
    año, mes
ORDER BY
    año, mes;


/* **********************************
   *                                *
   *   BACKUP DE LA BASE DE DATOS   *     
   *         dvdrentalTest          *
   *                                *
   **********************************

 FUNCION: f_backup_pgsql(v_path_backup)
 	Realiza el backup de la base de datos 

	Parámetros : Recibe una cadena de texto con la ruta para guardar el respaldo

	Retorna    : Void y un mensaje de confirmación por consola.
*/
--Con problemas
CREATE OR REPLACE FUNCTION f_backup_pgsql(v_path_backup text)
RETURNS void AS $$
DECLARE
    v_comando text; -- Usamos una variable para almacenar la sentencia
BEGIN
    -- Estructuramos dinámicamente el comando pg_dump usando la ruta donde se guardará
    v_comando := 'pg_dump -Fc -h localhost -U postgres -d dvdrentalTest -f "' || replace(quote_literal(v_path_backup), '''', '''''') || '"';
    -- Ejecución del comando
    RAISE NOTICE 'Comando a ejecutar: %', v_comando; -- Agregar esta línea para depurar
    EXECUTE v_comando;
    RAISE NOTICE 'Backup realizado exitosamente a %', v_path_backup;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al realizar el backup: %', SQLERRM;
END;
$$
LANGUAGE plpgsql;


-- Otra versión con E'
CREATE OR REPLACE FUNCTION f_backup_pgsql(v_path_backup text)
RETURNS void AS $$
DECLARE
    v_comando text;
BEGIN
    -- Acortar la ruta si es necesario (ejemplo utilizando substring)
    v_path_backup := substring(v_path_backup from 1 for 255);

    -- Construir el comando pg_dump, utilizando E'...' para escapar la ruta
    v_comando := E'pg_dump -Fc -h localhost -U postgres -d dvdrentalTest -f "' || v_path_backup || '"';

    -- Ejecutar el comando
    RAISE NOTICE 'Comando a ejecutar: %', v_comando;
    EXECUTE v_comando;
    RAISE NOTICE 'Backup realizado exitosamente a %', v_path_backup; -- 
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al realizar el backup: %', SQLERRM;
END;
$$
LANGUAGE plpgsql;

-- Versión con format
CREATE OR REPLACE FUNCTION f_backup_pgsql(v_path_backup text)
RETURNS void AS $$
DECLARE
    v_comando text;
BEGIN
    -- Construir el comando pg_dump usando format
    v_comando := format('pg_dump -Fc -h localhost -U postgres -d dvdrentalTest -f %L', v_path_backup);
    -- Ejecutar el comando
    RAISE NOTICE 'Comando a ejecutar: %', v_comando;
    EXECUTE v_comando;
    --RAISE NOTICE 'Backup realizado exitosamente a %', v_path_backup;
--EXCEPTION
   -- WHEN OTHERS THEN
      --  RAISE EXCEPTION 'Error al realizar el backup: %', SQLERRM;
END;
$$
LANGUAGE plpgsql;

-- Nueva variante con format
CREATE OR REPLACE FUNCTION f_backup_pgsql(v_path_backup text)
RETURNS void AS $$
DECLARE
    v_comando text;
BEGIN
    -- Construir el comando pg_dump usando format
    v_comando := format('pg_dump -Fc -h localhost -U postgres -d dvdrentalTest -f "%s"', v_path_backup);

    -- Ejecutar el comando
    RAISE NOTICE 'Comando a ejecutar: %', v_comando;
    EXECUTE v_comando;
    RAISE NOTICE 'Backup realizado exitosamente a %', v_path_backup;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al realizar el backup: %', SQLERRM;

END;
$$
LANGUAGE plpgsql;



-- Ejecutamos la función:
-- **********************

SELECT f_backup_pgsql('C:\\backup_pgsql\\dvdrentalTest.dump');

-- Eliminamos la función:
-- **********************

DROP FUNCTION IF EXISTS f_backup_pgsql(text);

-- dump a un archivo

pg_dump –U postgres -F c dvdrentalTest > dvdrentalTest.sql;

pg_dump –U postgres -F c dvdrentalTest > "c:\\backup_pgsql\\" || db.sql
pg_dump –U <superuser_name> –F c <database_name> > <dump_file_name>
