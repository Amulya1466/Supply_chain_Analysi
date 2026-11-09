Select * from supply_chain1
--Total records
select
count(*) as Total_records
from supply_chain1;

--Duplicates 
select 
count(*)- count(distinct ID)as Unique_ID
from supply_chain1;

--Missing IDs
select 
sum(case when ID is null then 1 else 0 end ) as Missing_ID,
sum(case when warehouse_block is null then 1 else 0 end) as Missing_warehouse,
SUM(CASE WHEN Mode_of_Shipment IS NULL THEN 1 ELSE 0 END) AS Missing_Shipment_Mode,
    SUM(CASE WHEN Customer_rating IS NULL THEN 1 ELSE 0 END) AS Missing_Rating
FROM supply_chain1;

-- out of 10,999 shipments how many deliveries were late and how many are on time

select 
sum(case when reached_on_time ='yes' then 1 else 0 end) as On_time,
sum(case when reached_on_time = 'no' then 1 else 0 end) as late
from supply_chain1;

--deliveries rate

SELECT
    COUNT(*) AS Total_Shipments,

    SUM(CASE
        WHEN Reached_On_Time = 'Yes' THEN 1
        ELSE 0
    END) AS On_Time_Deliveries,

    SUM(CASE
        WHEN Reached_On_Time = 'No' THEN 1
        ELSE 0
    END) AS Late_Deliveries,

    CAST(
        100.0 * SUM(CASE
            WHEN Reached_On_Time = 'Yes' THEN 1
            ELSE 0
        END) / COUNT(*) AS DECIMAL(5,2)
    ) AS On_Time_Percentage,

    CAST(
        100.0 * SUM(CASE
            WHEN Reached_On_Time = 'No' THEN 1
            ELSE 0
        END) / COUNT(*) AS DECIMAL(5,2)
    ) AS Late_Percentage

FROM supply_chain1;

--which warehouse has the highest late delivery percentage

select Warehouse_block,
count(*) as shipment_count,
sum( case when reached_on_time = 'yes' then 1 else 0 end)as on_time,
sum(case when reached_on_time = 'no' then 1 else 0 end) as late_delivery,
cast(
      100.0* sum(case when reached_on_time = 'no' then 1 else 0 end)/count(*) as decimal(5,2)
      ) as late_delivery_percentage
from Supply_chain1
group by Warehouse_block
order by late_delivery_percentage desc;

--Which shipment mode has the highest late deliveries

SELECT
    Mode_of_Shipment,
    COUNT(*) AS Total_Shipments,

    SUM(CASE
        WHEN Reached_On_Time = 'Yes' THEN 1
        ELSE 0
    END) AS On_Time,

    SUM(CASE
        WHEN Reached_On_Time = 'No' THEN 1
        ELSE 0
    END) AS Late,

    CAST(
        100.0 * SUM(CASE
            WHEN Reached_On_Time = 'No' THEN 1
            ELSE 0
        END) / COUNT(*) AS DECIMAL(5,2)
    ) AS Late_Delivery_Percentage

FROM Supply_chain1
GROUP BY Mode_of_Shipment
ORDER BY Late_Delivery_Percentage DESC;

--product importance effect late delivery
 
 SELECT product_importance, 
 count(*) as shipment_count,
 SUM(CASE
        WHEN Reached_On_Time = 'Yes' THEN 1
        ELSE 0
    END) AS On_Time,

    SUM(CASE
        WHEN Reached_On_Time = 'No' THEN 1
        ELSE 0
    END) AS Late,

    CAST(
        100.0 * SUM(CASE
            WHEN Reached_On_Time = 'No' THEN 1
            ELSE 0
        END) / COUNT(*) AS DECIMAL(5,2)
    ) AS Late_Delivery_Percentage
FROM supply_chain1
group by Product_importance
order by Late_Delivery_Percentage desc;

