create database joey_pizza;

create table orders(
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id));

create table orders_details(
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id));

/*Retrieve the total number of orders placed.*/
select count(*) from orders;

/*Calculate the total revenue generated from pizza sales.*/

SELECT 
    ROUND(SUM(price * quantity), 2) AS total_sales
FROM
    pizzas a
        JOIN
    orders_details b ON a.pizza_id = b.pizza_id;

-- Identify the highest-priced pizza.
SELECT 
    b.name,a.price
FROM
    pizzas a join pizza_types b on a.pizza_type_id=b.pizza_type_id
WHERE
    a.price = (SELECT 
            MAX(price)
        FROM
            pizzas);

-- or 
	select b.name as  pizza_name ,a.price as pizza_price
	from pizzas a join pizza_types b on a.pizza_type_id=b.pizza_type_id
	order by 2 desc
	limit 1;
-- Identify the most common pizza size ordered.
select size,count(b.quantity)
from pizzas a join orders_details  b on a.pizza_id=b.pizza_id
group by size
order by 2 desc
limit 1;

-- List the top 5 most ordered pizza types along with their quantities.
select b.name,sum(c.quantity) as tt
from pizzas  a
join pizza_types b on a.pizza_type_id=b.pizza_type_id
join orders_details c  on a.pizza_id=c.pizza_id 
group by b.name
order by tt desc
limit 5;

-- Intermediate:
-- Join the necessary tables to find the total quantity of each pizza category ordered. 

SELECT category,SUM(quantity)
FROM pizza_types PT 
JOIN pizzas P ON PT.pizza_type_id=P.pizza_type_id
JOIN orders_details OD ON P.pizza_id=OD.pizza_id
group by category;


-- Group the orders by date and calculate the average number of pizzas ordered per day.

	SELECT ORDERS.ORDER_DATE,AVG(orders_details.quantity) AS QUANTITY
	FROM orders JOIN orders_details 
	ON orders.order_id=orders_details.order_id
	group by orders.order_date
	ORDER BY QUANTITY DESC;
    
-- Determine the distribution of orders by hour of the day.	    
	SELECT HOUR(ORDER_TIME) AS ORDER_PER_HOUR,COUNT(ORDERS.ORDER_ID) AS QTY
	FROM ORDERS 
	GROUP BY ORDER_PER_HOUR
	ORDER BY QTY DESC;
    
 -- Group the orders by date and calculate the average number of pizzas ordered per day.
		SELECT AVG(A.QTY_ORDERED) FROM  (SELECT ORDER_DATE,SUM(ORDERS_DETAILS.QUANTITY) AS QTY_ORDERED
		FROM ORDERS JOIN ORDERS_DETAILS ON ORDERS.ORDER_ID=ORDERS_DETAILS.ORDER_ID
		GROUP BY ORDERS.ORDER_DATE
		ORDER BY QTY_ORDERED DESC) AS A;
        
 -- Determine the top 3 most ordered pizza types based on revenue.    
 
 SELECT a.pizza_type_ID,a.name,sum(b.price*c.quantity) as rev
 FROM pizza_types a join pizzas b  on a.pizza_type_id=b.pizza_type_id
 join orders_details c on b.pizza_id=c.pizza_id
 group by a.Pizza_type_ID,a.name
 order by rev desc
 limit 3;
 
 
 
-- Advanced:
-- Calculate the percentage contribution of each pizza type to total revenue.
with a as
	(select sum(pizzas.price*orders_details.quantity) as rev
	from pizzas join orders_details on pizzas.pizza_id=orders_details.pizza_id),	
   b as	(select a.category,round(sum(price*quantity),2) as rev_per_pizza
	from pizza_types a join pizzas b on a.pizza_type_id=b.pizza_type_id
	join orders_details c on b.pizza_id=c.pizza_id
	group by a.category)
    
   select b.category,((b.rev_per_pizza)/a.rev)*100 as rev_per_category
   from a,b;

-- Analyze the cumulative revenue generated over time.
    select temp.od,round(sum(temp.rev) over(order by temp.od),2) as cum_rev from(
	select (order_date) as od ,sum(quantity*price) as rev
	from orders a join orders_details b on a.order_id=b.order_id
	join pizzas c on b.pizza_id=c.pizza_id
	group by od) as temp;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select * from (select a.name,sum(b.price*c.quantity) as rev,a.category,rank()over(partition by category order by sum(b.price*c.quantity) desc) as ran
from pizza_types a join pizzas b on a.pizza_type_id=b.pizza_type_id
join orders_details c on b.pizza_id=c.pizza_id
group by name,category) as ot
where ran<=3;