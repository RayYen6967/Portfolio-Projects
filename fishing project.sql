---- Data Cleaning ----

--Change the column name to make it more clear 

exec sp_rename 'northatlanticfishing.length', 'vessel_length', 'column'
exec sp_rename 'northatlanticfishing.power', 'vessel_power', 'column'
exec sp_rename 'northatlanticfishing.patch', 'patch_id', 'column'

--Combine month and year to a single date 
 
alter table northatlanticfishing 
add date date 

update northatlanticfishing 
set date = dateadd(yyyy, year-1, '2002')

update northatlanticfishing 
set date = dateadd(mm, convert(int, y_month), date)

alter table northatlanticfishing
drop column month 

alter table northatlanticfishing
drop column y_month

alter table northatlanticfishing
drop column year

--Change 0, 1 to No, Yes in y column
--Change column name to Fishing

alter table northatlanticfishing
add fishing varchar(5)

update northatlanticfishing
set fishing = iif(y = 0, 'No', 'Yes')

alter table northatlanticfishing
drop column y

--Calculate the missing price by value / weight

update northatlanticfishing
set price = value / weight 
where price = 0 and value != 0 

---- Data Exploration ----

--Looking at weight, adjusted price, nao_index, vessels by year 
--Exclude 2019 because it only includes data from Jan.-June

select avg(weight) as avg_weight, avg(value_cpi/weight) as avg_price,
       avg(nao_index) as avg_nao_index, count(ID) as total_vessels, 
	   datepart(yy, date) as year
from NorthAtlanticFishing
where fishing = 'Yes' and datepart(yy, date) != 2019
group by datepart(yy, date)
order by datepart(yy, date)

--Looking at weight, adjusted price, nao_index, vessels by month 
--Exclude 2019 because it only includes data from Jan.-June

select avg(weight) as avg_weight, avg(value_cpi/weight) as avg_price,
       avg(nao_index) as avg_nao_index, count(ID) as total_vessels, 
	   datepart(mm, date) as month
from NorthAtlanticFishing
where fishing = 'Yes' and datepart(yy, date) <> 2019
group by datepart(mm, date)
order by datepart(mm, date)

--Engine_age vs Weight & Price

with engine_group as (select case when engine_age <= 20 then '0-20'
                             when engine_age <= 40 then '21-40'
	                         when engine_age <= 60 then '41-60'
	                         when engine_age <= 80 then '61-80'
	                         when engine_age <= 100 then '81-100'
	                         else '101-120' end as engine_group,
							 weight, value_cpi/weight as price, ID
	                  from NorthAtlanticFishing where fishing = 'Yes')
select engine_group, avg(weight) as avg_weight, 
       avg(price) as avg_price, count(ID) as total_vessels
from engine_group 
group by engine_group
order by convert(int, right(engine_group, len(engine_group)/2))

--Vessel_length vs Weight & Price 

with length_group as (select case when vessel_length <= 20 then '0-20'
                             when vessel_length <= 40 then '21-40'
	                         when vessel_length <= 60 then '41-60'
	                         when vessel_length <= 80 then '61-80'
	                         else '81-100' end as length_group,
							 weight, value_cpi/weight as price, ID
					 from NorthAtlanticFishing where fishing = 'Yes')
select length_group, avg(weight) as avg_weight, 
       avg(price) as avg_price, count(ID) as total_vessels
from length_group
group by length_group
order by convert(int, right(length_group, len(length_group)/2))

--Vessel_power vs Weight & Price 

with power_group as (select case when vessel_power <= 2000 then '0-2k'
                            when vessel_power <= 4000 then '2k-4k'
	                        when vessel_power <= 6000 then '4k-6k'
	                        when vessel_power <= 8000 then '6k-8k'
	                        when vessel_power <= 10000 then '8k-10k'
							else '10k-11k' end as power_group,
							weight, value_cpi/weight as price, ID
					from NorthAtlanticFishing where fishing = 'yes')
select power_group, avg(weight) as avg_weight, 
       avg(price) as avg_price, count(ID) as total_vessels
from power_group 
group by power_group
order by len(power_group), power_group

--Top 5 landing that has the lowest price in the year

with price_rank_year as (select landing, datepart(yy, date) as year, avg(value_cpi/weight) as price,
                                rank() over (partition by datepart(yy, date) order by avg(value_cpi/weight)) as rank
                         from NorthAtlanticFishing 
						 where fishing = 'Yes' and value_cpi != 0
						 group by landing, datepart(yy, date))
select year, landing, price
from price_rank_year
where rank <= 5
order by year, price

--Top 5 landing that has the highest price in the year

with price_rank_year as (select landing, datepart(yy, date) as year, avg(value_cpi/weight) as price,
                                rank() over (partition by datepart(yy, date) order by avg(value_cpi/weight) desc) as rank
                         from NorthAtlanticFishing 
						 where fishing = 'Yes' and value_cpi != 0
						 group by landing, datepart(yy, date))
select year, landing, price
from price_rank_year
where rank <= 5
order by year, price desc


