/*

               EVALUACIÓN FINAL MODULO 5

Autor : Jorge Córdova

 ![1731413642737](image/evalFinalM5_Jorge_Cordova/1731413642737.png)

## Introducción

El presente trabajo es parte de los requisitos de evaluación al término del módulo 5,
del bootcamp Full Stack Python, relativo a conocimientos sobre sql, usando el motor
de base de datos PostgreSQL v. 16.4.

## Análisis del requerimiento

Para los ejercicios propuestos se ha utilizado la base de datos de ejemplo, provista
por pgSQL, llamada "dvdrental", relacionada con el arrendamiento de películas.

Como se observa en la imagen, se montó la base en dos servidores:

![1731413914353](image/evalFinalM5_Jorge_Cordova/1731413914353.png)

* En Azure: Se aprovechó el ejercicio para montar una instancia en un servidor en la nube.
* En Localhost: Se montaron dos instancias ("dvdrental" y "dvdrentalTest").
* En MongoDB: mediante la exportanción de las tablas en formato CSV, se montó la
  misma base sólo con fines académicos.

![1731434507611](image/evalFinalM5_Jorge_Cordova/1731434507611.png)

Las tareas requeridas son:

1. Cargar una base de datos desde un archivo de respaldo: Para el cumplimiento
   de la actividad, se importó el archivo proporcionado ".tar" a PostgreSQL.
   Nota: Los ejercicios fueron desarrollados en la instancia "dvdrentalTest",
   para que, en la segunda instancia ("dvdrental"), se pudiesen replicar todos
   los pasos desde 0, en la misma secuencia y así obtener los mismos resultados.
2. Escribir consultas SQL: Se entiende que se deben crear consultas básicas de
   tipo CRUD, y también, consultas más complejas para obtener información específica,
   por ejemplo, aplicando agrupaciones.
3. Comprender el modelo relacional: Para poder armar las distintas consultas y
   operaciones sobre la base de datos, se requiere analizar y entender la estructura
   de la base de datos "dvdrental", las relaciones entre sus tablas, restricciones
   y otros elementos que forman parte del esquema original.
4. Documentar la base de datos: Se solicita también, crear un diccionario de datos
   que describa las tablas y columnas.
5. Crear un backup: Finalmente, para poder auditar las operaciones solicitadas,
   se debe generar un respaldo con los cambios producidos en la BBDD para su comprobación.

## Restaurar la BBDD "DVDRENTAL"

La descripción no específica cómo, sin embargo, para restaurar la base se puede
hacer a través de línea de comandos, o utilizando la interfaz gráfica que, con
pocas acciones permite montar el esquema y los datos en la nueva base de datos
de destino.

Se realizó el procedimiento de restauración a través de la descomprensión del
archivo ".tar" de la bbdd.

Se realizó el mismo procedimiento tanto para instanciar la BBDD en Azure, como
en localhost.

Para probar todos los métodos, también se probaron por consola, usando psql.

Restaurar BBDD desde PgAdmin
    ![1731422530262](image/evalFinalM5_Jorge_Cordova/1731422530262.png)

Indicar la ruta para el archivo de restauración ".tar"
    ![1731434721768](image/evalFinalM5_Jorge_Cordova/1731434721768.png)

## Antes de empezar

* **Eliminar o reemplazar una función**

  Cada vez que una función se modifica, debe ser actualizada pero, para ello,
  si la función ya existía, requiere ser eliminada previamente. Esta es una
  tarea habitual.

  Esta sentencia se puede escribir "a mano" o, se puede usar la que provee el
  propio pgAdmin, haciendo click derecho sobre el objeto, luego
  "Scripts/CREATE/Create Script". Esta acción abrirá una pestaña mostrando el
  código y, en la parte superior, se hallará la sentencia para dropear la función,
  sin cometer errores de sintáxis.

## PROCEDIMIENTOS GENERALES DE INSERCIÓN

  1) OPERACIONES DE INSERCIÓN PARA LA ENTIDAD CUSTOMER

     * **Insertar un cliente de forma manual ("create" CUSTOMER)**

        Para insertar un nuevo registro en la tabla customer se requiere hacer dos
        operaciones secuenciales.

        Primero, crear la dirección, en su defecto se generará un error de FK, si se
        intenta, insertar un customer, sin su dirección.

        Segundo, realizar una inserción simple, pero lo vamos a resolver con una función
        que haga ambas cosas.

     * **Datos de ejemplo:**

        Para generar datos aleatorios se creo una función en Python usando la librería
        FAKER, todos los datos generados para prueba se generan y guardan en la carpeta:

        .\data_pruebas_[fecha].csv

        Las tuplas generadas para este caso son:
            
('Jorge', 'Cordova', 'jorge.cordova@mymail.com', 'Calle Siempreviva 123', 'Santiago', 1, 1, '12345', '9555-12121');
('Jota', 'Juillerat', 'jota.juillerat@elmail.com', 'Calle Elm 456', 'Santiago', 1, 1, '67890', '9444-21212', 1); 
('Alejandro', 'Juille', 'alejuille@mumail.com', 'Calle Test 789', 'Santiago', 1, 1, '13579', '9333-31313', 1);
('Ale', 'Cordova', 'ale_cordova@gmail.com', 'Calle Nueva 2354', 'Santiago', 1, 1, '75000', '9666-43434', 1);
('Cindy Test', 'Gonzalez Test', 'cynthiatest@testmail.net', '753 Carlson Courts, MA 61349', 'Davidfort', 1, 1, '50600', '736.643.4357', 1);
('Teresa Garcia Test', 'Test Brady', 'TereGarcia@example.net', '068 Samuel Islands Apt. 711, IN 45377', 'Joneston', 1, 1, '17589', '(905)654-0273', 0); 

/*
        Luego de chequear varias veces, logré establecer los campos que son necesarios
        para conservar la integridad y respetar los constraints (por ejemplo, no nulo
        o requerido).

        La lógica es simple, se capturan todos los datos necesarios, luego se insertan
        en el orden correcto, primero address y luego customer, así se garantiza que se
        cumplan la integridad y las restricciones.

     * **Script 'DROP' función que inserta cliente (CUSTOMER)**

        Este es el último script para dropear la función que inserta un nuevo customer
        en la tabla.
*/
 
DROP FUNCTION IF EXISTS f_insertar_cliente(
                character varying,  
                character varying, 
                character varying, 
                character varying, 
                character varying,  
                integer, 
                integer, 
                character varying, 
                character varying, 
                integer); 

--   * **FUNCTION: f_insertar_cliente()**
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
            _active INT ) 
RETURNS VOID AS $$ 
DECLARE _address_id INT; 
BEGIN -- Primero insertamos la dirección, si no existe. 
    INSERT INTO address (address, district, city_id, postal_code, phone) 
        VALUES (_address, _district, _city_id, _postal_code, _phone) 
        RETURNING address_id 
        INTO _address_id; -- Luego, podemos insertar un nuevo cliente sin errores 
    INSERT INTO customer (first_name, last_name, email, address_id, store_id, active) 
        VALUES (_first_name, _last_name, _email, _address_id, _store_id, _active); 
