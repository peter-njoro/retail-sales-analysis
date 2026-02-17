-- =====================================================
-- Optimal Discount Range by Category
-- =====================================================
-- Find the discount range that maximizes profit for each category

WITH discount_ranges AS (
    SELECT 
        category,
        CASE 
            WHEN discount = 0 THEN '0%'
            WHEN discount > 0 AND discount <= 0.05 THEN '1-5%'
            WHEN discount > 0.05 AND discount <= 0.10 THEN '6-10%'
            WHEN discount > 0.10 AND discount <= 0.15 THEN '11-15%'
            WHEN discount > 0.15 AND discount <= 0.20 THEN '16-20%'
            WHEN discount > 0.20 AND discount <= 0.30 THEN '21-30%'
            ELSE '30%+'
        END AS discount_range,
        SUM(sales) AS revenue,
        SUM(profit) AS profit,
        COUNT(*) AS transactions
    FROM retail_analysis.superstore_sales
    GROUP BY category, discount_range
)
SELECT 
    category,
    discount_range,
    transactions,
    CONCAT('$', FORMAT(revenue, 2)) AS revenue,
    CONCAT('$', FORMAT(profit, 2)) AS profit,
    CONCAT(ROUND((profit / NULLIF(revenue, 0)) * 100, 2), '%') AS profit_margin,
    RANK() OVER (PARTITION BY category ORDER BY profit DESC) AS profit_rank
FROM discount_ranges
ORDER BY category, profit_rank;