use schema snowflake_sample_data.tpch_sf1;

--Basic Queries

    --1. Count number of orders
    SELECT COUNT(*) FROM orders;
    
    --2. Limit to only 10 orders
    SELECT *
    FROM orders
    LIMIT 10;
    
    --3. Show only distinct order statuses
    SELECT DISTINCT O_ORDERSTATUS
    FROM orders;
    
    --4. Counter number of distinct customers
    SELECT COUNT(DISTINCT O_CUSTKEY)
    FROM orders;
    
    --5. Counter number of distinct clerks
    SELECT COUNT(DISTINCT O_CLERK)
    FROM orders;

    --6. Counter number of distinct years
    SELECT COUNT(DISTINCT YEAR(O_ORDERDATE))
    FROM orders;

    --7. Counter number of distinct dates
    SELECT COUNT(DISTINCT O_ORDERDATE)
    FROM orders;

    --8. Earliest and latest dates
    SELECT MIN(O_ORDERDATE), MAX(O_ORDERDATE)
    FROM orders;

    --9. Highest, lowest, and average total price
    SELECT 
        MIN(O_TOTALPRICE), 
        MAX(O_TOTALPRICE), 
        AVG(O_TOTALPRICE)
    FROM orders;

    --10. Average 10 account balances
    SELECT AVG(S_ACCTBAL)
    FROM supplier
    LIMIT 10;

--Intermediate Queries

    --11. Number of orders per order date ordered by earliest date
    SELECT O_ORDERDATE, COUNT(*)
    FROM orders
    GROUP BY O_ORDERDATE
    ORDER BY O_ORDERDATE;

    --12. Number of orders per year ordered by earliest year
    SELECT YEAR(O_ORDERDATE), COUNT(*)
    FROM orders
    GROUP BY YEAR(O_ORDERDATE)
    ORDER BY YEAR(O_ORDERDATE);

    --13. Number of orders per order priority ordered by most orders
    SELECT O_ORDERPRIORITY, COUNT(*) AS total_orders
    FROM orders
    GROUP BY O_ORDERPRIORITY
    ORDER BY total_orders DESC;

    --14. Number of orders by customer ordered by most orders
    --Show the result as custkey, name, nation key, totalorders
    SELECT O_CUSTKEY, C_NAME, C_NATIONKEY, COUNT(*) AS total_orders
    FROM orders
    JOIN CUSTOMER C ON O_CUSTKEY=C_CUSTKEY
    GROUP BY O_CUSTKEY, C_NAME, C_NATIONKEY
    ORDER BY total_orders DESC;

    --15. Countries with most customers
    --show as nationkey, nation name, total orders
    SELECT C_NATIONKEY, N_NAME, COUNT(*) AS total_orders
    FROM customer
    JOIN nation ON C_NATIONKEY=N_NATIONKEY
    GROUP BY C_NATIONKEY, N_NAME
    ORDER BY total_orders;

    --16. Clerks that have sold the most
    --show as nationkey, nation name, total orders
    SELECT O_CLERK, COUNT(*), SUM(O_TOTALPRICE) AS cum_total
    FROM orders 
    GROUP BY O_CLERK
    ORDER BY cum_total DESC;

    --17. Parts with the greatest profit margin
    SELECT 
        P_PARTKEY, 
        P_RETAILPRICE, 
        PS_SUPPLYCOST, 
        P_RETAILPRICE-PS_SUPPLYCOST AS profit,
        (P_RETAILPRICE-PS_SUPPLYCOST)/P_RETAILPRICE AS profit_margin
    FROM part
    JOIN partsupp ON P_PARTKEY=PS_PARTKEY
    ORDER BY profit_margin DESC;
    
    --18. Nations with the highest number of suppliers
    SELECT S_NATIONKEY, N_NAME, COUNT(*) AS total_parts
    FROM supplier
    JOIN nation ON S_NATIONKEY=N_NATIONKEY
    GROUP BY S_NATIONKEY, N_NAME
    ORDER BY total_parts DESC;

    --19. 2nd most expensive Lineitem that was delivered in person in the year 1997
    SELECT * 
    FROM lineitem
    WHERE L_SHIPINSTRUCT='DELIVER IN PERSON' AND YEAR(L_RECEIPTDATE)=1997
    ORDER BY L_EXTENDEDPRICE DESC
    LIMIT 1 OFFSET 1;

    --20. Specific customer from the United States in the machinery market segment
    --who has the 5th lowest account balance
    SELECT N_NAME, * 
    FROM customer
    JOIN NATION on C_NATIONKEY=N_NATIONKEY
    WHERE C_NATIONKEY=24 AND C_MKTSEGMENT='MACHINERY'
    ORDER BY C_ACCTBAL
    LIMIT 1 OFFSET 4;

