-- =====================================================
-- Discount Impact by Category
-- =====================================================

WITH category_discount_analysis AS (
    SELECT 
        category,
        CASE 
            WHEN discount = 0 THEN 'No Discount'
            WHEN discount > 0 AND discount <= 0.20 THEN 'Low (1-20%)'
            WHEN discount > 0.20 THEN 'High (20%+)'
        END AS discount_level,
        SUM(sales) AS total_revenue,
        SUM(profit) AS total_profit,
        COUNT(*) AS transaction_count,
        AVG(discount) AS avg_discount
    FROM retail_analysis.superstore_sales
    GROUP BY category, discount_level
)
SELECT 
    category,
    discount_level,
    transaction_count,
    CONCAT('$', FORMAT(total_revenue, 2)) AS revenue,
    CONCAT('$', FORMAT(total_profit, 2)) AS profit,
    CONCAT(ROUND((total_profit / NULLIF(total_revenue, 0)) * 100, 2), '%') AS profit_margin,
    CONCAT(ROUND(avg_discount * 100, 1), '%') AS avg_discount,
    -- Rank within category
    RANK() OVER (PARTITION BY category ORDER BY total_profit DESC) AS profit_rank_in_category
FROM category_discount_analysis
ORDER BY category, discount_level;