END; 
$$ 
LANGUAGE plpgsql;

/*
     * **Datos de ejemplo insertados**

        La primera versión funcional del insert, generó que el campo 'active' del
        registro **customer_id Nr.602**, quedase vacío (null), sin embargo, se
        aprovechará este error para aplicar el procedimiento de actualización o
        update en la sección siguiente
*/

SELECT f_insertar_cliente('Jorge', 'Cordova', 'jorge.cordova@mymail.com', 'Calle Siempreviva 123', 'Santiago', 1, 1, '12345', '9555-12121'); 
SELECT f_insertar_cliente('Jota', 'Juillerat', 'jota.juillerat@elmail.com', 'Calle Elm 456', 'Santiago', 1, 1, '67890', '9444-21212', 1); 
SELECT f_insertar_cliente('Alejandro', 'Juille', 'alejuille@mumail.com', 'Calle Test 789', 'Santiago', 1, 1, '13579', '9333-31313', 1); 
SELECT f_insertar_cliente('Ale', 'Cordova', 'ale_cordova@gmail.com', 'Calle Nueva 2354', 'Santiago', 1, 1, '75000', '9666-43434', 1); 
SELECT f_insertar_cliente('Cindy Test', 'Gonzalez Test', 'cynthiatest@testmail.net', '753 Carlson Courts, MA 61349', 'Davidfort', 1, 1, '50600', '736.643.4357', 1); 
SELECT f_insertar_cliente('Teresa Garcia Test', 'Test Brady', 'TereGarcia@example.net', '068 Samuel Islands Apt. 711, IN 45377', 'Joneston', 1, 1, '17589', '(905)654-0273', 0); 

/*
            ![1731419931693](image/evalFinalM5_Jorge_Cordova/1731419931693.png)

            ![1731419993663](image/evalFinalM5_Jorge_Cordova/1731419993663.png)
*/

-- * **Listar los registros insertados**
SELECT * FROM customer WHERE last_name = 'Cordova' 
SELECT * FROM customer WHERE last_name = 'Juille' 
SELECT * FROM customer WHERE last_name = 'Juillerat' 
SELECT * FROM customer WHERE last_name = 'Juillerat' 
    OR last_name = 'Juille' 
    OR last_name = 'Cordova'  

/*
        ![1731420031082](image/evalFinalM5_Jorge_Cordova/1731420031082.png)

        Para comprobar que los registros se han agregado, también podemos listar los
        últimos registros de la tabla customer.
*/
  
SELECT * FROM customer 
    ORDER BY customer_id DESC 
    LIMIT 5;

/*
        ![1731420161400](image/evalFinalM5_Jorge_Cordova/1731420161400.png)

        La comprobación no puede ser completa, sin listar los cambios de la tabla "address".
        Listamos las "address" de los últimos 5 registros agregados
*/

SELECT * FROM address ORDER BY address_id DESC LIMIT 5; 

/*
       ![1731420212722](image/evalFinalM5_Jorge_Cordova/1731420212722.png)

        Para indagar sobre las restricciones utilicé la siguiente consulta, que extrae
        los nombres de las restricciones únicas definidas en una tabla, por ejemplo:
        "customer" o "address"

        P.D: No sirvió de mucho, se entendería que no hay restricciones, más allá de
        not null o FK.
*/ 

SELECT conname FROM pg_constraint WHERE contype = 'u' AND conrelid = 'customer'::regclass; 
SELECT conname FROM pg_constraint WHERE contype = 'u' AND conrelid = 'address'::regclass; 

/*
  2) OPERACIONES DE INSERCIÓN PARA LA ENTIDAD STAFF

     * **Insertar un nuevo empleado (STAFF)**

       * Consideraciones:

         1) Se debe tener cuidado al insertar un nuevo registro porque hace referencia
            a una tabla externa ("address"), a través de su clave foránea "address_id".
         2) Adicionalmente, la tabla "address", también posee referencia a otras tablas
            a través de la FK "city_id", la que a su vez, está vinculada a la FK "country_id".
         3) Se podría generar una función que valide estos aspectos, introduciendo una
            capa adicional de verificación, por ejemplo, comprobando si la ciudad y el
            país existen, lanzando una excepción del tipo:
*/
 
IF _city_id IS NULL AND NOT EXISTS 
    (SELECT 1 FROM country WHERE country_id = _country_id) 
    THEN RAISE EXCEPTION 'La ciudad y/o el país no existen.'; 
END IF;

/*
            Sin embargo, esto detendría el proceso.

        4) También se podrían insertar la ciudad y el país, en caso de no existir, agregando
            a nuestra función una consulta como esta:
*/
 
IF _city_id IS NULL 
    THEN INSERT INTO city(city, country_id, last_update) 
    VALUES (_city_name, _country_id, NOW()) 
    RETURNING city_id INTO _city_id; 
    INSERT INTO country(country, last_update) 
    VALUES WHERE NOT EXISTS (SELECT 1 FROM country 
    WHERE country_id = _country_id); 
END IF;

/*
            5) Estas dos aproximaciones al problema de lograr mayor integridad en los datos
                para no generar datos basura que luego no conecten con nada, tienen pros y
                contras.
                Por ejemplo, podría no ser deseado que se cree un país que no existe (ficticio),
                o que sea un proceso administrativo que requiere aprobación para modificar un
                mantenedor.
                También podría ocurrir que el detectar si la ciudad o país no existen, lanzando
                una excepción, no sea un comportamiento deseado para la aplicación. En ambos
                casos, el beneficio es una bbdd consistente, íntegra y útil para los usos que se
                le quiera dar. Para efectos académicos, habiendo entendido el problema, se reducirá
                la complejidad, omitiendo estos escenarios y creando datos de pruebas con los
                datos existente en los mantenedores (países y ciudades ya creados)
*/

-- * **FUNCTION: f_insertar_staff()**
CREATE OR REPLACE FUNCTION f_insertar_staff( 
                        _first_name text, 
                        _last_name text, 
                        _address text, 
                        _address2 text, 
                        _district text, 
                        _city_id integer, 
                        _postal_code text, 
                        _phone text, 
                        _email text, 
                        _store_id integer, 
                        _active boolean, 
                        _username text, 
                        _password text 
                ) 
RETURNS void AS $$ 
DECLARE v_address_id integer; 
BEGIN -- Primero insertamos la dirección para mantener la consistencia de BBDD 
      -- Para el city_id, usaremos datos existentes en la BBDD 
    INSERT INTO address( address, address2, district, city_id, postal_code, phone, last_update ) 
    VALUES ( _address, _address2, _district, _city_id, _postal_code, _phone, NOW() ) RETURNING address_id 
    INTO v_address_id; -- Insertar el empleado 
    INSERT INTO staff( first_name, last_name, address_id, email, store_id, active, username, password, last_update ) 
    VALUES ( _first_name, _last_name, v_address_id, _email, _store_id, _active, _username, _password, NOW() ); 
END; $$ 
LANGUAGE plpgsql;

-- ![1731433844609](image/evalFinalM5_Jorge_Cordova/1731433844609.png)