--discount wise performance
SELECT
    CASE
        WHEN Discount_offered BETWEEN 0 AND 10 THEN '0-10'
        WHEN Discount_offered BETWEEN 11 AND 20 THEN '11-20'
        WHEN Discount_offered BETWEEN 21 AND 30 THEN '21-30'
        WHEN Discount_offered BETWEEN 31 AND 40 THEN '31-40'
        ELSE 'Above 40'
    END AS Discount_Range,

    COUNT(*) AS Total_Shipments,

    SUM(CASE
        WHEN Reached_On_Time = 'No' THEN 1
        ELSE 0
    END) AS Late_Shipments,

    CAST(
        100.0 * SUM(CASE
            WHEN Reached_On_Time = 'No' THEN 1
            ELSE 0
        END) / COUNT(*) AS DECIMAL(5,2)
    ) AS Late_Delivery_Percentage

FROM Supply_chain1

GROUP BY
    CASE
        WHEN Discount_offered BETWEEN 0 AND 10 THEN '0-10'
        WHEN Discount_offered BETWEEN 11 AND 20 THEN '11-20'
        WHEN Discount_offered BETWEEN 21 AND 30 THEN '21-30'
        WHEN Discount_offered BETWEEN 31 AND 40 THEN '31-40'
        ELSE 'Above 40'
    END

ORDER BY Discount_Range;

-- warehouse_performance
WITH Warehouse_Performance AS
(
    SELECT
        Warehouse_block,
        COUNT(*) AS Total_Shipments,

        SUM(CASE
            WHEN Reached_On_Time = 'No' THEN 1
            ELSE 0
        END) AS Late_Shipments

    FROM Supply_chain1
    GROUP BY Warehouse_block
)

SELECT
    Warehouse_block,
    Total_Shipments,
    Late_Shipments,

    CAST(
        100.0 * Late_Shipments / Total_Shipments
        AS DECIMAL(5,2)
    ) AS Late_Percentage

FROM Warehouse_Performance
ORDER BY Late_Percentage DESC;

--Ranking by warehouse performance

WITH Warehouse_Performance AS
(
    SELECT
        Warehouse_block,
        COUNT(*) AS Total_Shipments,

        SUM(CASE
            WHEN Reached_On_Time = 'No' THEN 1
            ELSE 0
        END) AS Late_Shipments

    FROM Supply_chain1
    GROUP BY Warehouse_block
),

Warehouse_Rates AS
(
    SELECT
        Warehouse_block,
        Total_Shipments,
        Late_Shipments,

        CAST(
            100.0 * Late_Shipments / Total_Shipments
            AS DECIMAL(5,2)
        ) AS Late_Percentage

    FROM Warehouse_Performance
)

SELECT
    Warehouse_block,
    Total_Shipments,
    Late_Shipments,
    Late_Percentage,

    RANK() OVER (
        ORDER BY Late_Percentage DESC
    ) AS Warehouse_Rank

FROM Warehouse_Rates;

--

WITH Warehouse_Performance AS
(
    SELECT
        Warehouse_block,
        COUNT(*) AS Total_Shipments,

        SUM(CASE
            WHEN Reached_On_Time = 'No' THEN 1
            ELSE 0
        END) AS Late_Shipments

    FROM Supply_chain1
    GROUP BY Warehouse_block
),

Warehouse_Rates AS
(
    SELECT
        Warehouse_block,
        Total_Shipments,
        Late_Shipments,

        CAST(
            100.0 * Late_Shipments / Total_Shipments
            AS DECIMAL(5,2)
        ) AS Late_Percentage

    FROM Warehouse_Performance
)

SELECT
    Warehouse_block,
    Late_Percentage,

    RANK() OVER (
        ORDER BY Late_Percentage DESC
    ) AS Rank_Position,

    DENSE_RANK() OVER (
        ORDER BY Late_Percentage DESC
    ) AS Dense_Rank_Position,

    ROW_NUMBER() OVER (
        ORDER BY Late_Percentage DESC
    ) AS Row_Number_Position

FROM Warehouse_Rates;

