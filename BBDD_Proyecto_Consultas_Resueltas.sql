--*CONSULTAS RESUELTAS BBDD_PROYECTO*--

--1. Crea el esquema de la BBDD.

CREATE TABLE actor (
    actor_id SERIAL PRIMARY KEY,
    first_name VARCHAR(45) NOT NULL,
    last_name VARCHAR(45) NOT NULL
);

CREATE TABLE address (
    address_id SERIAL PRIMARY KEY,
    address VARCHAR(50) NOT NULL,
    address2 VARCHAR(50),
    district VARCHAR(20) NOT NULL,
    city_id INT NOT NULL REFERENCES city(city_id),
    postal_code VARCHAR(10),
    phone VARCHAR(20) NOT NULL
);

CREATE TABLE category (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(25) NOT NULL
);

CREATE TABLE city (
    city_id SERIAL PRIMARY KEY,
    city VARCHAR(50) NOT NULL,
    country_id INT NOT NULL REFERENCES country(country_id)
);

CREATE TABLE country (
    country_id SERIAL PRIMARY KEY,
    country VARCHAR(50) NOT NULL
);

CREATE TABLE customer (
    customer_id SERIAL PRIMARY KEY,
    store_id INT NOT NULL REFERENCES store(store_id),
    first_name VARCHAR(45) NOT NULL,
    last_name VARCHAR(45) NOT NULL,
    email VARCHAR(50),
    address_id INT NOT NULL REFERENCES address(address_id),
    active BOOLEAN DEFAULT TRUE NOT NULL,
    create_date DATE DEFAULT CURRENT_DATE NOT NULL
);

CREATE TABLE film (
    film_id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    release_year SMALLINT,
    language_id INT NOT NULL REFERENCES language(language_id),
    original_language_id INT REFERENCES language(language_id),
    rental_duration SMALLINT DEFAULT 3 NOT NULL,
    rental_rate NUMERIC(4,2) DEFAULT 4.99 NOT NULL,
    length SMALLINT,
    replacement_cost NUMERIC(5,2) DEFAULT 19.99 NOT NULL,
    rating VARCHAR(5) CHECK (rating IN ('G','PG','PG-13','R','NC-17')),
    special_features TEXT[]
);

CREATE TABLE film_actor (
    film_id INT NOT NULL REFERENCES film(film_id),
    actor_id INT NOT NULL REFERENCES actor(actor_id),
    PRIMARY KEY (film_id, actor_id)
);

CREATE TABLE film_category (
    film_id INT NOT NULL REFERENCES film(film_id),
    category_id INT NOT NULL REFERENCES category(category_id),
    PRIMARY KEY (film_id, category_id)
);

CREATE TABLE inventory (
    inventory_id SERIAL PRIMARY KEY,
    film_id INT NOT NULL REFERENCES film(film_id),
    store_id INT NOT NULL REFERENCES store(store_id)
);

CREATE TABLE language (
    language_id SERIAL PRIMARY KEY,
    name CHAR(20) NOT NULL
);

CREATE TABLE payment (
    payment_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customer(customer_id),
    staff_id INT NOT NULL REFERENCES staff(staff_id),
    rental_id INT NOT NULL REFERENCES rental(rental_id),
    amount NUMERIC(5,2) NOT NULL,
    payment_date TIMESTAMP NOT NULL
);

CREATE TABLE rental (
    rental_id SERIAL PRIMARY KEY,
    rental_date TIMESTAMP NOT NULL,
    inventory_id INT NOT NULL REFERENCES inventory(inventory_id),
    customer_id INT NOT NULL REFERENCES customer(customer_id),
    return_date TIMESTAMP,
    staff_id INT NOT NULL REFERENCES staff(staff_id)
);

CREATE TABLE staff (
    staff_id SERIAL PRIMARY KEY,
    first_name VARCHAR(45) NOT NULL,
    last_name VARCHAR(45) NOT NULL,
    address_id INT NOT NULL REFERENCES address(address_id),
    email VARCHAR(50),
    store_id INT NOT NULL REFERENCES store(store_id),
    active BOOLEAN DEFAULT TRUE NOT NULL,
    username VARCHAR(16) NOT NULL,
    password VARCHAR(40)
);

CREATE TABLE store (
    store_id SERIAL PRIMARY KEY,
    manager_staff_id INT NOT NULL,
    address_id INT NOT NULL REFERENCES address(address_id)
);


--2. Muestra los nombres de todas las películas con una clasificación por edades de ‘R’.

SELECT  title
FROM film f
WHERE f.rating = 'R';