-- * **Eliminar la función f_insertar_staff()**
            DROP FUNCTION IF EXISTS f_eliminar_staff(integer); 

-- * **Datos de prueba f_insertar_staff()**
-- Referencia) (first_name, last_name, address, address2, district, city_id, postal_code, phone, email, store_id, active, username, password)

```sql 
('Pedrito', 'Staff1', 'Recoleta 123', 'Santiago', 'Santiago', 300, '912345', '9555-5555', 'pstaff1e@eval5.com', 2, true, 'Pedrito1', 'pass123') 
('Juanito', 'Staff2', 'Vivaceta 321', 'Recoleta', 'Recoleta', 576, '812345', '9444-2222', 'jstaff2@eval5.com', 1, true, 'Juanito2', 'pass123') 
('Dieguito', 'Staff3', 'Apoquindo 3321', 'Las Condes', 'Las Condes', 300, '912345', '8333-5555', 'dstaff3@eval5.com', 2, true, 'Dieguito3', 'pass123') 
('Fulanito', 'Staff4', 'Alameda 8321', 'Santiago', 'Santiago', 576, '812345', '2555-1111', 'fstaff4@eval5.com', 2, true, 'Fulanito4', 'pass123') 
('Sutanito', 'Staff5', 'Matta 2321', 'Santiago', 'Santiago', 300, '912345', '3123-1231', 'sstaff5@eval5.com', 1, true, 'Sutanito5', 'pass123') 
```

-- * **Ejecución**
SELECT f_insertar_staff('Pedrito', 'Staff1', 'Recoleta 123', 'Santiago', 'Santiago', 300, '912345', '9555-5555', 'pstaff1e@eval5.com', 2, true, 'Pedrito1', 'pass123'); 
SELECT f_insertar_staff('Juanito', 'Staff2', 'Vivaceta 321', 'Recoleta', 'Recoleta', 576, '812345', '9444-2222', 'jstaff2@eval5.com', 1, true, 'Juanito2', 'pass123'); 
SELECT f_insertar_staff('Dieguito', 'Staff3', 'Apoquindo 3321', 'Las Condes', 'Las Condes', 300, '912345', '8333-5555', 'dstaff3@eval5.com', 2, true, 'Dieguito3', 'pass123'); 
SELECT f_insertar_staff('Fulanito', 'Staff4', 'Alameda 8321', 'Santiago', 'Santiago', 576, '812345', '2555-1111', 'fstaff4@eval5.com', 2, true, 'Fulanito4', 'pass123'); 
SELECT f_insertar_staff('Sutanito', 'Staff5', 'Matta 2321', 'Santiago', 'Santiago', 300, '912345', '3123-1231', 'sstaff5@eval5.com', 1, true, 'Sutanito5', 'pass123');

/*
         ![1731434190221](image/evalFinalM5_Jorge_Cordova/1731434190221.png)

  3) OPERACIONES DE INSERCIÓN PARA LA ENTIDAD ACTOR

     * **Insertar un nuevo actor (ACTOR)**

       * Consideraciones:

         1) No existen restricciones evidentes al momento de crear un nuevo actor,
            porque esta tabla es referida por la tabla "film", pudiendo un actor, no
            tener asociadas películas al momento de ser creado.
         2) Entendiendo cómo funciona la tabla, vamos a crear una función que inserte
            nuevos registros en la tabla actor, pero antes de hacer la inserción,
            verificará si el actor ya existe en la base de datos, evitando así duplicados.
*/

-- * **FUNCTION: f_insertar_actor()**
CREATE OR REPLACE FUNCTION f_insertar_actor(
_first_name text,
_last_name text
)
RETURNS void AS
$$
DECLARE
    _actor_id integer;
BEGIN
-- Verificamos si el actor ya existe
SELECT actor_id INTO _actor_id
FROM actor
WHERE first_name = _first_name AND last_name = _last_name;
-- Si no existe, insertamos el nuevo actor
IF _actor_id IS NULL THEN
    INSERT INTO actor(
        first_name, last_name, last_update
    )
    VALUES (
        _first_name, _last_name, NOW()
    );
ELSE
    RAISE NOTICE 'El actor % % ya existe.', _first_name, _last_name;
END IF;
END;
$$
LANGUAGE plpgsql;

-- ![1731433551631](image/evalFinalM5_Jorge_Cordova/1731433551631.png)

-- * **Eliminar la función f_insertar_actor()**
DROP FUNCTION IF EXISTS f_insertar_actor(text, text); 

-- * **Datos de prueba: f_insertar_actor()**
('Burt', 'Dukakis'); -- El actor ya existe en la tabla, lanza el aviso de duplicado 
('Spencer', 'Depp'); -- El actor ya existe en la tabla, lanza el aviso de duplicado 
('Juanito', 'Actor1');  -- Registro nuevo, aparece al final de la tabla ACTOR 
('Pedrito', 'Actor2');  -- Registro nuevo, aparece al final de la tabla ACTOR 
('Dieguito', 'Actor3'); -- Registro nuevo, aparece al final de la tabla ACTOR 

--     * **Ejecución**
SELECT f_insertar_actor('Burt', 'Dukakis');  -- Debe mostrar un aviso de duplicado 
SELECT f_insertar_actor('Spencer', 'Depp');  -- Debe mostrar un aviso de duplicado 
SELECT f_insertar_actor('Juanito', 'Actor1'); 
SELECT f_insertar_actor('Pedrito', 'Actor2'); 
SELECT f_insertar_actor('Dieguito', 'Actor3'); 

/*
        No inserta datos duplicados
            ![1731433680397](image/evalFinalM5_Jorge_Cordova/1731433680397.png)

        Hace validación a través de evaluar los argumentos
            ![1731433729040](image/evalFinalM5_Jorge_Cordova/1731433729040.png)

        Sólo inserta los nuevos registros
            ![1731433751603](image/evalFinalM5_Jorge_Cordova/1731433751603.png)

## PROCEDIMIENTOS GENERALES DE ELIMINACIÓN

  1) OPERACIONES DE ELIMINACIÓN PARA LA ENTIDAD CUSTOMER

     * **Eliminar un cliente de forma manual ("DELETE" CUSTOMER)**

        Forma simple, eliminamos el cliente con 2 consultas, Una para el customer
        y la otra para la dirección

        Primero eliminamos el customer por su ID de customer. Se eliminará el
        customer_id = 603

        ![1731428715103](image/evalFinalM5_Jorge_Cordova/1731428715103.png)
*/ 

-- Primero eliminamos el customer 603 
DELETE FROM customer WHERE customer_id = 603; 
-- Tiene el address_id = 615 
-- Segundo, eliminamos el address_id 615 
DELETE FROM address WHERE address_id = 615; 

/*
        ![1731428782902](image/evalFinalM5_Jorge_Cordova/1731428782902.png)

        Registro en customer borrado
            ![1731428833647](image/evalFinalM5_Jorge_Cordova/1731428833647.png)

        Registro en address borrado
            ![1731428934147](image/evalFinalM5_Jorge_Cordova/1731428934147.png)

     * **Eliminar un cliente usando una función**

        Se creo la función "f_eliminar_cliente(integer)", que ELIMINA UN CLIENTE DE
        LA TABLA CUSTOMER.

        Primero, se debe verificar si hay "borrado en cascada", en su defecto, se
        debe manejar el procedimiento (manual o a través de funciones) para no dejar
        datos inconsistentes o dark data.

        La siguiente consulta, fue la primera versión que no borra la dirección, pero
        se dejó para mostrar como manejar el error.
*/

