--CREATE DATABASES AND IMPORT DATA FROM CSV FILES
create table invoices(
	meal_id varchar(50) primary key not null,
	order_id varchar(50) unique not null,
	company_id varchar(50) not null,
	date_of_meal timestamp not null,
	participants text array,
	meal_price decimal not null,
	type_of_meal varchar(20)	
)

create table orderleads(
	order_id varchar(50) primary key not null,
	company_id varchar(50) not null,
	date_of_order date not null,
	order_value decimal not null,
	converted boolean not null
)

create table salesteam(
	company_id varchar(50) primary key not null,
	company varchar(50) not null,
	salesrep_id varchar(50) not null,
	salesrep varchar(50) not null
)

alter table invoices
add constraint fk_invoices_orderleads foreign key (order_id) references orderleads (order_id)

alter table invoices
add constraint fk_invoices_salesteam foreign key (company_id) references salesteam (company_id)

alter table orderleads
add constraint fk_orderleads_salesteam foreign key (company_id) references salesteam (company_id)

-- ORDERS SUMMARY
-- Main indicators
select count(distinct company_id) as number_of_companies, count(*) as number_of_orders, round(avg(order_value), 2) as average_order_value, round(cast(sum(case when converted='true' then 1 else 0 end) as decimal)/cast(count(order_id) as decimal)*100, 2) as average_conversion_rate from orderleads
--Number of orders and number of sales by date
select date_of_order, count(*) as number_of_orders, sum(case when converted='true' then 1 else 0 end) as number_of_sales from orderleads
group by date_of_order
order by date_of_order
-- Number of orders, average order value and conversion rate by company
select salesteam.company, count(order_id) as number_of_orders, round(avg(order_value), 2) as average_order_value, round(cast(sum(case when converted='true' then 1 else 0 end) as decimal)/cast(count(order_id) as decimal)*100, 2) as conversion_rate
from orderleads
join salesteam on orderleads.company_id = salesteam.company_id
group by salesteam.company

-- MEAL ANALYSIS
-- Extract data on meal (meal_id, date_of_meal, date_of_order, company, number_of_participants, meal_price, type_of_meal, value_per_participant) from database
create view meal_infor as 
select meal_id, date_of_meal, date_of_order, company, cast(array_length(participants, 1) as decimal) as number_of_participants, meal_price, type_of_meal, 
from invoices
join orderleads on invoices.order_id = orderleads.order_id
join salesteam on invoices.company_id = salesteam.company_id
where converted = 'true'

select *, round(meal_price/number_of_participants, 2) as value_per_participant
from meal_infor

