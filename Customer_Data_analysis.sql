select *  from dbo.support_data

--Let's create a view so that only necessary columns can be used for Analysis.
create view customer as
select [channel_name],[category],[Sub-category],[Customer Remarks],[order_date_time]
,[Issue_reported at],[issue_responded],[Response_Time],[Survey_response_Date],[Customer_City],[Product_category]
,[Item_price],[connected_handling_time],[Agent_name],[Supervisor],[Manager],[Tenure Bucket],[Agent Shift]
,[CSAT Score]
from dbo.support_data

select * from customer

--What is the average response time for customer issues?
select round(avg(Response_Time),0) as Average_Response_Time_in_minutes 
from customer

--What is the average handling time for issues?
select round(avg(convert(int,connected_handling_time)),0) as AHT_in_min 
from customer
where connected_handling_time is not null

--How does response time vary by agent shift?
select [Agent Shift],round(avg(Response_Time),0) as Response_Time 
from customer
group by [Agent Shift]

--how many percentage agents have the highest and lowest CSAT scores?
WITH total AS (
    SELECT COUNT(DISTINCT Agent_name) AS total_count
    FROM customer
),
highest_score AS (
    SELECT COUNT(DISTINCT Agent_name) AS high_count
    FROM customer
    WHERE [CSAT Score] = (SELECT MAX([CSAT Score]) FROM customer)
),
lowest_score AS (
    SELECT COUNT(DISTINCT Agent_name) AS low_count
    FROM customer
    WHERE [CSAT Score] = (SELECT MIN([CSAT Score]) FROM customer)
)
SELECT
    (CAST(high_count AS FLOAT) / total_count) * 100 AS highest_score_percentage,
    round((CAST(low_count AS FLOAT) / total_count) * 100,3) AS lowest_score_percentage
FROM total, highest_score, lowest_score;


--How does agent performance vary under different supervisors?
select Supervisor,round(avg([CSAT Score]),2) as Avg_csat_score,COUNT(Agent_name) as No_of_agents 
from customer
group by Supervisor
order by avg_csat_score desc;

--What are the most common issues reported by customers?
select top 10 category,[Sub-category] as issues,COUNT(category) as Frequency 
from customer
group by [sub-category],category
order by Frequency desc

--How does customer satisfaction correlate with different product categories?
select category,round(avg([CSAT Score]),2) 
from customer
group by category

--What is the average order value associated with different customer complaints?
select category,AVG(cast(Item_price as int)) as average_order_value 
from customer
where Item_price is not null
group by category
order by average_order_value desc

--How do issue response times differ by customer city?
SELECT Customer_City,hr,in_min
FROM (	
		SELECT Customer_City,ROUND(CAST(Response_Time AS INT) / 60, 0) AS hr,
        CAST(CAST(Response_Time AS INT) % 60 AS INT) AS in_minu
		FROM customer
		WHERE Customer_City IS NOT NULL) AS Subquery
WHERE hr > 0 OR in_minu > 0
ORDER BY hr DESC, in_minu DESC;


--What trends can be identified in customer remarks over time?
select top 10 [Customer Remarks],count([Customer Remarks]) as frequency 
from customer 
where [Customer Remarks] is not null
group by [Customer Remarks]
order by frequency desc