--3. Encuentra los nombres de los actores que tengan un “actor_id” entre 30 y 40.

SELECT  first_name
FROM actor a
WHERE a.actor_id BETWEEN 30 AND 40;


--4. Obtén las películas cuyo idioma coincide con el idioma original.

SELECT  title
FROM film f
WHERE f.language_id = f.original_language_id;


--5. Ordena las películas por duración de forma ascendente.

SELECT  title
FROM film f
ORDER BY f.length asc;


--6. Encuentra el nombre y apellido de los actores que tengan ‘Allen’ en su apellido.

SELECT  first_name, a.last_name
FROM actor a
WHERE a.last_name ilike '%Allen%';  --ilike lo tuve que buscar porque en la BBDD Allen está registrado como ALLEN


--7. Encuentra la cantidad total de películas en cada clasificación de la tabla “film” y muestra la clasificación junto con el recuento.

SELECT  COUNT(f.title ), f.rating
FROM film f
GROUP BY  f.rating;


--8. Encuentra el título de todas las películas que son ‘PG-13’ o tienen una duración mayor a 3 horas en la tabla film.

SELECT  title
FROM film f
WHERE f.rating = 'PG-13' or f.length > 180;


--9. Encuentra la variabilidad de lo que costaría reemplazar las películas.

SELECT  variance(f.replacement_cost) AS "variance_replacement_cost"
FROM film f;


--10. Encuentra la mayor y menor duración de una película de nuestra BBDD.

SELECT  MAX(f.length), MIN(f.length)
FROM film f;


--11. Encuentra lo que costó el antepenúltimo alquiler ordenado por día.

SELECT  p.amount, r.rental_date
FROM rental r
JOIN payment p ON r.rental_id = p.rental_id offset (
SELECT  COUNT(*) - 3 FROM rental);


--12. Encuentra el título de las películas en la tabla “film” que no sean ni ‘NC17’ ni ‘G’ en cuanto a su clasificación.

SELECT  f.title
FROM film f
WHERE f.rating NOT IN ('NC-17', 'G');


--13. Encuentra el promedio de duración de las películas para cada clasificación de la tabla film y muestra la clasificación junto con el promedio de duración.

SELECT  AVG(f.length), f.rating
FROM film f
GROUP BY  f.rating;


--14. Encuentra el título de todas las películas que tengan una duración mayor a 180 minutos.

SELECT  title
FROM film f
WHERE f.length > 180;


--15. ¿Cuánto dinero ha generado en total la empresa?

SELECT  SUM(p.amount) AS "total_earnings"
FROM payment p;


--16. Muestra los 10 clientes con mayor valor de id.

SELECT  *
FROM customer c
ORDER BY c.customer_id DESC
LIMIT 10;


--17. Encuentra el nombre y apellido de los actores que aparecen en la película con título ‘Egg Igby’.

SELECT  a.first_name, a.last_name
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film f ON fa.film_id = f.film_id
WHERE f.title ilike 'Egg Igby'; --He aplicado mi aprendizaje sobre el método ilike para solucionar el mismo problema que sucedía anteriormente


--18. Selecciona todos los nombres de las películas únicos.

SELECT  distinct f.title
FROM film f;


--19. Encuentra el título de las películas que son comedias y tienen una duración mayor a 180 minutos en la tabla “film”.

SELECT  f.title
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON c.category_id = fc.category_id
WHERE c.name = 'Comedy' AND f.length > 180;


--20. Encuentra las categorías de películas que tienen un promedio de duración superior a 110 minutos y muestra el nombre de la categoría junto con el promedio de duración.

SELECT  AVG(f.length), c."name"
FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
JOIN film f ON f.film_id = fc.film_id
GROUP BY  "name"
HAVING AVG(f.length) > 110;


--21. ¿Cuál es la media de duración del alquiler de las películas?

SELECT  AVG(f.rental_duration) AS film_rental_duration
FROM film f;


--22. Crea una columna con el nombre y apellidos de todos los actores y actrices.

SELECT  concat("first_name",' ',"last_name") AS full_name
FROM actor a;


--23. Números de alquiler por día, ordenados por cantidad de alquiler de forma descendente.

SELECT  DATE(r.rental_date) AS days_rented, COUNT(r.rental_id)  AS rents_amount
FROM rental r
GROUP BY  DATE(r.rental_date)
ORDER BY  rents_amount desc;


--24. Encuentra las películas con una duración superior al promedio.

SELECT  f.title
FROM film f
WHERE f.length > (SELECT  AVG(length) FROM film);


--25. Averigua el número de alquileres registrados por mes.

