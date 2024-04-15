--1. Histogram of Tweets [Twitter SQL Interview Question]
with tweets_per_user as (
  SELECT count(*) as num_tweets
  FROM tweets
  WHERE EXTRACT(YEAR from tweet_date) = 2022
  GROUP BY user_id
  ORDER BY count(*)
)

select 
  num_tweets as tweet_bucket,
  count(*) as users_num
from tweets_per_user
group by tweet_bucket;





--2. Data Science Skills [LinkedIn SQL Interview Question]
SELECT candidate_id, count(*) as count_skills
FROM candidates
WHERE skill in ('Python', 'Tableau', 'PostgreSQL')
GROUP BY candidate_id
HAVING count(*) >= 3;





--3. Page With No Likes [Facebook SQL Interview Question]
with pages_with_likes as (
  SELECT page_id, count(*)
  FROM page_likes
  GROUP BY page_id
)

select pages.page_id from pages 
left join pages_with_likes 
on pages.page_id=pages_with_likes.page_id
where pages_with_likes.page_id is NULL
ORDER BY pages.page_id;

--another solution
SELECT pages.page_id 
FROM pages
FULL OUTER JOIN page_likes ON page_likes.page_id = pages.page_id
WHERE user_id is NULL
ORDER BY page_id;





--4. Unfinished Parts [Tesla SQL Interview Question]
SELECT part, finish_date 
FROM parts_assembly
where finish_date is null;





--5. Laptop vs. Mobile Viewership [New York Times SQL Interview Question]
select
  (
    select count(*) 
    from viewership
    where device_type in ('laptop')
  ) as laptop_views,
  (
    select count(*) 
    from viewership
    where device_type in ('tablet', 'phone')
  ) as mobile_views

--another solution
SELECT 
  SUM(CASE WHEN device_type = 'laptop' THEN 1 END) as laptop_views,
  SUM(CASE WHEN device_type in ('tablet', 'phone') THEN 1 END) as mobile_views
FROM viewership;




--6. Average Post Hiatus (Part 1) [Facebook SQL Interview Question]
with cte as (
  SELECT user_id, count(*) AS count_posts
  FROM posts
  WHERE EXTRACT(YEAR FROM post_date) = 2021
  GROUP BY user_id
  HAVING count(*) >= 2
)

select 
  posts.user_id, 
  DATE_PART('days', MAX(posts.post_date)-MIN(posts.post_date)) AS days_between
from posts
JOIN cte ON cte.user_id = posts.user_id
group by posts.user_id;





--7. Teams Power Users [Microsoft SQL Interview Question]
SELECT sender_id, count(*) as message_count 
FROM messages
GROUP BY sender_id
ORDER BY count(*) DESC
LIMIT 2;





--8. Duplicate Job Listings [Linkedin SQL Interview Question]
with dupl_cte as 
(
  SELECT company_id, count(*)
  FROM job_listings
  GROUP BY company_id
  HAVING count(*) >= 2
)

SELECT count(*) as duplicate_companies
FROM dupl_cte;

--another solution
SELECT count(*) 
FROM (
  SELECT company_id, title, count(*) 
  FROM job_listings
  GROUP BY company_id, title
  HAVING count(*) >= 2
) as t





--9. Cities With Completed Trades [Robinhood SQL Interview Question]
SELECT city, count(*) 
FROM trades
JOIN users ON trades.user_id = users.user_id
WHERE status='Completed'
GROUP BY city
ORDER BY count(*) DESC
LIMIT 3;





--10. Average Review Ratings [Amazon SQL Interview Question]
SELECT 
  EXTRACT(MONTH FROM submit_date) as mth, 
  product_id as product, 
  ROUND(AVG(stars), 2) as avg_stars
FROM reviews
GROUP BY product_id, mth
ORDER BY mth, product;





--11. App Click-through Rate (CTR) [Facebook SQL Interview Question]
SELECT 
  app_id,
  ROUND(
    100.0 * 
    SUM(CASE WHEN event_type = 'click' THEN 1 END) / 
    SUM(CASE WHEN event_type = 'impression' THEN 1 END), 
  2) as ctr
FROM events
GROUP BY app_id;





--12. Second Day Confirmation [TikTok SQL Interview Question]
SELECT user_id
FROM emails
JOIN texts ON emails.email_id = texts.email_id
WHERE 
  signup_action = 'Confirmed' AND
  signup_date + interval '1' day = action_date
ORDER BY emails.email_id;





--13. Cards Issued Difference [JPMorgan Chase SQL Interview Question]
SELECT 
  card_name, 
  MAX(issued_amount)-MIN(issued_amount) as difference
