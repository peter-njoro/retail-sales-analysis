-- =====================================================
-- Business Question 2: Product Category Profitability
-- =====================================================
-- Purpose: Identify most and least profitable categories
-- Techniques: GROUP BY, ranking, profit margin analysis
-- =====================================================

-- Category-Level Analysis
WITH category_performance AS (
    SELECT 
        category,
        COUNT(DISTINCT order_id) AS total_orders,
        COUNT(*) AS total_items,
        SUM(sales) AS total_revenue,
        SUM(profit) AS total_profit,
        SUM(quantity) AS total_quantity,
        AVG(discount) AS avg_discount,
        -- Profit metrics
        ROUND((SUM(profit) / NULLIF(SUM(sales), 0)) * 100, 2) AS profit_margin_pct,
        SUM(CASE WHEN profit < 0 THEN 1 ELSE 0 END) AS unprofitable_transactions
    FROM retail_analysis.superstore_sales
    GROUP BY category
)
SELECT 
    category,
    total_orders,
    total_items,
    CONCAT('$', FORMAT(total_revenue, 2)) AS revenue,
    CONCAT('$', FORMAT(total_profit, 2)) AS profit,
    CONCAT(profit_margin_pct, '%') AS profit_margin,
    CONCAT(ROUND(avg_discount * 100, 1), '%') AS avg_discount,
    unprofitable_transactions,
    CONCAT(ROUND((unprofitable_transactions / total_items) * 100, 1), '%') AS unprofitable_pct,
    -- Revenue contribution
    CONCAT(ROUND((total_revenue / SUM(total_revenue) OVER ()) * 100, 1), '%') AS revenue_share,
    -- Profit contribution
    CONCAT(ROUND((total_profit / SUM(total_profit) OVER ()) * 100, 1), '%') AS profit_share
FROM category_performance
ORDER BY total_profit DESC;