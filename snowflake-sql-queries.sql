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