SELECT  date_part('month',r.rental_date) AS months, COUNT(*) AS num_rents --el uso de date_part permite quedarte solo con la parte deseada de una fecha 
FROM rental r
GROUP BY  months
ORDER BY  months asc;


--26. Encuentra el promedio, la desviación estándar y varianza del total pagado.

SELECT  AVG(p.amount) AS avg_total_payment,
        stddev(p.amount) AS total_sta_dev,
        variance(p.amount) AS total_variance
FROM payment p;


--27. ¿Qué películas se alquilan por encima del precio medio?

SELECT  f.title
FROM film f
WHERE f.rental_rate > (SELECT AVG(rental_rate) FROM film)
ORDER BY f.rental_rate desc;


--28. Muestra el id de los actores que hayan participado en más de 40 películas.

SELECT  a.actor_id
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film f ON f.film_id = fa.film_id
GROUP BY a.actor_id
HAVING COUNT(f.film_id) > 40;


--29. Obtener todas las películas y, si están disponibles en el inventario, mostrar la cantidad disponible.

SELECT  f.title, COUNT(i.inventory_id) AS available_quantity
FROM film f
LEFT JOIN inventory i ON f.film_id = i.film_id --left join coge todas las películas, sin importar si están disponibles en el inventario
GROUP BY  f.title
ORDER BY  available_quantity;


--30. Obtener los actores y el número de películas en las que ha actuado.

SELECT  concat(a.first_name,' ',a.last_name) AS full_name, COUNT(f.film_id) AS num_film --he vuelto a usar el uso de CONCAT() aprendido anteriormente para dar el nombre y apellido de los actores en una sola columna
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film f ON fa.film_id = f.film_id
GROUP BY  a.first_name, a.last_name
ORDER BY  a.first_name;


--31. Obtener todas las películas y mostrar los actores que han actuado en ellas, incluso si algunas películas no tienen actores asociados.

SELECT  f.title, concat(a.first_name,' ',a.last_name) AS full_name
FROM film f
LEFT JOIN film_actor fa ON f.film_id = fa.film_id
LEFT JOIN actor a ON fa.actor_id = a.actor_id
ORDER BY f.title;


--32. Obtener todos los actores y mostrar las películas en las que han actuado, incluso si algunos actores no han actuado en ninguna película.

SELECT  concat(a.first_name,' ',a.last_name) AS full_name, f.title
FROM actor a
LEFT JOIN film_actor fa ON fa.actor_id = a.actor_id
LEFT JOIN film f ON f.film_id = fa.film_id
ORDER BY a.first_name;


--33. Obtener todas las películas que tenemos y todos los registros de alquiler.

SELECT  f.title, r.rental_date, f.rental_duration
FROM film f
LEFT JOIN inventory i ON f.film_id = i.film_id
LEFT JOIN rental r ON i.inventory_id = r.inventory_id
ORDER BY f.title, r.rental_date;


--34. Encuentra los 5 clientes que más dinero se hayan gastado con nosotros.

SELECT  concat(c.first_name,' ',c.last_name) AS full_name, SUM(p.amount) AS total_pay
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY  c.first_name, c.last_name
ORDER BY  total_pay DESC --el uso de desc hace que nos quedemos con los 5 registros con el pago total más alto
LIMIT 5;


--35. Selecciona todos los actores cuyo primer nombre es 'Johnny'.

SELECT  *
FROM actor a
WHERE a.first_name ilike 'Johnny';


--36. Renombra la columna “first_name” como Nombre y “last_name” como Apellido.

alter table actor 
rename column first_name to "Nombre";  --he intentado hacer los dos cambios a la vez pero me ha dado error, asi que he aprendido que hay que hacerlos individualmente

alter table actor
rename column last_name to "Apellido"; --acordarse de 'refrescar' la BBDD cuando haces algún cambio para poder verlo

--37. Encuentra el ID del actor más bajo y más alto en la tabla actor.

SELECT  MAX(a.actor_id), MIN(a.actor_id)
FROM actor a;


--38. Cuenta cuántos actores hay en la tabla “actor”.

SELECT  COUNT(a.actor_id)
FROM actor a;


--39. Selecciona todos los actores y ordénalos por apellido en orden ascendente.

SELECT  concat(a."Nombre",' ',a."Apellido") AS full_name
FROM actor a
ORDER BY a."Apellido" asc;


--40. Selecciona las primeras 5 películas de la tabla “film”.

SELECT  f.title
FROM film f
LIMIT 5;


--41. Agrupa los actores por su nombre y cuenta cuántos actores tienen el mismo nombre. ¿Cuál es el nombre más repetido?