-- * **Primera versión de la función (No borra address)**
CREATE OR REPLACE FUNCTION f_eliminar_cliente(_customer_id INT) 
RETURNS VOID AS $$ BEGIN DELETE FROM customer 
WHERE customer_id = _customer_id; 
END; 
$$ 
LANGUAGE plpgsql; 

/*
        Ejecutamos la función y eliminamos un registro de la tabla customer por su id = 605

        ![1731429063373](image/evalFinalM5_Jorge_Cordova/1731429063373.png)

        ![1731429090400](image/evalFinalM5_Jorge_Cordova/1731429090400.png)

*/ 

SELECT f_eliminar_cliente(605) 

/*
        Como se observa en la BBDD, el script original, sólo eliminaba el customer,
        pero no su dirección (address), por lo que procedemos a eliminarla manualmente,
        antes de corregir la función y luego, probaremos nuevamente con la nueva versión.

        ![1731429139312](image/evalFinalM5_Jorge_Cordova/1731429139312.png)
*/
 
DELETE FROM address 
WHERE address_id = 617; -- El address_id correspondiente al customer_id 605 

--  Eliminamos la función anterior, antes de guardar las modificaciones
DROP FUNCTION IF EXISTS f_eliminar_cliente(integer); 

/*
        Habiendo observado el error, procedemos a corregir la función, ahora si elimina
        el cliente y su dirección. La función recibe un customer_id, y lo primero que
        hace es buscar el address_id por el customer_id, y almacena el dato en una
        varible. Luego, procesa la eliminación de la dirección, que debe ser previo
        al customer y, finalmente, elimina el customer por su customer_id.
*/

-- * **FUNCTION: f_eliminar_cliente(), versión corregida**
CREATE OR REPLACE FUNCTION f_eliminar_cliente(_customer_id INT)  
RETURNS VOID AS $$ 
DECLARE _address_id INT; 
BEGIN -- Primero, se debe obtener el address_id a partir del customer_id 
SELECT address_id 
    INTO _address_id 
    FROM customer 
    WHERE customer_id = _customer_id; -- Segundo, se debe eliminar el cliente, antes que la dirección, por un constraint (FK) 
DELETE FROM customer 
    WHERE customer_id = _customer_id; -- Finalmente, se puede eliminar la dirección 
DELETE FROM address 
    WHERE address_id = _address_id; 
END; 
$$ 
LANGUAGE plpgsql; 

/*
     * **Ejecutamos la eliminación de un registro CUSTOMER**

        Ahora, con la función corregida, eliminaremos el cliente "customer_id = 604"
        y su dirección asociada "address_id = 616"

        ![1731429597038](image/evalFinalM5_Jorge_Cordova/1731429597038.png)
*/

SELECT f_eliminar_cliente(604); 

/*
        Como se puede comprobar en la BBDD, el registro no existe en la tabla
        CUSTOMER y tampoco en la tabla ADDRESS asociada por su address_id.

        ![1731430009167](image/evalFinalM5_Jorge_Cordova/1731430009167.png)

        ![1731429919563](image/evalFinalM5_Jorge_Cordova/1731429919563.png)

        Para verificar, se pueden listar últimos registros de las tablas afectadas.
*/

SELECT * FROM customer ORDER BY customer_id DESC LIMIT 10 -- No se puede ver el registro 604
SELECT * FROM address ORDER BY address_id DESC LIMIT 10   -- No se puede ver el registro 616

/*
  2) OPERACIONES DE ELIMINACIÓN PARA LA ENTIDAD STAFF

     * **Eliminar un empleado ("DELETE" STAFF)**

        Forma simple, eliminamos el empleado haciendo una consulta a la tabla "staff"
        y una consulta a la tabla "address".

        Para este ejemplo, de los empleados que creamos antes, usaremos el empleado #7,
        cuyo address_id es el N° 624.
*/

-- Primero, eliminamos el registro del empleado su id de empleado
DELETE FROM staff
WHERE staff_id = 7;

--      ![1731430321723](image/evalFinalM5_Jorge_Cordova/1731430321723.png)

--  Segundo eliminamos la dirección del empleado por su id de dirección:
DELETE FROM address
WHERE address_id = 624;

--        ![1731430626016](image/evalFinalM5_Jorge_Cordova/1731430626016.png)
  
-- Se verifica con las siguientes consultas
SELECT * FROM staff
ORDER BY staff_id ASC LIMIT 10

SELECT * FROM address
ORDER BY address_id DESC LIMIT 10

/*
        Usando una función, eliminaremos el empleado pasando como parámetro el número
        de su id (staff_id), la misma función hará la consulta a la tabla "address" y,
        usando su "address_id", eliminará la dirección.

        Por dependencia, se debe eliminar primero el empleado, y luego la dirección.

        Para el ejemplo, eliminaremos el registro #6 de la tabla staff, cuyo address_id
        es el 623.
*/

-- * **Eliminar la función (DROP)**
DROP FUNCTION IF EXISTS f_eliminar_empleado(integer);

--     * **FUNCTION: f_eliminar_empleado()**
CREATE OR REPLACE FUNCTION f_eliminar_empleado(_staff_id integer) 
RETURNS void AS $$ 
DECLARE _address_id integer; 
BEGIN -- Antes de eliminar el empleado, necesitamos guardar el ID de la dirección 
      -- porque de otra forma se pierde y no se puede completar el segundo delete 
    SELECT address_id 
        INTO _address_id 
        FROM staff 
        WHERE staff_id = _staff_id; -- Eliminamos el empleado por su id 
    DELETE FROM staff 
        WHERE staff_id = _staff_id; -- Ahora sí podemos eliminar la dirección usando el id guardado 
    IF FOUND THEN 
        DELETE FROM address 
        WHERE address_id = _address_id; 
    END IF; 
END; 
$$ 
LANGUAGE plpgsql; 

--     * **Ejecutamos**
SELECT f_eliminar_empleado(6); SELECT f_eliminar_empleado(5);
          
--        ![1731431175528](image/evalFinalM5_Jorge_Cordova/1731431175528.png)

-- Se verifica con las siguientes consultas
SELECT * FROM staff
ORDER BY staff_id DESC LIMIT 10

SELECT * FROM address
ORDER BY address_id DESC LIMIT 10
-- Ambos registros fueron correctamente eliminados

/*
        ![1731431229362](image/evalFinalM5_Jorge_Cordova/1731431229362.png)

        ![1731431260358](image/evalFinalM5_Jorge_Cordova/1731431260358.png)

        ![1731431831260](image/evalFinalM5_Jorge_Cordova/1731431831260.png)

  3) OPERACIONES DE ELIMINACIÓN PARA LA ENTIDAD ACTOR

     * **Eliminar un actor ("DELETE" ACTOR)**

        Forma simple, eliminamos el actor haciendo una consulta a la tabla "actor".

        La tabla no tiene restricciones ni FK de las que dependa.

        Para este ejemplo, de los actores que creamos antes, usaremos el actor N° 203.
*/

