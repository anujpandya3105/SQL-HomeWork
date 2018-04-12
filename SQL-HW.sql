#Make the sakila database the current DB. All queries
#will run against this database.
use sakila;

#1a. 
select first_name, last_name from sakila.actor;

#1b
select concat(upper(first_name), ' ', upper(last_name)) as 'Actor Name'
from sakila.actor;

#2a
select actor_id , first_name,  last_name 
from sakila.actor
where lower(first_name) = lower('Joe');

#2b
select * from sakila.actor
where upper(last_name) like upper('%GEN%');

#2c
select * from sakila.actor
where upper(last_name) like upper('%LI%')
order by last_name, first_name;

#2d
select country_id, country from country
where country in ('Afghanistan', 'Bangladesh', 'China');

#3a
alter table sakila.actor
add middle_name char(1) after first_name;

#3b
ALTER TABLE sakila.actor MODIFY middle_name BLOB;

#Verify the table structure of actor.
desc sakila.actor;

#3c
ALTER TABLE sakila.actor DROP COLUMN middle_name;

#4a
select last_name from actor;
select last_name, count(*) as 'num of actors with last name' 
from actor
group by last_name;

#4b
select last_name from actor;
select last_name, count(*) as 'num of actors with last name' 
from actor
group by last_name
having count(*) >= 2;

#4c
update actor 
set first_name = 'HARPO'
where last_name = 'WILLIAMS'
and first_name = 'GROUCHO';

#Verifying data after the update
select * from sakila.actor
where last_name  LIKE  '%WILLIAMS%'

#Get the unique ID of Harpo Williams to use in update below.
select * from sakila.actor;

#4d
UPDATE  sakila.actor
SET     first_name = CASE WHEN first_name = 'HARPO' THEN 'GROUCHO' ELSE 'MUCHO GROUCHO' END
WHERE   actor_id = 172;

#5a
#CLI command to show the schema of a table
show create table sakila.address;
desc  sakila.address;
#Command to create the table:
#CREATE TABLE `address` (
#  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
#  `address` varchar(50) NOT NULL,
#  `address2` varchar(50) DEFAULT NULL,
#  `district` varchar(20) NOT NULL,
#  `city_id` smallint(5) unsigned NOT NULL,
#  `postal_code` varchar(10) DEFAULT NULL,
#  `phone` varchar(20) NOT NULL,
#  `location` geometry NOT NULL,
#  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
#  PRIMARY KEY (`address_id`),
#  KEY `idx_fk_city_id` (`city_id`),
#  SPATIAL KEY `idx_location` (`location`),
#  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
#) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8

#Random queries to verify data in tables
select count(*) from sakila.staff;
select * from sakila.address;
select * from city;
select * from country;

#6a
select s.first_name, s.last_name,
a.address, a.address2, a.district, c.city, a.postal_code
from sakila.staff s 
join sakila.address a on s.address_id = a.address_id 
join sakila.city c on c.city_id = a.city_id;

#Alternative way of writing the query

select s.first_name, s.last_name,
a.address, a.address2, a.district, c.city, a.postal_code
from sakila.staff s, sakila.address a, sakila.city c 
where s.address_id = a.address_id
and a.city_id = c.city_id;


#6b
select s.staff_id, s.first_name, s.last_name, sum(amount)
from staff s join payment p
on s.staff_id = p.staff_id
WHERE month(payment_date) = 8
AND year(payment_date) = 2005
group by s.staff_id;

#Random queries
select * from film ;
select * from film_actor  where film_id = 2;

#6c
select fi.film_id, fi.title, count(actor_id) as 'number of actors'
from film fi inner join film_actor fa
on fi.film_id = fa.film_id
group by fi.film_id;


#6d
select count(*) 
from sakila.inventory i join sakila.film f 
on i.film_id = f.film_id
where f.title = 'HUNCHBACK IMPOSSIBLE'

#6e
select c.customer_id, c.first_name, c.last_name, sum(p.amount) as 'Total Amount Paid'
from customer c join payment p
on c.customer_id = p.customer_id
group by c.customer_id
order by c.last_name;

#7a
select title from film
where title in 
(select title from film where title like 'K%' or title like 'Q%');

#7b
select a.actor_id, a.first_name, a.last_name
from actor a 
where actor_id in 
(select actor_id from film_actor fa join film f 
 on fa.film_id = f.film_id and f.title = 'ALONE TRIP');
 
#7c
select first_name, last_name, email
from customer inner join address on customer.address_id = address.address_id
inner join city on address.city_id = city.city_id
inner join country on country.country_id = city.country_id
where upper(country.country) = 'CANADA';

# OR
select first_name, last_name, email
from customer, address, city, country
where customer.address_id = address.address_id
and address.city_id = city.city_id
and city.country_id = country.country_id
and lower(country.country) = 'canada';


#7d(assuming G and PG are rated family films)
select rating, title, description from film where rating in ('G', 'PG')
order by rating;

#7e, using rental duration to determine most frequently rented movies.
select title, rental_duration from film order by rental_duration desc;

#7f 
select store.store_id,  sum(amount) 
from store join customer on store.store_id = customer.store_id
join payment on payment.customer_id =  customer.customer_id 
group by store.store_id;

#7g
select store_id, address, address2, district, city, postal_code, country
from sakila.store s join sakila.address a on s.address_id = a.address_id 
join sakila.city c on a.city_id = c.city_id
join sakila.country cntry on c.country_id = cntry.country_id;

#OR(another way to write the above query)

select store_id, address, address2, district, city, postal_code, country
from store s, address a, city c, country cntry
where s.address_id = a.address_id
and c.city_id = a.city_id
and c.country_id = cntry.country_id ;

#7h
select cat.name, sum(amount) as amt
from category cat 
inner join film_category fcat on cat.category_id = fcat.category_id
inner join inventory inv on inv.film_id = fcat.film_id
inner join rental ren on ren.inventory_id = inv.inventory_id
inner join payment pay on pay.rental_id = ren.rental_id
group by cat.name
order by amt desc limit 5;

select * from category;

#Use this query to validate your results from the above query
#verified for category 15(sports) / 2 Animation / 14 Sci Fi
select sum(amount) from payment where rental_id in 
  (select rental_id from rental where inventory_id in 
  (select inventory_id from sakila.inventory where film_id in 
  (select film_id from sakila.film_category where category_id = 15))) ;

#8a
create view executive_v
as 
select cat.name, sum(amount) as amt
from category cat 
inner join film_category fcat on cat.category_id = fcat.category_id
inner join inventory inv on inv.film_id = fcat.film_id
inner join rental ren on ren.inventory_id = inv.inventory_id
inner join payment pay on pay.rental_id = ren.rental_id
group by cat.name
order by amt desc limit 5;

#8b
select * from executive_v;

#8c
drop view executive_v;