SELECT  a."Nombre", COUNT(a."Nombre") AS num_names
FROM actor a
GROUP BY  "Nombre"
ORDER BY  num_names desc; -- usando LIMIT 1 podríamos saber cual es el nombre más repetido, aunque en este caso hay tres nombres que se repiten: Kenneth, Penelope y Julia


--42. Encuentra todos los alquileres y los nombres de los clientes que los realizaron.

SELECT  r.rental_id, r.rental_date, r.return_date, concat(c.first_name,' ', c.last_name) AS full_name
FROM rental r
JOIN customer c ON c.customer_id = r.customer_id
ORDER BY r.rental_id;


--43. Muestra todos los clientes y sus alquileres si existen, incluyendo aquellos que no tienen alquileres.

SELECT  concat(c.first_name,' ',c.last_name) AS full_name, r.rental_id, r.rental_date, r.return_date
FROM customer c
LEFT JOIN rental r
ON c.customer_id = r.customer_id;


--44. Realiza un CROSS JOIN entre las tablas film y category. ¿Aporta valor esta consulta? ¿Por qué? Deja después de la consulta la contestación.

SELECT  *
FROM film f
CROSS JOIN category c;

/*CONTESTACIÓN: No aporta ningún valor; el CROSS JOIN junta las columnas de una tabla con las de otra sin
 importar si coinciden o no sus id, lo que provoca que para cada película que solo puede tener registrada 
 una categoría (en este caso), esto se rompa y a cada película le pertenecen ahora todos los tipos de categorías*/


--45. Encuentra los actores que han participado en películas de la categoría 'Action'.

SELECT  concat(a."Nombre",' ',a."Apellido") AS full_name
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film f ON fa.film_id = f.film_id
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
WHERE c."name" ilike 'Action';


--46. Encuentra todos los actores que no han participado en películas.

SELECT  concat(a."Nombre",' ',a."Apellido") AS full_name
FROM actor a
WHERE not exists(
SELECT  1
FROM film_actor fa
WHERE a.actor_id = fa.actor_id);


--47. Selecciona el nombre de los actores y la cantidad de películas en las que han participado.

SELECT  concat(a."Nombre",' ',a."Apellido") AS full_name, COUNT(f.film_id) AS total_films
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film f ON f.film_id = fa.film_id
GROUP BY  a."Nombre", a."Apellido";


--48. Crea una vista llamada “actor_num_peliculas” que muestre los nombres de los actores y el número de películas en las que han participado.

create view actor_num_peliculas as
select concat(a."Nombre", ' ', a."Apellido") as full_name, count(f.film_id) as total_films
from actor a
join film_actor fa on a.actor_id = fa.actor_id
join film f on f.film_id = fa.film_id
group by a.actor_id, a."Nombre", a."Apellido";

select *
from actor_num_peliculas; -- así podemos acceder a los datos de la vista recién creada

drop view actor_num_peliculas; -- se usa para borrar una vista, en este caso como me había equivocado la primera vez, he necesitado borrar esa vista para poder hacerla de nuevo


--49. Calcula el número total de alquileres realizados por cada cliente.

SELECT  concat(c.first_name,' ',c.last_name) AS full_name, COUNT(r.rental_id) AS total_rent
FROM customer c
LEFT JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.first_name, c.last_name
ORDER BY total_rent desc;


--50. Calcula la duración total de las películas en la categoría 'Action'.

SELECT  f.title, f.length
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
WHERE c."name" ilike 'Action'
ORDER BY f.length;


--51. Crea una tabla temporal llamada “cliente_rentas_temporal” para almacenar el total de alquileres por cliente.

CREATE temporary TABLE cliente_rentas_temporal AS
SELECT  concat(c.first_name,' ',c.last_name) AS full_name, COUNT(r.rental_id) AS total_rent
FROM customer c
LEFT JOIN rental r ON c.customer_id = r.customer_id
GROUP BY  c.first_name, c.last_name;

SELECT  *                       --esta parte solo sirve para llamar a la tabla temporal creada
FROM cliente_rentas_temporal;


--52. Crea una tabla temporal llamada “peliculas_alquiladas” que almacene las películas que han sido alquiladas al menos 10 veces.

CREATE temporary TABLE peliculas_alquiladas AS
SELECT  f.title
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY  f.title
HAVING COUNT(r.rental_id) > 9;

SELECT  *
FROM peliculas_alquiladas;


--53. Encuentra el título de las películas que han sido alquiladas por el cliente con el nombre ‘Tammy Sanders’ y que aún no se han devuelto. Ordena los resultados alfabéticamente por título de película.

