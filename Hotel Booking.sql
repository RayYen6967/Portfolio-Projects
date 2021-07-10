---- Data Exploration ----

-- Categorical Data --

select hotel, count(*), avg(is_canceled)
from dbo.hotel_booking
group by hotel

select meal, count(*), avg(is_canceled)
from dbo.hotel_booking
group by meal
-- Convert 'Undefined' to 'SC' because both of them are consider as 'No meal package'

select country, count(*), avg(is_canceled)
from dbo.hotel_booking
group by country
order by count(*) desc
-- Get top 5 countries that had the highest cancellation rate and booked at least 100 times each year
-- Exclude Null values

select market_segment, count(*), avg(is_canceled)
from dbo.hotel_booking
group by market_segment 
-- Convert 'Undefined' to 'Excluded' and exclude them later in visualization

select distribution_channel, count(*), avg(is_canceled)
from dbo.hotel_booking
group by distribution_channel
-- Convert 'Undefined' to 'Excluded' and exclude them later in visualization

select is_repeated_guest, count(*), avg(is_canceled)
from dbo.hotel_booking
group by is_repeated_guest
-- Convert 0, 1 to 'Not Repeated' and 'Repeated'

select reserved_room_type, count(*), avg(is_canceled)
from dbo.hotel_booking
group by reserved_room_type

select assigned_room_type, count(*), avg(is_canceled)
from dbo.hotel_booking
group by assigned_room_type

select deposit_type, count(*), avg(is_canceled)
from dbo.hotel_booking
group by deposit_type

select agent, count(*), avg(is_canceled)
from dbo.hotel_booking 
group by agent 
order by count(*) desc 
-- Get top 5 agents that had the highest cancellation rate and booked at least 100 times each year
-- Exclude Null values 

select company, count(*), avg(is_canceled)
from dbo.hotel_booking 
group by company 
order by count(*) desc
-- Get top 5 companies that had the highest cancellation rate and booked at least 10 times each year
-- Exclude Null values 

select customer_type, count(*), avg(is_canceled)
from dbo.hotel_booking 
group by customer_type

select arrival_date_year, count(*), avg(is_canceled)
from dbo.hotel_booking 
group by arrival_date_year

select arrival_date_month, count(*), avg(is_canceled)
from dbo.hotel_booking 
group by arrival_date_month

select required_car_parking_spaces, count(*), avg(is_canceled)
from dbo.hotel_booking 
group by required_car_parking_spaces
-- Divide into 2 groups because the cancellation rates are all 0 for those reqiured parking spaces 
-- 0 --> 'Not required', 1-8 --> 'Required'
-- Consider as categorical data

-- Numerical Data --

select distinct percentile_disc(0) within group (order by lead_time) over (),
       percentile_disc(0.25) within group (order by lead_time) over (),
       percentile_disc(0.5) within group (order by lead_time) over (),
	   percentile_disc(0.75) within group (order by lead_time) over (),
	   percentile_disc(1) within group (order by lead_time) over ()
from dbo.hotel_booking
-- Divide into 11 groups with size of bins = 20 
-- Lead_time > 200 as one group 
 
select distinct percentile_disc(0) within group (order by stays_in_weekend_nights) over (),
       percentile_disc(0.25) within group (order by stays_in_weekend_nights) over (),
       percentile_disc(0.5) within group (order by stays_in_weekend_nights) over (),
	   percentile_disc(0.75) within group (order by stays_in_weekend_nights) over (),
	   percentile_disc(1) within group (order by stays_in_weekend_nights) over ()
from dbo.hotel_booking
-- Divide into 4 groups with stays_in_weekend_nights > 2 as one group 

select distinct percentile_disc(0) within group (order by stays_in_week_nights) over (),
       percentile_disc(0.25) within group (order by stays_in_week_nights) over (),
       percentile_disc(0.5) within group (order by stays_in_week_nights) over (),
	   percentile_disc(0.75) within group (order by stays_in_week_nights) over (),
	   percentile_disc(1) within group (order by stays_in_week_nights) over ()
from dbo.hotel_booking
-- Divide into 5 groups with stays_in_week_nights > 3 as one group 

select adults, count(*), avg(is_canceled)
from dbo.hotel_booking
group by adults 
-- Divide into 6 groups with adults > 4 as one group 

select children, count(*), avg(is_canceled)
from dbo.hotel_booking
group by children
-- Convert 4 Null values to 0
-- Divide into 4 groups with children > 2 as one group 

select babies, count(*), avg(is_canceled)
from dbo.hotel_booking
group by babies
-- Divide into 3 groups with babies > 1 as one group