FROM monthly_cards_issued
GROUP BY card_name
ORDER BY difference DESC;





--14. Compressed Mean [Alibaba SQL Interview Question]
with total_orders_table as (
  SELECT SUM(order_occurrences) as total_orders
  FROM items_per_order
),
total_items_table as (
  select SUM(order_occurrences * item_count) as total_items 
  from items_per_order
)

select ROUND(CAST ((total_items/total_orders) as numeric), 1) as mean 
from total_orders_table, total_items_table;





--15. Pharmacy Analytics (Part 1) [CVS Health SQL Interview Question]
SELECT 
  drug,
  total_sales - cogs as total_profit
FROM pharmacy_sales
ORDER BY total_profit DESC
LIMIT 3;





--16. Pharmacy Analytics (Part 2) [CVS Health SQL Interview Question]
SELECT 
  manufacturer,
  count(*) as drug_count,
  -SUM(total_sales-cogs) as total_loss
FROM pharmacy_sales
WHERE total_sales-cogs < 0
GROUP BY manufacturer
ORDER BY total_loss DESC;





--17. Pharmacy Analytics (Part 3) [CVS Health SQL Interview Question]
SELECT 
  manufacturer, 
  '$' || ROUND(SUM(total_sales)/1000000, 0) || ' million' as sale
FROM pharmacy_sales
GROUP BY manufacturer
ORDER BY ROUND(SUM(total_sales)/1000000, 0) DESC, manufacturer;





--18. User's Third Transaction [Uber SQL Interview Question]
select user_id, spend, transaction_date FROM (
  select 
    *,
    RANK() OVER(PARTITION BY user_id ORDER BY transaction_date) Rank
  from transactions
  order by user_id, transaction_date
) t
WHERE t.rank = 3;
/*with users_with_3_or_more_trans as (
  SELECT user_id
  FROM transactions 
  GROUP BY user_id
  HAVING count(*) >= 3
  ORDER BY user_id
),
table_with_row_num as (
  SELECT
    *,
    ROW_NUMBER() OVER(ORDER BY user_id, transaction_date) AS row_number 
  FROM transactions
  WHERE 
    user_id in (SELECT * FROM users_with_3_or_more_trans)
  ORDER BY user_id, transaction_date
)

select user_id, spend, transaction_date 
from table_with_row_num
where row_number%3 = 0;*/





--19. Sending vs. Opening Snaps [Snapchat SQL Interview Question]
SELECT 
  age_bucket, 
  ROUND(100*time_sending/(time_sending+time_opening), 2) as send_perc,
  ROUND(100*time_opening/(time_sending+time_opening), 2) as open_perc
FROM (
  SELECT 
    age_bucket, 
    SUM(CASE WHEN activity_type = 'open' THEN time_spent END) as time_opening,
    SUM(CASE WHEN activity_type = 'send' THEN time_spent END) as time_sending
  FROM activities
  JOIN age_breakdown ON activities.user_id = age_breakdown.user_id
  WHERE activity_type in ('open', 'send')
  GROUP BY age_bucket
  ORDER BY age_bucket
) t;





--20. Tweets' Rolling Averages [Twitter SQL Interview Question]
SELECT 
  user_id,
  tweet_date,
  ROUND((tweet_count + prior_day + day_before)/3.0, 2)
FROM (
  SELECT 
    *,
    Lag(tweet_count, 1, 0) OVER(PARTITION BY user_id ORDER BY user_id, tweet_date) AS prior_day,
    Lag(tweet_count, 2, 0) OVER(PARTITION BY user_id ORDER BY user_id, tweet_date) AS day_before
  FROM tweets
  ORDER BY user_id, tweet_date
) t;





--21. Highest-Grossing Items [Amazon SQL Interview Question]
select 
  category,
  product,
  total_spend
from (
  select 
    category, 
    product, 
    SUM(spend) as total_spend,
    RANK() OVER(PARTITION BY category ORDER BY SUM(spend) DESC) as rank
  from product_spend
  WHERE 
    EXTRACT(YEAR FROM transaction_date) = 2022
  GROUP BY category, product
  ORDER BY category
) t
where t.rank in (1, 2);





--22. Top 5 Artists [Spotify SQL Interview Question]
with highest_num_songs as (
  SELECT 
    artist_name,
    count(*) as num_songs
  FROM artists 
  JOIN songs ON artists.artist_id = songs.artist_id
  JOIN global_song_rank ON global_song_rank.song_id = songs.song_id
  WHERE rank <= 10
  GROUP BY artist_name
  ORDER BY count(*) DESC
),
distinct_num_songs as (
  select DISTINCT(num_songs) 
  from highest_num_songs
  ORDER BY num_songs DESC
  LIMIT 5
)