--Advanced Queries

    --21. Show details about each country: name, number of orders, total revenue,
    --avg revenue, min revenue, max revenue, std dev revenue
    --order by largest revenue and round all numbers to 2 spots
    SELECT 
        N_NAME AS country_name,
        COUNT(*) AS num_orders,
        SUM(O_TOTALPRICE) AS total_revenue,
        ROUND(AVG(O_TOTALPRICE), 2) AS avg_order,
        MIN(O_TOTALPRICE) AS min_order,
        MAX(O_TOTALPRICE) AS max_order,
        ROUND(STDDEV(O_TOTALPRICE), 2)
    FROM orders
    JOIN customer ON O_CUSTKEY=C_CUSTKEY
    JOIN nation ON C_NATIONKEY=N_NATIONKEY
    GROUP BY N_NAME
    ORDER BY total_revenue DESC;

    --22. Display each region, the number of countries in each one, and total number of customers
    SELECT 
        R_NAME AS country_name, 
        COUNT(DISTINCT C_NATIONKEY) AS num_nations, 
        COUNT(*) AS total_customers
    FROM region
    JOIN nation ON R_REGIONKEY=N_REGIONKEY
    JOIN customer ON C_NATIONKEY=N_NATIONKEY
    GROUP BY R_NAME;

    --23. show the total revenue by year and the change from the prior year
    SELECT 
        YEAR(O_ORDERDATE) AS year, 
        SUM(O_TOTALPRICE) AS annual_revenue,
        SUM(O_TOTALPRICE) - LAG(SUM(O_TOTALPRICE)) OVER (ORDER BY year) AS annual_difference
    FROM orders
    GROUP BY year
    ORDER BY year;

    --24. Find a specific customer who is from China, ordered on a Sunday in November of 1995,
    --with an order between 10K and 20K, and a vowel as the third letter of the order comment
    --show who the customer is, country name, order date, comment, third letter in the comment, and 
    --order amount
    SELECT 
        O_CUSTKEY, 
        N_NAME, 
        O_ORDERDATE, 
        O_COMMENT,
        SUBSTR(O_COMMENT, 3 , 1) AS third_letter_in_comment,
        O_TOTALPRICE
    FROM orders
    JOIN customer ON O_CUSTKEY=C_CUSTKEY
    JOIN nation ON C_NATIONKEY=N_NATIONKEY
    WHERE 
        N_NAME='CHINA' AND 
        YEAR(O_ORDERDATE)=1995 AND
        MONTH(O_ORDERDATE)=11 AND
        DAYNAME(O_ORDERDATE)='Sun' AND
        O_TOTALPRICE BETWEEN 10000 AND 20000 AND
        SUBSTR(O_COMMENT, 3 , 1) IN ('a','e','i','o','u');

    --25. Display the country names such that the United States is always on the top
    --and the others are ordered alphabetically
    SELECT N_NAME FROM nation WHERE N_NAME = 'UNITED STATES'
    UNION ALL
    (SELECT N_NAME FROM nation WHERE N_NAME != 'UNITED STATES' ORDER BY N_NAME);

    --26. Breakdown of each country by year using CTE
    --show country name, year, total revenue, avg price, min order, max order, std dev
    with orders_by_country as (
        SELECT *
        FROM orders
        JOIN customer ON O_CUSTKEY=C_CUSTKEY
        JOIN nation ON C_NATIONKEY=N_NATIONKEY
    )
    SELECT 
        N_NAME as country_name, 
        YEAR(O_ORDERDATE) as year, 
        SUM(O_TOTALPRICE) as total_revenue,
        ROUND(AVG(O_TOTALPRICE), 2) AS avg_order,
        MIN(O_TOTALPRICE) AS min_order,
        MAX(O_TOTALPRICE) AS max_order,
        ROUND(STDDEV(O_TOTALPRICE), 2) as std_dev
    FROM orders_by_country
    GROUP BY country_name, year
    ORDER BY country_name, year;

    --27. Breakdown by supplier
    with supplier_breakdown as (
        SELECT * 
        FROM supplier 
        JOIN partsupp ON s_suppkey=ps_suppkey
    )
    SELECT 
        s_suppkey, 
        AVG(s_acctbal) as account_balance, 
        COUNT(*) as num_parts,
        MIN(ps_availqty) as parts_min_avail,
        MAX(ps_availqty) as parts_max_avail,
        ROUND(AVG(ps_availqty), 2) as parts_avg_avail,
        MIN(ps_supplycost) as parts_min_cost,
        MAX(ps_supplycost) as parts_max_cost,
        ROUND(AVG(ps_supplycost), 2) as parts_avg_cost
    FROM supplier_breakdown
    GROUP BY s_suppkey
    ORDER BY s_suppkey

    --28. Lineitems by day of the week
    with lineitems_by_day_name as (
        SELECT 
            CASE
                WHEN DAYNAME(L_SHIPDATE)='Sun' THEN 0
                WHEN DAYNAME(L_SHIPDATE)='Mon' THEN 1
                WHEN DAYNAME(L_SHIPDATE)='Tue' THEN 2
                WHEN DAYNAME(L_SHIPDATE)='Wed' THEN 3
                WHEN DAYNAME(L_SHIPDATE)='Thu' THEN 4
                WHEN DAYNAME(L_SHIPDATE)='Fri' THEN 5
                WHEN DAYNAME(L_SHIPDATE)='Sat' THEN 6
            END as day_num,
            DAYNAME(L_SHIPDATE) as day_name,
            *
        FROM lineitem
    )
    SELECT 
        day_num, 
        day_name, 
        COUNT(*) as li_num,
        MIN(L_QUANTITY) as li_min_quant,
        MAX(L_QUANTITY) as li_max_quant,
        ROUND(AVG(L_QUANTITY), 2) as li_avg_quant,
        MIN(L_EXTENDEDPRICE) as li_min_extprice,
        MAX(L_EXTENDEDPRICE) as li_max_extprice,
        ROUND(AVG(L_EXTENDEDPRICE), 2) as li_avg_extprice
    FROM lineitems_by_day_name
    GROUP BY day_num, day_name
    ORDER BY day_num;

    --29. Region, number of countries, number of customers
    with region_info as (
        SELECT * 
        FROM region
        JOIN nation ON R_REGIONKEY=N_REGIONKEY
        JOIN customer ON C_NATIONKEY=N_NATIONKEY
        ORDER BY R_REGIONKEY
    )
    SELECT 
        R_NAME,
        COUNT(DISTINCT N_NAME) as num_countries, 
        COUNT(C_NAME) as num_customers 
    FROM region_info
    GROUP BY R_NAME;

    --30. Percent of parts by type, shown as a percent rounded to two decimal places
    with total_part_by_type as (
        SELECT 
            P_TYPE, 
            COUNT(*) as count_parts
        FROM part
        GROUP BY P_TYPE
    )
    SELECT 
        P_TYPE,
        count_parts,
        ROUND(100*count_parts/(SELECT COUNT(*) FROM part), 2) || '%'
    FROM total_part_by_type;