select previous_cancellations, count(*), avg(is_canceled)
from dbo.hotel_booking
group by previous_cancellations
-- Divide into 4 groups because of obvious difference of cancellation rate 
-- 0, 1, 2-12, 12+ 

select previous_bookings_not_canceled, count(*), avg(is_canceled)
from dbo.hotel_booking
group by previous_bookings_not_canceled
-- Divide into 19 groups with previous_bookings_not_canceled >= 18 as one group 

select booking_changes, count(*), avg(is_canceled)
from dbo.hotel_booking
group by booking_changes
-- Divide into 10 groups with booking_changes >= 9 as one group 

select days_in_waiting_list, count(*), avg(is_canceled)
from dbo.hotel_booking
group by days_in_waiting_list
order by days_in_waiting_list
-- Divide into 5 gruops 
-- '0', 'Within a week', 'Within a month', 'Within half year' , 'Over half year'

select distinct percentile_disc(0) within group (order by adr) over (),
       percentile_disc(0.25) within group (order by adr) over (),
       percentile_disc(0.5) within group (order by adr) over (),
	   percentile_disc(0.75) within group (order by adr) over (),
	   percentile_disc(1) within group (order by adr) over ()
from dbo.hotel_booking
-- Exclude outliers : -6.38 --> 0, 5400 --> 200
-- Divide into 6 groups with size of bins = 30 and adr > 150 as one group

select total_of_special_requests, count(*), avg(is_canceled)
from dbo.hotel_booking 
group by total_of_special_requests


---- Feature Engineering ----

-- Arrival_date_weekday -- 
select arrival_date_day_of_month, arrival_date_month, arrival_date_year
from hotel_booking 
-- Utilize the combination of year, month and day of month
-- Create this new column that shows the day of the week

-- Total_staying_nights --
select stays_in_week_nights + stays_in_weekend_nights as total_staying_nights, count(*), avg(is_canceled)
from hotel_booking
group by stays_in_week_nights + stays_in_weekend_nights
order by stays_in_week_nights + stays_in_weekend_nights
-- Divide into 32 groups with total_staying_nights > 30 as one group 
-- Convert 0 to 'Unknown' because total_staying_nights = 0 is unreasonable

-- Total_number_of_people --
select adults + isnull(children, 0) + babies as total_number_of_people, count(*), avg(is_canceled)
from hotel_booking 
group by adults + isnull(children, 0) + babies
order by adults + isnull(children, 0) + babies
-- Divide into 7 groups with total_number_of_people > 5 as one group 
-- Convert 0 to 'Unknown' because total_number_of_people = 0 is unreasonable


---- Data Cleaning ----

-- Categorical Data with many categories --
with temp1 as (select meal, market_segment, distribution_channel, deposit_type, customer_type, is_canceled,
                      reserved_room_type, assigned_room_type, arrival_date_year, arrival_date_month,
                      convert(varchar, arrival_date_year) as year_con, convert(varchar, arrival_date_day_of_month) as day_con,
                      case arrival_date_month when 'January' then '01'
			                                  when 'Fabuary' then '02' 
			                                  when 'March' then '03'
			                                  when 'April' then '04'
			                                  when 'May' then '05'
			                                  when 'June' then '06'
			                                  when 'July' then '07'
			                                  when 'August' then '08'
			                                  when 'September' then '09'
			                                  when 'October' then '10'
			                                  when 'November' then '11'
			                                   else '12' end as month_con from hotel_booking),
temp2 as (select meal, market_segment, distribution_channel, deposit_type, customer_type, is_canceled,
                      reserved_room_type, assigned_room_type, arrival_date_year, arrival_date_month,
                 datename(weekday, convert(date, (year_con + '-'+month_con + '-' + day_con))) as arrival_date_weekday
          from temp1)
select iif(meal = 'Undefined', 'SC', meal) as meal, iif(market_segment = 'Undefined', 'Excluded', market_segment) as market_segment,
       iif(distribution_channel = 'Undefined', 'Excluded', distribution_channel) as distribution_channel, deposit_type, customer_type,
	   reserved_room_type, assigned_room_type, arrival_date_year, arrival_date_month, arrival_date_weekday, is_canceled
from temp2;

-- Categorical Data with 2 categories --

select is_canceled, hotel, iif(is_repeated_guest = 0, 'Not Repeated', 'Repeated') as is_repeated_guest, 
       iif(required_car_parking_spaces = 0, 'Not Required', 'Required') as required_car_parking_spaces
from hotel_booking;

-- Numerical Data -- 

