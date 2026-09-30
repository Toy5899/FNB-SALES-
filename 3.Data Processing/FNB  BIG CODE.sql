-- Databricks notebook source
CREATE OR REPLACE TEMP VIEW FNBSales AS 

SELECT

    Date,
    Sales,
    `Cost of Sales`,
    `Quantity Sold`,

    Sales / `Quantity Sold` AS Sales_Price_Per_Unit, ---Sales priceper unit

    Sales - `Cost of Sales` AS Gross_Profit,---gross profit

    ((Sales - `Cost of Sales`) / Sales) * 100 ---gross profit as percentage
        AS Gross_Profit_Percentage,

    (Sales - `Cost of Sales`) / `Quantity Sold` ---gross profit per unit
        AS Gross_Profit_Per_Unit,

    CASE
        WHEN DAYOFWEEK(Date) = 2 THEN 'Monday' ---days of week
        WHEN DAYOFWEEK(Date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(Date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(Date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(Date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(Date) = 7 THEN 'Saturday'
        WHEN DAYOFWEEK(Date) = 1 THEN 'Sunday'
    END AS Day_Classification,

    DATE_FORMAT(Date, 'yyyy-MM') AS Sales_Month,---month

    CASE ---promotion period

        -- Promotion 1
        WHEN Date BETWEEN '2013-12-30' AND '2014-01-01'
            THEN 'Promotion 1'

        -- Promotion 2
        WHEN Date BETWEEN '2014-08-28' AND '2014-09-08'
            THEN 'Promotion 2'

        -- Promotion 3
        WHEN Date BETWEEN '2014-02-27' AND '2014-03-10'
            THEN 'Promotion 3'

        ELSE 'Normal Price'

    END AS Promotion_Period,

    CASE ---promotion flag

        WHEN Date BETWEEN '2013-12-30' AND '2014-01-01'
            THEN 'Promotion'

        WHEN Date BETWEEN '2014-08-28' AND '2014-09-08'
            THEN 'Promotion'

        WHEN Date BETWEEN '2014-02-27' AND '2014-03-10'
            THEN 'Promotion'
ELSE 'Normal'
END AS Promotion_Status
FROM fnbsales.sales.fnbsalescasestudy
WHERE `Quantity Sold` > 0;

WITH Normal_Baseline AS (
    SELECT
        AVG(`Quantity Sold`) AS Normal_Qty,
        AVG(Sales_Price_Per_Unit) AS Normal_Price
    FROM FNBSales
    WHERE Promotion_Status = 'Normal'
),

Promotion_Averages AS (
    SELECT
        Promotion_Period,
        AVG(`Quantity Sold`) AS Promo_Qty,
        AVG(Sales_Price_Per_Unit) AS Promo_Price
    FROM FNBSales
    WHERE Promotion_Status = 'Promotion'
    GROUP BY Promotion_Period
)

SELECT
    Promotion_Period, ----- Calculate Price Elasticity of Demand (PED) for each promotion period

    ROUND(Promo_Qty, 2) AS Avg_Promo_Quantity,
    ROUND(Promo_Price, 2) AS Avg_Promo_Price,

    ROUND(Normal_Qty, 2) AS Normal_Avg_Quantity,
    ROUND(Normal_Price, 2) AS Normal_Avg_Price,

    ROUND(
        ((Promo_Qty - Normal_Qty) / Normal_Qty) /
        ((Promo_Price - Normal_Price) / Normal_Price),
        2
    ) AS Price_Elasticity,

    ABS(
        ROUND(
            ((Promo_Qty - Normal_Qty) / Normal_Qty) /
            ((Promo_Price - Normal_Price) / Normal_Price),
            2
        )
    ) AS Absolute_PED

FROM Promotion_Averages
CROSS JOIN Normal_Baseline
ORDER BY Promotion_Period;

---checking my big table
SELECT *
FROM FNBSales
ORDER BY Date;

-- COMMAND ----------

SELECT
    Promotion_Period,
    ROUND(AVG(`Quantity Sold`), 2) AS Avg_Quantity_Sold,
    ROUND(AVG(Sales_Price_Per_Unit), 2) AS Avg_Price_Per_Unit
FROM FNBSales
WHERE Promotion_Status = 'Promotion'
GROUP BY Promotion_Period
ORDER BY Promotion_Period;

SELECT
    ROUND(AVG(`Quantity Sold`), 2) AS Normal_Avg_Quantity,
    ROUND(AVG(Sales_Price_Per_Unit), 2) AS Normal_Avg_Price
FROM FNBSales
WHERE Promotion_Status = 'Normal';



-- COMMAND ----------

WITH Normal_Baseline AS (
    SELECT
        AVG(`Quantity Sold`) AS Normal_Qty,
        AVG(Sales_Price_Per_Unit) AS Normal_Price
    FROM FNBSales
    WHERE Promotion_Status = 'Normal'
),

Promotion_Averages AS (
    SELECT
        Promotion_Period,
        AVG(`Quantity Sold`) AS Promo_Qty,
        AVG(Sales_Price_Per_Unit) AS Promo_Price
    FROM FNBSales
    WHERE Promotion_Status = 'Promotion'
    GROUP BY Promotion_Period
)

SELECT
    Promotion_Period,

    ROUND(Promo_Qty, 2) AS Avg_Promo_Quantity,
    ROUND(Promo_Price, 2) AS Avg_Promo_Price,

    ROUND(Normal_Qty, 2) AS Normal_Avg_Quantity,
    ROUND(Normal_Price, 2) AS Normal_Avg_Price,

    ROUND(
        ((Promo_Qty - Normal_Qty) / Normal_Qty) /
        ((Promo_Price - Normal_Price) / Normal_Price),
        2
    ) AS Price_Elasticity

FROM Promotion_Averages
CROSS JOIN Normal_Baseline
ORDER BY Promotion_Period;