select 
  artist_name,
  DENSE_RANK() OVER(ORDER BY num_songs DESC) as artist_rank
from highest_num_songs
where num_songs in (select * from distinct_num_songs)





--23. Signup Activation Rate [TikTok SQL Interview Question]
with signup_table as (
  SELECT 
    signup_action,
    count(*)
  FROM emails
  JOIN texts ON texts.email_id = emails.email_id
  GROUP BY signup_action
),
final_totals as (
  select 
    (select count from signup_table where signup_action = 'Confirmed') as confirmed_total,
    (select count from signup_table where signup_action = 'Not Confirmed') as not_confirmed_total
)

select 
  ROUND(
          confirmed_total/
          ((confirmed_total+not_confirmed_total)*1.0), 
  2) as confirm_rate
from final_totals;





--24. Supercloud Customer [Microsoft SQL Interview Question]
with distinct_categories as (
  SELECT DISTINCT(product_category) FROM products
),
customers_and_category_grouped as (
  select 
    customer_id,
    product_category
  from customer_contracts
  join products on 
    customer_contracts.product_id = products.product_id
  group by customer_id, product_category
  order by customer_id
)

select customer_id
from customers_and_category_grouped
group by customer_id
having count(*) >= (select count(*) from distinct_categories);





--25. Odd and Even Measurements [Google SQL Interview Question]
with last_digit_table as (
  select 
    measurement_time,
    cast(measurement_value as float),
    RIGHT(cast(cast(measurement_value as float) as varchar), 1) as last_num
  from measurements
)
SELECT 
  date(measurement_time),
  ROUND(
    CAST(
          SUM(CASE WHEN CAST(last_num as INT)%2 = 1 THEN measurement_value END) 
    as numeric), 
  2) as odd_sum,
  ROUND(
    CAST(
          SUM(CASE WHEN CAST(last_num as INT)%2 = 0 THEN measurement_value END) 
    as numeric),
  2) as even_sum
FROM last_digit_table
GROUP BY date(measurement_time)
ORDER BY date(measurement_time);




--26. Histogram of Users and Purchases [Walmart SQL Interview Question]
with user_final_date as (
  select user_id, MAX(transaction_date) as final_date 
  from user_transactions
  group by user_id
)

select 
  user_transactions.transaction_date, 
  user_final_date.user_id, 
  count(*) 
from user_transactions
join user_final_date on 
  user_final_date.user_id = user_transactions.user_id and 
  user_final_date.final_date = user_transactions.transaction_date
group by user_final_date.user_id, user_transactions.transaction_date;





--27. Compressed Mode [Alibaba SQL Interview Question]
with cte as (
SELECT order_occurrences, count(*) 
FROM items_per_order
group by order_occurrences
order by order_occurrences DESC
LIMIT 1)

select item_count as mode from items_per_order
join cte on items_per_order.order_occurrences = cte.order_occurrences
order by item_count ASC;





--28. Card Launch Success [JPMorgan Chase SQL Interview Question]
with cte as (
select 
  *, 
  RANK() OVER(PARTITION BY card_name ORDER BY issue_year ASC, issue_month ASC) Rank
from monthly_cards_issued
order by card_name, rank
)

select card_name, issued_amount from cte where rank = 1;




--29. International Call Percentage [Verizon SQL Interview Question]
with country_codes as (
  select caller_id, country_id from phone_info
), 
part1_cte as (
  select phone_calls.caller_id, country_id, receiver_id
  from phone_calls
  join country_codes on phone_calls.caller_id = country_codes.caller_id
),
part2_cte as (
  select 
    part1_cte.caller_id, 
    part1_cte.country_id as caller_country,
    part1_cte.receiver_id,
    country_codes.country_id as receiver_country
  from part1_cte
  join country_codes on part1_cte.receiver_id = country_codes.caller_id
),
part3_cte as (
  select 
    *,
    CASE 
      WHEN caller_country != receiver_country THEN 'international'
      WHEN caller_country = receiver_country THEN 'domestic'
    END as type_call
  from part2_cte
),
part4_cte as (
  select 
    SUM(CASE WHEN type_call = 'domestic' THEN 1 END) as dom_calls,
    SUM(CASE WHEN type_call = 'international' THEN 1 END) as int_calls,
    COUNT(*) as total_calls
  from part3_cte
)

select 
  round(
    CAST (
      100*CAST(int_calls as float)/cast(total_calls as float)
    as numeric), 
  1)
from part4_cte;





