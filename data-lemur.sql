--Data Science Skills [LinkedIn SQL Interview Question]
SELECT candidate_id, count(*) as count_skills
FROM candidates
WHERE skill in ('Python', 'Tableau', 'PostgreSQL')
GROUP BY candidate_id
HAVING count(*) >= 3;





--Page With No Likes [Facebook SQL Interview Question]
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





--Unfinished Parts [Tesla SQL Interview Question]
SELECT part, finish_date 
FROM parts_assembly
where finish_date is null;





--Laptop vs. Mobile Viewership [New York Times SQL Interview Question]
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





--Average Post Hiatus (Part 1) [Facebook SQL Interview Question]
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





--Teams Power Users [Microsoft SQL Interview Question]
SELECT sender_id, count(*) as message_count 
FROM messages
GROUP BY sender_id
ORDER BY count(*) DESC
LIMIT 2;





--Duplicate Job Listings [Linkedin SQL Interview Question]
with dupl_cte as 
(
  SELECT company_id, count(*)
  FROM job_listings
  GROUP BY company_id
  HAVING count(*) >= 2
)

SELECT count(*) as duplicate_companies
FROM dupl_cte;





--Cities With Completed Trades [Robinhood SQL Interview Question]
SELECT city, count(*) 
FROM trades
JOIN users ON trades.user_id = users.user_id
WHERE status='Completed'
GROUP BY city
ORDER BY count(*) DESC
LIMIT 3;






