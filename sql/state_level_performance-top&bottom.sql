-- =====================================================
-- State-Level Performance (Top & Bottom States)
-- =====================================================

WITH state_performance AS (
    SELECT 
        state,
        region,
        COUNT(DISTINCT order_id) AS total_orders,
        SUM(sales) AS total_revenue,
        SUM(profit) AS total_profit,
        ROUND((SUM(profit) / NULLIF(SUM(sales), 0)) * 100, 2) AS profit_margin_pct,
        AVG(discount) AS avg_discount
    FROM retail_analysis.superstore_sales
    GROUP BY state, region
)
(
    SELECT 
        'Top 10' AS tier,
        state,
        region,
        CONCAT('$', FORMAT(total_revenue, 2)) AS revenue,
        CONCAT('$', FORMAT(total_profit, 2)) AS profit,
        CONCAT(profit_margin_pct, '%') AS profit_margin,
        CONCAT(ROUND(avg_discount * 100, 1), '%') AS avg_discount
    FROM state_performance
    ORDER BY total_profit DESC
    LIMIT 10
)
UNION ALL
(
    SELECT 
        'Bottom 10' AS tier,
        state,
        region,
        CONCAT('$', FORMAT(total_revenue, 2)) AS revenue,
        CONCAT('$', FORMAT(total_profit, 2)) AS profit,
        CONCAT(profit_margin_pct, '%') AS profit_margin,
        CONCAT(ROUND(avg_discount * 100, 1), '%') AS avg_discount
    FROM state_performance
    ORDER BY total_profit ASC
    LIMIT 10
);
