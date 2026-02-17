-- =====================================================
-- Regional Category Performance
-- =====================================================
-- Identify which categories perform differently by region

SELECT 
    region,
    category,
    COUNT(DISTINCT order_id) AS total_orders,
    CONCAT('$', FORMAT(SUM(sales), 2)) AS revenue,
    CONCAT('$', FORMAT(SUM(profit), 2)) AS profit,
    CONCAT(ROUND((SUM(profit) / NULLIF(SUM(sales), 0)) * 100, 2), '%') AS profit_margin,
    RANK() OVER (PARTITION BY region ORDER BY SUM(profit) DESC) AS profit_rank_in_region
FROM retail_analysis.superstore_sales
GROUP BY region, category
ORDER BY region, profit_rank_in_region;