-- Eliminamos el registro del actor usando su actor_id
DELETE FROM actor
WHERE actor_id = 203;

-- Se verifica con la siguiente consulta
SELECT * FROM actor
ORDER BY actor_id DESC LIMIT 10

/*
       ![1731431877584](image/evalFinalM5_Jorge_Cordova/1731431877584.png)

        Para el siguiente caso, usando una función, eliminaremos un actor pasando
        como parámetro el número de su id (actor_id). No tiene dependencias.

        Eliminaremos el registro N° 202 de la tabla actor.
*/

-- * **Eliminar la función (DROP)**
DROP FUNCTION IF EXISTS f_eliminar_actor(integer);

-- * **FUNCTION: f_eliminar_actor()**
CREATE OR REPLACE FUNCTION f_eliminar_actor(_actor_id integer) 
    RETURNS void AS $$ 
    BEGIN 
    DELETE FROM actor 
    WHERE actor_id = _actor_id; 
END; 
$$ 
LANGUAGE plpgsql; 

/*
     * **EJECUCIÓN**

        ![1731432138960](image/evalFinalM5_Jorge_Cordova/1731432138960.png)
*/

SELECT f_eliminar_actor(202);

-- Se verifica con la siguiente consulta
SELECT * FROM actor
ORDER BY actor_id DESC LIMIT 10

/*
![1731432265710](image/evalFinalM5_Jorge_Cordova/1731432265710.png)

## PROCEDIMIENTOS GENERALES DE ACTUALIZACIÓN (UPDATE)

  1) OPERACIONES DE ACTUALIZACIÓN PARA LA ENTIDAD CUSTOMER

     * **Actualizar un cliente ("UPDATE" CUSTOMER)**

        Se proponen 3 métodos para actualizar los registros
         * Forma simple.
         * Función con un parámetro
         * Función 2 con múltiples parámetros

        **Forma simple**, usando un select con update y set, podemos actualizar
        un registro en la tabla customer, pero requerirá una acción por cada 
        modificación.
*/

-- Sintáxis:
UPDATE <nombre_tabla>
SET <nombre_campo>= <valor_campo>
WHERE <condicion>;

/*
        Campos actualizables o modificables:

          * store_id
          * first_name
          * last_name
          * email
          * address_id
          * activebool
          * active

        Primero haremos una actualización simple por el ID de customer. Se modificará
        el correo del "customer_id" = 602,  de "mymail" a "testupdate".
*/

UPDATE customer
SET email = 'jcordova@testupdate.com'
WHERE customer_id = 602;

/*
        ![1731440689292](image/evalFinalM5_Jorge_Cordova/1731440689292.png)

        Ejecutando una sentencia "UPDATE", modificamos el correo del cliente.
        ![1731462731442](image/evalFinalM5_Jorge_Cordova/1731462731442.png)

     * **FUNCIÓN 1: Actualiza cliente pasando un parámetro de tipo texto**

        Párámetros:

       * "_customer_id" : El id del customer, de tipo entero.
       * "_columna"     : El nombre de una columna cualquiera, tipo texto.
       * "_valor"       : Una cadena de texto.

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
    -- Arma la consulta de actualización en forma dinámica
    EXECUTE format("UPDATE customer SET %I = %L WHERE customer_id = %L", _columna, _valor, _customer_id);
    
    -- Confirma que la actualización se realizó
    RAISE NOTICE "Customer ID: %, columna % actualizada con valor %", _customer_id, _columna, _valor;
END;
$$;

-- EJECUCIÓN
SELECT f_actualiza_cliente(607, 'first_name', 'Uso de Función UPDATE');

/*
        Registro a modificar en el "first_name"
        ![1731446529390](image/evalFinalM5_Jorge_Cordova/1731446529390.png)

        Campo modificado con la cadena "Uso de Función UPDATE"
        ![1731446641992](image/evalFinalM5_Jorge_Cordova/1731446641992.png)

     * **FUNCIÓN 2: Actualiza cliente pasando parámetros múltiples**

        Párámetros:
         * _customer_id   : El id del customer, de tipo entero.
         * _updates JSONB : Un conjunto de pares clave:valor

        Retorna: Un mensaje de confirmación por consola.
*/

-- Versión múltiples campos usando JSONB
CREATE OR REPLACE FUNCTION f_actualiza_cliente_multiple(
    _customer_id INT,
    _updates JSONB
)
RETURNS TEXT
LANGUAGE plpgsql
AS
$$
DECLARE
    _columna TEXT;
    _valor TEXT;
    _set_clauses TEXT := '';
BEGIN
    -- Invento para armar, dinámicamente, el "SET" de una consulta con múltiples columnas 
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

-- EJECUCIÓN
SELECT f_actualiza_cliente_multiple(602, '{"last_name": "Cordova_updated", "email": "jota.cordova@update_multiple.com"}');

/*
        Vista antes de usar la función
            ![1731463628114](image/evalFinalM5_Jorge_Cordova/1731463628114.png)

        Ejecutamos la función
            ![1731463957265](image/evalFinalM5_Jorge_Cordova/1731463957265.png)

        Vista después de usar la función
            ![1731464017816](image/evalFinalM5_Jorge_Cordova/1731464017816.png)

  2) OPERACIONES DE ACTUALIZACIÓN PARA LA ENTIDAD STAFF

     * **Actualizar un empleado ("UPDATE" STAFF)**

        Al igual que con "customer, se puede utilizar cualquiera de los 3 métodos
        ya descritos para actualizar los registros de esta tabla
         * Forma simple.
         * Función con un parámetro
         * Función 2 con múltiples parámetros

        **Forma simple**, usando un select con update y set, podemos actualizar
        un registro en la tabla customer, pero requerirá una acción por cada
        modificación.
*/

-- Sintáxis:
UPDATE <nombre_tabla>
SET <nombre_campo>= <valor_campo>
WHERE <condicion>;

/*
        Campos actualizables o modificables:

          * first_name
          * last_name
          * address_id
          * email
          * store_id
          * active
          * username
          * password
          * picture

        Primero haremos una actualización simple por el ID del empleado. Se modificará
        el correo del "staff_id" = 4,  de "jstaff2" a "juanito_staff2".
*/

UPDATE customer
SET email = 'juanito_staff2@eval5.com'
WHERE staff_id = 4;

/*
        Vista antes de actualizar
            ![1731465011952](image/evalFinalM5_Jorge_Cordova/1731465011952.png)

        Vista después de actualizar
            ![1731465298791](image/evalFinalM5_Jorge_Cordova/1731465298791.png)

     * **FUNCIÓN 1: Actualiza empleado pasando un parámetro de tipo texto**

        Párámetros:

       * "_staff_id" : El id del customer, de tipo entero.
       * "_columna"  : El nombre de una columna cualquiera, que sea de tipo texto.
       * "_valor"    : Una cadena de texto.

        Retorna: Un mensaje de confirmación por consola.

        Excepción: Esta versión sólo es para campos de tipo texto, se puede hacer una
        variante, modificando el tipo de dato por boolean, numeric, integer

        Para evitar esto, que no es tan eficiente, en la siguiente versión, se agregará
        la lógica usando JSONB, para que recibe argumentos múltiples.
*/

