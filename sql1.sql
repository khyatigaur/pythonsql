select * from df_orders;

-- find top 10 highest reveue generating products 
select product_id ,round(sum(quantity*sale_price),2) as revenue 
from df_orders
group by product_id
order by revenue desc
limit 10;

-- find top 5 highest selling products in each region
with cte as (
select region,product_id,round(sum(quantity*sale_price),2) as sales
from df_orders
group by region,product_id)
select * from (
select *
, row_number() over(partition by region order by sales desc) as rn
from cte) A
where rn<=5;

-- find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023

with cte as(
select EXTRACT(YEAR FROM order_date) as y,EXTRACT(MONTH FROM order_date) as m,round(sum(quantity*sale_price),2) as sales from 
df_orders
group by y,m
order by y)
select m
, sum(case when y=2022 then sales else 0 end) as sales_2022
, sum(case when y=2023 then sales else 0 end) as sales_2023
from cte 
group by m
order by m; 




-- for each category which month had highest sales
with cte as(
select category,DATE_FORMAT(order_date, "%M %Y") as ym ,round(sum(quantity*sale_price),2) as sales 
from df_orders
group by category,ym
order by sales desc
)
select * from
(select *,row_number() over (partition by category order by sales desc) as rn
from cte ) A
where rn=1
; 


-- which sub category had highest growth by profit in 2023 compare to 2022

with cte1 as
(with cte as
(select sub_category ,extract(year from order_date) as order_year,round(sum(sale_price),2) as sales 
from df_orders
group by sub_category,order_year
order by sales desc
)
select  sub_category,
sum(case when order_year=2022 then sales else 0 end ) as sales_2022,
sum(case when order_year=2023 then sales else 0 end ) as sales_2023
from cte
group by sub_category
)
select * , round((sales_2023-sales_2022),2) as diff from cte1 
order by diff desc
limit 1;

