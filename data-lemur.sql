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