--Do customers who experience late deliveries tend to give lower ratings?
SELECT
    Customer_rating,
    COUNT(*) AS Total_Shipments,

    SUM(CASE
        WHEN Reached_On_Time = 'Yes' THEN 1
        ELSE 0
    END) AS On_Time_Shipments,

    SUM(CASE
        WHEN Reached_On_Time = 'No' THEN 1
        ELSE 0
    END) AS Late_Shipments,

    CAST(
        100.0 * SUM(CASE
            WHEN Reached_On_Time = 'No' THEN 1
            ELSE 0
        END) / COUNT(*) AS DECIMAL(5,2)
    ) AS Late_Percentage

FROM Supply_chain1
GROUP BY Customer_rating
ORDER BY Customer_rating;

--Are heavy shipments more likely to experience delivery delays than light shipments?

SELECT
    CASE
        WHEN Weight_in_gms < 2000 THEN 'Light'
        WHEN Weight_in_gms BETWEEN 2000 AND 5000 THEN 'Medium'
        ELSE 'Heavy'
    END AS Weight_Category,

    COUNT(*) AS Total_Shipments,

    SUM(CASE
        WHEN Reached_On_Time = 'Yes' THEN 1
        ELSE 0
    END) AS On_Time_Shipments,

    SUM(CASE
        WHEN Reached_On_Time = 'No' THEN 1
        ELSE 0
    END) AS Late_Shipments,

    CAST(
        100.0 * SUM(CASE
            WHEN Reached_On_Time = 'No' THEN 1
            ELSE 0
        END) / COUNT(*) AS DECIMAL(5,2)
    ) AS Late_Percentage

FROM Supply_chain1
GROUP BY
    CASE
        WHEN Weight_in_gms < 2000 THEN 'Light'
        WHEN Weight_in_gms BETWEEN 2000 AND 5000 THEN 'Medium'
        ELSE 'Heavy'
    END
ORDER BY Late_Percentage DESC;

--Are shipments with more customer-care calls experiencing higher delivery delays?
SELECT
    Customer_care_calls,
    COUNT(*) AS Total_Shipments,

    SUM(CASE
        WHEN Reached_On_Time = 'Yes' THEN 1
        ELSE 0
    END) AS On_Time_Shipments,

    SUM(CASE
        WHEN Reached_On_Time = 'No' THEN 1
        ELSE 0
    END) AS Late_Shipments,

    CAST(
        100.0 * SUM(CASE
            WHEN Reached_On_Time = 'No' THEN 1
            ELSE 0
        END) / COUNT(*) AS DECIMAL(5,2)
    ) AS Late_Percentage

FROM Supply_chain1
GROUP BY Customer_care_calls
ORDER BY Customer_care_calls;

--

WITH Shipment_Analysis AS
(
    SELECT
        Mode_of_Shipment,
        Product_importance,

        CASE
            WHEN Discount_offered BETWEEN 0 AND 10 THEN '0-10'
            WHEN Discount_offered BETWEEN 11 AND 20 THEN '11-20'
            WHEN Discount_offered BETWEEN 21 AND 30 THEN '21-30'
            WHEN Discount_offered BETWEEN 31 AND 40 THEN '31-40'
            ELSE 'Above 40'
        END AS Discount_Range,

        COUNT(*) AS Total_Shipments,

        SUM(CASE
            WHEN Reached_On_Time = 'No' THEN 1
            ELSE 0
        END) AS Late_Shipments

    FROM Supply_chain1

    GROUP BY
        Mode_of_Shipment,
        Product_importance,
        CASE
            WHEN Discount_offered BETWEEN 0 AND 10 THEN '0-10'
            WHEN Discount_offered BETWEEN 11 AND 20 THEN '11-20'
            WHEN Discount_offered BETWEEN 21 AND 30 THEN '21-30'
            WHEN Discount_offered BETWEEN 31 AND 40 THEN '31-40'
            ELSE 'Above 40'
        END
)

SELECT
    Mode_of_Shipment,
    Product_importance,
    Discount_Range,
    Total_Shipments,
    Late_Shipments,

    CAST(
        100.0 * Late_Shipments / Total_Shipments
        AS DECIMAL(5,2)
    ) AS Late_Percentage

FROM Shipment_Analysis

ORDER BY Late_Percentage DESC;



      