-- Versión una columna dinámica
CREATE OR REPLACE FUNCTION f_actualiza_empleado(
    _staff_id INT,
    _columna TEXT,
    _valor TEXT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- Arma la consulta de actualización en forma dinámica
    EXECUTE format('UPDATE staff SET %I = %L WHERE staff_id = %L', _columna, _valor, _staff_id);
    -- Confirma que la actualización se realizó
    RAISE NOTICE '%', format('Staff ID: %s, columna %s actualizada con valor %s', _staff_id, _columna, _valor);
END;
$$;

--        **Eliminar función**
DROP FUNCTION IF EXISTS f_actualiza_empleado(integer, text, text);    

--        **Ejecución**
SELECT f_actualiza_empleado(3, 'first_name', 'Pedro Test Función UPDATE');

/*
        Registro a modificar en el "first_name"
            ![1731467017593](image/evalFinalM5_Jorge_Cordova/1731467017593.png)

        Campo modificado con la cadena "Uso de Función UPDATE"
            ![1731467911415](image/evalFinalM5_Jorge_Cordova/1731467911415.png)

     * **FUNCIÓN 2: Actualiza empleados (staff) pasando parámetros múltiples**

        Párámetros:
         * _staff_id      : El id del customer, de tipo entero.
         * _updates JSONB : Un conjunto de pares clave:valor

        Retorna: Un mensaje de confirmación por consola.
*/

-- Versión múltiples campos usando JSONB
CREATE OR REPLACE FUNCTION f_actualiza_empleado_multiple(
    _staff_id INT,
    _updates JSONB
)
RETURNS TEXT
LANGUAGE plpgsql
AS
$$
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
    EXECUTE format('UPDATE staff SET %s WHERE staff_id = %L', _set_clauses, _staff_id);
    -- Mensaje con confirmación
    RETURN format('Staff ID %s: columnas actualizadas con los valores %s', _staff_id, _set_clauses);
END;
$$;

-- EJECUCIÓN
SELECT f_actualiza_empleado_multiple(4, '{"last_name": "Staff2_Múltiple", "email": "juanito_staff2_test_multiple@eval5.com"}');

/*
        Vista antes de usar la función
            ![1731468380550](image/evalFinalM5_Jorge_Cordova/1731468380550.png)

        Ejecutamos la función
            ![1731468543708](image/evalFinalM5_Jorge_Cordova/1731468543708.png)

        Vista después de usar la función
            ![1731468626541](image/evalFinalM5_Jorge_Cordova/1731468626541.png)

  3) OPERACIONES DE ACTUALIZACIÓN PARA LA ENTIDAD ACTOR

     * **Actualizar un actor ("UPDATE" ACTOR)**

        Al igual que con los anteriores, mostraré 3 formas de actualizar los
        registros de la tabla "ACTOR".

         * Forma simple.
         * Función con un parámetro
         * Función 2 con múltiples parámetros
*/

-- Sintáxis:
UPDATE <nombre_tabla>
SET <nombre_campo>= <valor_campo>
WHERE <condicion>;

/*
        Campos actualizables o modificables:

          * first_name
          * last_name

        Primero haremos una actualización simple por el ID del actor. Se modificará
        el nombre del "actor_id" = 204,  de "Dieguito" a "Diego Test Simple".
*/

UPDATE actor
SET first_name = 'Diego Test Simple'
WHERE actor_id = 204;

/*
        Vista antes de usar la función
            ![1731469262646](image/evalFinalM5_Jorge_Cordova/1731469262646.png)

        Ejecutamos la función
            ![1731469344202](image/evalFinalM5_Jorge_Cordova/1731469344202.png)

        Vista después de usar la función
            ![1731469394340](image/evalFinalM5_Jorge_Cordova/1731469394340.png)

     * **FUNCIÓN 1: Actualiza un actor pasando un parámetro de tipo texto**

        Párámetros:

       * "_actor_id" : El id del actor, de tipo entero.
       * "_columna"  : El nombre de una columna cualquiera, que sea de tipo texto.
       * "_valor"    : Una cadena de texto.

        Retorna: Un mensaje de confirmación por consola.

        Excepción: Esta versión sólo es para campos de tipo texto, se puede hacer una
        variante, modificando el tipo de dato por boolean, numeric, integer

        Para evitar esto, que no es tan eficiente, en la siguiente versión, se agregará
        la lógica usando JSONB, para que reciba argumentos múltiples.
*/

-- Versión una columna dinámica
CREATE OR REPLACE FUNCTION f_actualiza_actor(
    _actor_id INT,
    _columna TEXT,
    _valor TEXT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- Arma la consulta de actualización en forma dinámica
    EXECUTE format('UPDATE actor SET %I = %L WHERE actor_id = %L', _columna, _valor, _actor_id);
    
    -- Confirma que la actualización se realizó
    RAISE NOTICE '%', format('Actor ID: %s, columna %s actualizada con valor %s', _actor_id, _columna, _valor);
END;
$$;

-- **Eliminar función**
DROP FUNCTION IF EXISTS f_actualiza_actor(integer, text, text);    

-- **Ejecución**
SELECT f_actualiza_actor(205, 'first_name', 'Jorge Test Función 1 COL');

/*
        Vista antes de usar la función
            ![1731505410450](image/evalFinalM5_Jorge_Cordova/1731505410450.png)

        Ejecutamos la función
            ![1731505569946](image/evalFinalM5_Jorge_Cordova/1731505569946.png)

        Vista después de usar la función
            ![1731505624927](image/evalFinalM5_Jorge_Cordova/1731505624927.png)

     * **FUNCIÓN 2: Actualiza empleados (staff) pasando parámetros múltiples**

        Párámetros:
         * _actor_id      : El id del actor, de tipo entero.
         * _updates JSONB : Un conjunto de pares clave:valor

        Retorna: Un mensaje de confirmación por consola.

*/

-- Versión múltiples campos usando JSONB
CREATE OR REPLACE FUNCTION f_actualiza_actor_multiple(
    _actor_id INT,
    _updates JSONB
)
RETURNS TEXT
LANGUAGE plpgsql
AS
$$
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
    EXECUTE format('UPDATE actor SET %s WHERE actor_id = %L', _set_clauses, _actor_id);
    -- Mensaje con confirmación
    RETURN format('Actor ID %s: columnas actualizadas con los valores %s', _actor_id, _set_clauses);
END;
$$;

-- **Eliminar función**
DROP FUNCTION IF EXISTS f_actualiza_actor_multiple(integer, jsonb);    

-- **Ejecutar función**
SELECT f_actualiza_actor_multiple(206, '{"first_name": "Sra. Cenicienta", "last_name": "Actriz5 Test Función Múltiple"}');

/*
        Vista antes de usar la función
            ![1731505820694](image/evalFinalM5_Jorge_Cordova/1731505820694.png)

        Ejecutamos la función
            ![1731506002841](image/evalFinalM5_Jorge_Cordova/1731506002841.png)

        Vista después de usar la función
            ![1731506046211](image/evalFinalM5_Jorge_Cordova/1731506046211.png)

## CONSULTAS ESPECÍFICAS (QUERIES)

  1) CLIENTES QUE HAN RENTADO POR AÑO Y MES

     * **Análisis**

        Esta consulta debe traer todos los arrendamientos de un cliente para
        un determinado mes y año.

        a) Para eficientar las consultas, primero que todo, podemos crear un
           índice en la tabla, sobre el 'campo rental_date', esto mejorará el
           rendimiento de la consulta.
*/

CREATE INDEX idx_rental_rental_date ON rental(rental_date);  -- Crea el índice si no existe, se ejecuta 1 vez.
  
/*
        b) Para no iterar entre pruebas y errores, buscando los años y meses
           que si tienen registros, primero, analizamos la cardinalidad de los
           arrendamientos por mes y año. Así podemos determinar qué períodos
           se pueden consultar y organizar mejor una consulta más eficiente.
*/

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

/*
        ![1731514600307](image/evalFinalM5_Jorge_Cordova/1731514600307.png)

        c) Luego, podemos ir armando progresivamente nuestra consulta SQL simple.
           Para el ejemplo, la consulta trae todos los registros de arrendamientos,
           para un año y mes determinado, en este caso 2006 y mes 02, pero falta
           hacerlo para un "customer" específico.
*/

SELECT rental.*, customer.*                                      -- Selecciona tablas rental y customer
FROM rental                                                      -- Trae los datos de la tabla rental
INNER JOIN customer ON rental.customer_id = customer.customer_id -- Une datos usando el id de cliente
WHERE DATE_PART('YEAR', rental_date) = 2006 AND                  -- Filtra los resultados por año
    DATE_PART('MONTH', rental_date)  = 02                        -- Filtra los resultados por mes
ORDER BY rental_date;                                            -- Ordena los resultados por fecha

/*
        ![1731536632721](image/evalFinalM5_Jorge_Cordova/1731536632721.png)

     * **Solución**

        La forma simple, es hacerlo a través de una consulta en la que indiquemos
        el "customer_id", un año y mes específicos, de la siguiente manera:
*/

SELECT 
    rental.rental_id, 
    rental.rental_date, 
    rental.customer_id, 
    customer.first_name, 
    customer.last_name
FROM 
    rental
INNER JOIN 
    customer ON rental.customer_id = customer.customer_id
WHERE 
    rental.customer_id = 300 
    AND DATE_PART('YEAR', rental.rental_date) = 2005
    AND DATE_PART('MONTH', rental.rental_date) = 7
ORDER BY 
    rental.rental_date ASC;

/*    
        Lo cual retornará:
            ![1731522671513](image/evalFinalM5_Jorge_Cordova/1731522671513.png)

        Una solución más elaborada, es usar una función que retorne la consulta.
        La siguiente función, "f_listar_por_customer_annio_y_mes()", permite pasar
        como parámetros, el valor del "customer id", un año y mes específicos.

        **Recibe  :** Valores enteros para el "customer_id", año y mes.

        Se recomienda hacer algunas consultas previas para conocer el rango de
        fechas y la cardinalidad de los meses para saber si lo que retorna la
        consulta es correcto Y COHERENTE.

        **Retorna :** Hace una unión entre "rental" y la tabla "customer", a
                      través del id del cliente y trae los registros de la
                      tabla "rental" (arrendamiento de películas) para un año y
                      mes específico, para un cliente particular.
*/

CREATE OR REPLACE FUNCTION f_listar_por_customer_annio_y_mes(
    _customer_id INT,
    _year INT,
    _month INT
)
RETURNS TABLE (
    rental_id INT,
    rental_date TIMESTAMP WITHOUT TIME ZONE,
    customer_id INT,
    first_name character varying,
    last_name character varying
)
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.rental_id,
        r.rental_date,
        c.customer_id,
        c.first_name,
        c.last_name
    FROM rental AS r
    INNER JOIN customer AS c ON r.customer_id = c.customer_id
    WHERE r.customer_id = _customer_id
        AND DATE_PART('YEAR', r.rental_date) = _year
        AND DATE_PART('MONTH', r.rental_date) = _month
    ORDER BY r.rental_date;
END;
$$
LANGUAGE plpgsql;

-- * **Eliminar la función**
DROP FUNCTION IF EXISTS f_listar_por_customer_annio_y_mes(integer, integer, integer);

-- * **Ejecutar la función**
-- Como retorna un json, le anteponemos "* from", para que desempaquete
-- el diccionario y lo muestre como una tabla separada por columnas.

SELECT * from f_listar_por_customer_annio_y_mes(300, 2005, 7);

/*
     * **Vista de la consulta usando la función**

        ![1731535785610](image/evalFinalM5_Jorge_Cordova/1731535785610.png)

  2) LISTAR TODOS LOS PAGOS ACUMULADOS POR FECHA

     * **Análisis**

        Esta consulta debe traer la cantidad y el monto total de pagos por fecha.
        Por ejemplo, el día 1/1/2005, se hicieron 10 ventas, que totalizaron $80,99.

     * **Consulta simple**

        La forma sencilla de resolverlo es a través de una consulta que agrupe
        por fecha, las ventas del día, esta es la consulta:

*/
-- Listar acumulado de payments por fecha
SELECT 
    CAST(payment_date AS DATE) AS "Fecha de Pago", 
    COUNT(*) AS "Cantidad de Pagos",
    SUM(amount) AS "Acumulado Venta"
FROM payment
GROUP BY CAST(payment_date AS DATE)
ORDER BY CAST(payment_date AS DATE);

/*
     * **Vista de la consulta simple**

        ![1731540938759](image/evalFinalM5_Jorge_Cordova/1731540938759.png)

     * **Function: f_listar_acumulado_ventas_fecha()**

        Trataremos de proponer una solución más elaborada, que permita recibir
        parámetros como el año o mes y, por defecto, traiga todas las ventas de
        la tabla "payment".

*/
CREATE OR REPLACE FUNCTION f_listar_acumulado_ventas_fecha(
        p_year INT DEFAULT NULL
    )
RETURNS TABLE (
        payment_date DATE,
        v_qtty_pagos BIGINT,
        v_amount_pagos NUMERIC
    )
AS $$
BEGIN
    RETURN QUERY
    SELECT CAST(p.payment_date AS DATE),
           COUNT(*) AS v_qtty_pagos,
           SUM(p.amount) AS v_amount_pagos
    FROM payment AS p
    WHERE p_year IS NULL OR EXTRACT(YEAR FROM p.payment_date) = p_year
    GROUP BY CAST(p.payment_date AS DATE)
    ORDER BY CAST(p.payment_date AS DATE);
END;
$$
LANGUAGE plpgsql;

-- * **Eliminar la función**
DROP FUNCTION IF EXISTS f_listar_acumulado_ventas_fecha(integer);

/*
     * **Vista de la consulta usando la función, por defecto toma todo el período**

        ![1731545545597](image/evalFinalM5_Jorge_Cordova/1731545545597.png)

        Si probamos con otros años, por ejemplo año=2006, dentro del rango de
        fechas, se verifica que no hay datos, es decir, la consulta no retorna
        registros.

        ![1731546201877](image/evalFinalM5_Jorge_Cordova/1731546201877.png)

        Se puede verificar que sólo 2007 tiene datos mirando la tabla o, con una
        consulta como la siguiente, que muestre qué mes y año tiene ventas, para
        el caso, comprobamos que no hay más datos, lo que también se confirma al
        mirar la tabla "payment":

        ![1731546656602](image/evalFinalM5_Jorge_Cordova/1731546656602.png)

  3) LISTAR TODOS LOS FILMS DEL AÑO 2006, QUE TENGAN UNA CALIFICACIÓN MAYOR A 4.0

     * **Análisis**

        Esta consulta SQL debe permitir obtener una lista de todas las películas
        del año 2006 que tengan una calificación superior a 4.

        Como no hay una especificación, y para simplificar la vista, asumiremos
        que los campos requeridos son:

        * film_id: Identificador único de la película.
        * title: Título de la película.
        * release_year: Año de lanzamiento de la película.
        * rental_rate: Calificación de la película.

     * **Consulta simple**

        En forma directa y sencilla, generamos un "select" a la tabla "film",
        indicando los campos que queremos ver, a los que les hemos dado un "nombre
        semnático" o más entendible.

*/

SELECT film_id as "id pelicula", 
       title as "Título del film", 
       release_year "Año de estreno", 
       rental_rate "Calificación"
FROM film
WHERE release_year = 2006
AND rental_rate > 4;

/*
     * **Vista de la consulta simple**

        ![1731547616867](image/evalFinalM5_Jorge_Cordova/1731547616867.png)

     * **Function: f_listar_por_annio_y_rate()**

        Siguiendo el enfoque metodológico, agregaremos complejidad mediante una
        solución más elaborada, que permita recibir como parámetros el año y la
        calificación, para que que la consulta sea dinámica.

*/

CREATE OR REPLACE FUNCTION f_listar_por_annio_y_rate(
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

-- * **Eliminar la función**
DROP FUNCTION IF EXISTS f_listar_por_annio_y_rate(integer, numeric);

/*
     * **Vista de la consulta usando la función "f_listar_por_annio_y_rate()"**

        ![1731550621093](image/evalFinalM5_Jorge_Cordova/1731550621093.png)

        Se puede verificar que sólo 2006 tiene datos mirando la tabla o, con una
        consulta que omita el año "2006", para que los liste todos:

        ![1731551522394](image/evalFinalM5_Jorge_Cordova/1731551522394.png)

## DICCIONARIO DE DATOS

En la documentación, se ha incluido el diccionario en formato csv, con el nombre
"diccionario_datos_dvdrental.csv".
*/

-- * **Script de creación del diccionario**
SELECT
    t1.TABLE_NAME AS "Tabla",
    t1.COLUMN_NAME AS "Columna",
    t1.COLUMN_DEFAULT AS "Valor por defecto",
    t1.IS_NULLABLE AS "Acepta nulos",
    t1.DATA_TYPE AS "Tipo de dato",
    COALESCE(t1.NUMERIC_PRECISION,
    t1.CHARACTER_MAXIMUM_LENGTH) AS "Longitud de columna",
    PG_CATALOG.COL_DESCRIPTION(t2.OID,
    t1.DTD_IDENTIFIER::int) AS "Descripción columna",
    t1.DOMAIN_NAME AS "Nombre dominio"
FROM 
    INFORMATION_SCHEMA.COLUMNS t1
    INNER JOIN PG_CLASS t2 ON (t2.RELNAME = t1.TABLE_NAME)
WHERE 
    t1.TABLE_SCHEMA = 'public'
ORDER BY
    t1.TABLE_NAME;

/*
* **Vista de la consulta "Diccionario"**

    ![1731556431685](image/evalFinalM5_Jorge_Cordova/1731556431685.png)

## PROCEDIMIENTO BACKUP BBDD

* **Consola**

    Usando la línea de comandos de CMD o PS, se puede ingresar la siguiente instrucción de pg_dump.

            ```bash
            pg_dump -h localhost -U evaluador -F t -f "C:\backup_pgsql\backup_dvdrentalTest_JCordova.tar" dvdrentalTest
            ```

    Significado de las opciones usadas:

  * **-h localhost:** Especifica el host, en este caso "localhost".
  * **-U evaluador:** El nombre de usuario que se utilizará para conectarse a la base de datos. Se creo un superuser "evaluador"
  * **-F t:** Formato de salida "tar".
  * **-f "C:\backup_pgsql\backup_dvdrentalTest_JCordova.tar":** Ruta y nombre del archivo de respaldo.
  * **"dvdrentalTest":** Nombre de la BBDD a respaldar.

* **PgAdmin**

    Paso 1: Abrir la interfaz de PgAdmin y posicionar el cursor sobre la bbdd
            que se va a respaldar.

    Paso 2: Hacer click sobre el nombre de la base y se desplegará un menú
            contextual, buscar la opción **"Backup"** y presionar.

    ![1731611515716](image/evalFinalM5_Jorge_Cordova/1731611515716.png)

    Paso 3: Se abrirá una ventana donde deberá rellenar los campos:

  * Filename: Un nombre identificatorio para el respaldo, en mi caso,
              "backup_pgadmin_dvdrental_jcordova.tar", procurando que
              quede en la ruta donde se guardará, en este caso y como
              ejemplo.

                "C:\backup_pgsql\backup_pgadmin_dvdrental_jcordova.tar"

  * Format: Para este caso seleccionaremos "tar", formato comprimido.

  * Compress ratio: Lo dejaremos en blanco

  * Encoding: De la lista se escogerá UTF-8

  * Number of jobs: No se toca.

  * Role name: Indicamos que usuario tiene privilegios sobre la base. Para
               este caso, hemos creado un usuario distinto, para asegurar
               la trazabilidad e independencia de las acciones que pueda 
               realizar, por lo tanto, se escoge "evaluador".

--    ![1731613037567](image/evalFinalM5_Jorge_Cordova/1731613037567.png)

    Paso 4: Presionar Aceptar y comenzará el proceso, al terminar sale un mensaje:

--    ![1731612811640](image/evalFinalM5_Jorge_Cordova/1731612811640.png)

    Revisar en el explorador de archivos
--    ![1731613109196](image/evalFinalM5_Jorge_Cordova/1731613109196.png)

## ANEXOS

* **Superusuario**

    user: "evaluador"

    pass: 123456

* **Archivos complementarios**
  
  * SQL: evalFinalM5_JCordova.sql
  * Diccionario de datos: diccionario_datos_dvdrental.csv
  * README: evalFinalM5_Jorge_Cordova.md
  * HTML: evalFinalM5.html
  * PDF: evalFinalM5.pdf
  * Backup consola: backup_dvdrentalTest_JCordova.tar
  * Backup PgAdmin: backup_pgadmin_dvdrental_jcordova.tar

*/  