select case when stays_in_week_nights + stays_in_weekend_nights > 30 then '30+'
            when stays_in_week_nights + stays_in_weekend_nights = 0 then 'Unknown'
	         else convert(varchar, stays_in_week_nights + stays_in_weekend_nights) end as total_staying_nights,
	   case when adults + isnull(children, 0) + babies > 5 then '5+'
	        when adults + isnull(children, 0) + babies = 0 then 'Unknown'
	         else convert(varchar, adults + isnull(children, 0) + babies) end as total_number_of_people,
       case when lead_time <= 20 then '0-20' 
	        when lead_time <= 40 then '20-40'
		    when lead_time <= 60 then '40-60'
		    when lead_time <= 80 then '60-80'
		    when lead_time <= 100 then '80-100'
		    when lead_time <= 120 then '100-120'
		    when lead_time <= 140 then '120-140'
		    when lead_time <= 160 then '140-160'
		    when lead_time <= 180 then '160-180'
		    when lead_time <= 200 then '180-200'
		     else '200+' end as lead_time, 
       iif(stays_in_weekend_nights > 2, '2+', convert(varchar, stays_in_weekend_nights)) as stays_in_weekend_nights,
	   iif(stays_in_week_nights > 3, '3+', convert(varchar, stays_in_week_nights)) as stays_in_week_nights,
	   iif(adults > 4, '4+', convert(varchar, adults)) as adults,
	   iif(children > 2, '2+', convert(varchar, isnull(children, 0))) as children,
	   iif(babies > 1, '1+', convert(varchar, babies)) as babies,
	   case when previous_cancellations >= 2 and previous_cancellations <= 12 then '2-12'
	        when previous_cancellations > 12 then '12+'
			 else convert(varchar, previous_cancellations) end as previous_cancellations,
       iif(previous_bookings_not_canceled >= 18, '18+', convert(varchar, previous_bookings_not_canceled)) as previous_bookings_not_canceled,
	   iif(booking_changes >= 9, '9+', convert(varchar, booking_changes)) as booking_changes,
	   case when days_in_waiting_list = 0 then '0'
	        when days_in_waiting_list <= 7 then 'Within a week'
			when days_in_waiting_list <= 30 then 'within a month'
			when days_in_waiting_list <= 180 then 'Within half year'
			 else 'Over half year' end as days_in_waiting_list,
       case when adr <= 30 then '0-30'
	        when adr <= 60 then '30-60'
			when adr <= 90 then '60-90'
			when adr <= 120 then '90-120'
			when adr <= 150 then '120-150'
			 else '150+' end as average_daily_rate,
	   case when stays_in_week_nights + stays_in_weekend_nights = 0 then 'Unknown'
	        when stays_in_week_nights + stays_in_weekend_nights > 30 then '30+'
			 else convert(varchar, stays_in_week_nights + stays_in_weekend_nights) end as total_staying_nights,
	   case when adults + isnull(children, 0) + babies = 0 then 'Unknown'
	        when adults + isnull(children, 0) + babies > 5 then '5+'
			 else convert(varchar, adults + isnull(children, 0) + babies) end as total_number_of_people,
	   total_of_special_requests, is_canceled
from hotel_booking;

-- Top 5 highest cancellation rate each year --

with temp as (select country, arrival_date_year, avg(is_canceled) as cancellation_rate, count(*) as booking_times,
                      row_number() over (partition by arrival_date_year order by avg(is_canceled) desc, count(*) desc) as therank
               from hotel_booking
			   where country is not null 
			   group by country, arrival_date_year
			   having count(*) >= 100)
select country, arrival_date_year as year, cancellation_rate, booking_times 
from temp
where therank <= 5 
order by arrival_date_year, cancellation_rate desc;
-- Country

with temp as (select agent, arrival_date_year, avg(is_canceled) as cancellation_rate, count(*) as booking_times,
                      row_number() over (partition by arrival_date_year order by avg(is_canceled) desc, count(*) desc) as therank
               from hotel_booking
			   where agent is not null 
			   group by agent, arrival_date_year
			   having count(*) >= 100)
select agent, arrival_date_year as year, cancellation_rate, booking_times 
from temp
where therank <= 5 
order by arrival_date_year, cancellation_rate desc;
-- Agent 

with temp as (select company, arrival_date_year, avg(is_canceled) as cancellation_rate, count(*) as booking_times,
                      row_number() over (partition by arrival_date_year order by avg(is_canceled) desc, count(*) desc) as therank
               from hotel_booking
			   where company is not null 
			   group by company, arrival_date_year
			   having count(*) >= 10)
select company, arrival_date_year as year, cancellation_rate, booking_times 
from temp
where therank <= 5 
order by arrival_date_year, cancellation_rate desc;
-- Company
