-- =====================================================
-- Customer Lifetime Value (CLV) Analysis
-- =====================================================
-- Customers with longest relationship and their value

WITH customer_tenure AS (
    SELECT 
        customer_id,
        customer_name,
        segment,
        region,
        MIN(order_date) AS first_order,
        MAX(order_date) AS last_order,
        DATEDIFF(MAX(order_date), MIN(order_date)) AS tenure_days,
        COUNT(DISTINCT order_id) AS total_orders,
        SUM(sales) AS total_revenue,
        SUM(profit) AS total_profit
    FROM retail_analysis.superstore_sales
    GROUP BY customer_id, customer_name, segment, region
    HAVING tenure_days > 0  -- Exclude one-time customers for this analysis
)
SELECT 
    customer_name,
    segment,
    region,
    first_order,
    last_order,
    tenure_days,
    ROUND(tenure_days / 365.25, 1) AS tenure_years,
    total_orders,
    CONCAT('$', FORMAT(total_revenue, 2)) AS lifetime_value,
    CONCAT('$', FORMAT(total_profit, 2)) AS lifetime_profit,
    -- Annualized metrics
    CONCAT('$', FORMAT((total_revenue / tenure_days) * 365.25, 2)) AS annualized_revenue,
    CONCAT('$', FORMAT(total_revenue / total_orders, 2)) AS avg_order_value,
    ROUND(total_orders / (tenure_days / 365.25), 1) AS avg_orders_per_year
FROM customer_tenure
ORDER BY total_revenue DESC
LIMIT 20;