SELECT  f.title
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN customer c ON r.customer_id = c.customer_id
WHERE c.first_name ilike 'Tammy' AND c.last_name ilike 'Sanders' AND r.return_date is null
ORDER BY f.title asc;


--54. Encuentra los nombres de los actores que han actuado en al menos una película que pertenece a la categoría ‘Sci-Fi’. Ordena los resultados alfabéticamente por apellido.

SELECT  concat(a."Nombre",' ',a."Apellido") AS full_name
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film f ON fa.film_id = f.film_id
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
WHERE c."name" ilike 'Sci-Fi'
GROUP BY  a."Nombre", a."Apellido", a.actor_id
ORDER BY  a."Apellido" asc;


--55. Encuentra el nombre y apellido de los actores que han actuado en películas que se alquilaron después de que la película ‘Spartacus Cheaper’ se alquilara por primera vez. Ordena los resultados alfabéticamente por apellido.


SELECT  distinct a."Nombre", a."Apellido"
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film f ON fa.film_id = f.film_id
JOIN inventory i ON f.film_id = i.inventory_id
JOIN rental r ON i.inventory_id = r.inventory_id
WHERE r.rental_date > (
    SELECT  MIN(r2.rental_date)
    FROM film f2
    JOIN inventory i2 ON f2.film_id = i2.film_id
    JOIN rental r2 ON i2.inventory_id = r2.inventory_id
    WHERE f2.title ilike 'Spartacus Cheaper' 
)
ORDER BY a."Apellido" asc;


--56. Encuentra el nombre y apellido de los actores que no han actuado en ninguna película de la categoría ‘Music’.

SELECT  concat(a."Nombre",' ',a."Apellido") AS full_name
FROM actor a
WHERE not exists(
    SELECT  1
    FROM film_actor fa
    JOIN film f ON fa.film_id = f.film_id
    JOIN film_category fc ON f.film_id = fc.film_id
    JOIN category c ON fc.category_id = c.category_id
    WHERE fa.actor_id = a.actor_id AND c."name" ilike 'Music' 
)
ORDER BY a."Apellido" asc;


--57. Encuentra el título de todas las películas que fueron alquiladas por más de 8 días.

SELECT  f.title
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
WHERE (r.return_date - r.rental_date) > interval '8 days'; --he aprendido que una operación de dos TIMESTAMPS da como resultado un intervalo, en este caso ponemos '8 days' porque queremos quedarnos con los que tengan más de 8 días


--58. Encuentra el título de todas las películas que son de la misma categoría que ‘Animation’.

SELECT  f.title
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
WHERE c."name" ilike 'Animation'
ORDER BY f.title asc;


--59. Encuentra los nombres de las películas que tienen la misma duración que la película con el título ‘Dancing Fever’. Ordena los resultados alfabéticamente por título de película.

SELECT  f.title
FROM film f
WHERE f.length = (
    SELECT  f2.length
    FROM film f2
    WHERE f2.title ilike 'Dancing Fever' 
)
ORDER BY f.title asc;


--60. Encuentra los nombres de los clientes que han alquilado al menos 7 películas distintas. Ordena los resultados alfabéticamente por apellido.

SELECT  c.first_name, c.last_name
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
GROUP BY  c.customer_id, c.first_name, c.last_name
HAVING COUNT(f.film_id) > 6
ORDER BY c.last_name asc;


--61. Encuentra la cantidad total de películas alquiladas por categoría y muestra el nombre de la categoría junto con el recuento de alquileres.

SELECT  c."name", COUNT(r.rental_id) AS total_rents
FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
JOIN film f ON fc.film_id = f.film_id
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY c."name"
ORDER BY total_rents asc;


--62. Encuentra el número de películas por categoría estrenadas en 2006.

SELECT  c."name", COUNT(f.film_id) AS total_film
FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
JOIN film f ON fc.film_id = f.film_id
WHERE f.release_year = 2006
GROUP BY c."name"
ORDER BY total_film asc;


--63. Obtén todas las combinaciones posibles de trabajadores con las tiendas que tenemos.

SELECT  s.first_name, s.last_name, s.store_id
FROM staff s
CROSS JOIN store s2;


--64. Encuentra la cantidad total de películas alquiladas por cada cliente y muestra el ID del cliente, su nombre y apellido junto con la cantidad de películas alquiladas.

SELECT  c.customer_id, c.first_name, c.last_name, COUNT(r.rental_id) AS total_rents
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
GROUP BY  c.customer_id, c.first_name, c.last_name
ORDER BY  c.customer_id;