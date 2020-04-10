/*Query 01: How many rental orders we have for each category of family movies?*/

SELECT DISTINCT (film_title),
	category_name AS category,
	COUNT(rental_ID) OVER (PARTITION BY film_title ) AS rental_count

FROM ( SELECT f.title film_title
      , c.name category_name
      ,r.rental_id rental_ID
      FROM category c
      JOIN film_category fc
      ON c.category_id = fc.category_id
      JOIN film f
      ON fc.film_id = f.film_id
      JOIN inventory i
      ON i.film_id = f.film_id
      JOIN rental r
      ON i.inventory_id = r.inventory_id
      WHERE c.name IN ('Animation' , 'Comedy' , 'Classics' , 'Children' ,'Family' , 'Music')
      ) Sub
ORDER BY category_name



/*Query 02: What is the rental count given the rental length for each family-friendly category?*/

SELECT category_name AS name, 
	   standard_quartile, 
       COUNT(standard_quartile) AS count
FROM
    (SELECT f.title film_title, c.name category_name, f.rental_duration ,
           NTILE(4) OVER (ORDER BY f.rental_duration) standard_quartile
    FROM  film f
    JOIN  film_category fc
    ON    fc.film_id = f.film_id
    JOIN  category c
    ON    fc.category_id = c.category_id
    WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
    ORDER BY 3) sub1
GROUP BY name, standard_quartile
ORDER BY name, standard_quartile;



/*Query 03 - How many rental orders each store has per month?*/

SELECT   DATE_PART('month', r.rental_date ) AS rental_month,
         DATE_PART('year', r.rental_date ) AS rental_year,
         sto.store_id,
         COUNT(*) as count_rentals
FROM     rental r
JOIN     staff sta
ON 	 sta.staff_id = r.staff_id
JOIN     store sto
ON       sto.store_id = sta.store_id
GROUP BY rental_month, rental_year, sto.store_id
ORDER BY count_rentals DESC



/*Query 04 - Who were our top 10 paying customers and how many monthly payments they made in 2007?*/

WITH t1 AS (SELECT p.customer_id, c.first_name || ' ' || c.last_name full_name, SUM(amount) payment_total
            FROM payment p
            JOIN customer c
            ON c.customer_id = p.customer_id
            GROUP BY 1, 2
            ORDER BY 3 DESC
            LIMIT 10)

SELECT   DATE_TRUNC('month', p.payment_date) payment_month, t1.full_name, COUNT(*) payment_count, SUM(p.amount) payment_amount
FROM     t1
JOIN     payment p
ON       p.customer_id = t1.customer_id
GROUP BY 1, 2
ORDER BY 2, 1;