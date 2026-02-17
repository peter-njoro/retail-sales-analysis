-- =====================================================
-- Business Question 3: Regional Performance Analysis
-- =====================================================
-- Purpose: Identify under-performing regions
-- Techniques: Regional aggregation, benchmarking, variance analysis
-- =====================================================

-- Regional Overview with Benchmarking
WITH regional_metrics AS (
    SELECT 
        region,
        COUNT(DISTINCT customer_id) AS total_customers,
        COUNT(DISTINCT order_id) AS total_orders,
        COUNT(*) AS total_items,
        SUM(sales) AS total_revenue,
        SUM(profit) AS total_profit,
        AVG(sales) AS avg_order_value,
        AVG(discount) AS avg_discount,
        ROUND((SUM(profit) / NULLIF(SUM(sales), 0)) * 100, 2) AS profit_margin_pct
    FROM retail_analysis.superstore_sales
    GROUP BY region
),
benchmark_metrics AS (
    SELECT 
        AVG(total_revenue) AS avg_regional_revenue,
        AVG(total_profit) AS avg_regional_profit,
        AVG(profit_margin_pct) AS avg_profit_margin,
        AVG(avg_order_value) AS avg_order_value_benchmark
    FROM regional_metrics
)
SELECT 
    rm.region,
    rm.total_customers,
    rm.total_orders,
    CONCAT('$', FORMAT(rm.total_revenue, 2)) AS revenue,
    CONCAT('$', FORMAT(rm.total_profit, 2)) AS profit,
    CONCAT(rm.profit_margin_pct, '%') AS profit_margin,
    CONCAT('$', FORMAT(rm.avg_order_value, 2)) AS avg_order_value,
    CONCAT(ROUND(rm.avg_discount * 100, 1), '%') AS avg_discount,
    -- Market share
    CONCAT(ROUND((rm.total_revenue / SUM(rm.total_revenue) OVER ()) * 100, 1), '%') AS revenue_share,
    -- Performance vs benchmark
    CONCAT(
        ROUND(((rm.total_revenue - bm.avg_regional_revenue) / bm.avg_regional_revenue) * 100, 1), 
        '%'
    ) AS revenue_vs_avg,
    CONCAT(
        ROUND(((rm.total_profit - bm.avg_regional_profit) / bm.avg_regional_profit) * 100, 1), 
        '%'
    ) AS profit_vs_avg,
    CONCAT(
        ROUND(rm.profit_margin_pct - bm.avg_profit_margin, 2), 
        ' pp'
    ) AS margin_vs_avg,
    -- Performance indicator
    CASE 
        WHEN rm.total_profit < bm.avg_regional_profit 
             AND rm.profit_margin_pct < bm.avg_profit_margin 
        THEN 'Under-performing'
        WHEN rm.total_profit > bm.avg_regional_profit 
             AND rm.profit_margin_pct > bm.avg_profit_margin 
        THEN 'Out-performing'
        ELSE 'Average'
    END AS performance_status
FROM regional_metrics rm
CROSS JOIN benchmark_metrics bm
ORDER BY rm.total_profit DESC;