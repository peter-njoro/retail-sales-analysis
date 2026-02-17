-- =====================================================
-- Business Question 4: Top 10 Customers by Revenue
-- =====================================================
-- Purpose: Identify high-value customers and their characteristics
-- Techniques: Customer aggregation, ranking, cohort analysis
-- =====================================================

-- Top 10 Customers by Revenue
WITH customer_metrics AS (
    SELECT 
        customer_id,
        customer_name,
        segment,
        region,
        COUNT(DISTINCT order_id) AS total_orders,
        COUNT(*) AS total_items,
        SUM(sales) AS total_revenue,
        SUM(profit) AS total_profit,
        SUM(quantity) AS total_quantity,
        AVG(discount) AS avg_discount,
        MIN(order_date) AS first_order_date,
        MAX(order_date) AS last_order_date,
        DATEDIFF(MAX(order_date), MIN(order_date)) AS customer_lifetime_days,
        ROUND((SUM(profit) / NULLIF(SUM(sales), 0)) * 100, 2) AS profit_margin_pct
    FROM retail_analysis.superstore_sales
    GROUP BY customer_id, customer_name, segment, region
),
ranked_customers AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (ORDER BY total_revenue DESC) AS revenue_rank,
        ROW_NUMBER() OVER (ORDER BY total_profit DESC) AS profit_rank,
        -- Calculate percentile
        PERCENT_RANK() OVER (ORDER BY total_revenue) AS revenue_percentile
    FROM customer_metrics
)
SELECT 
    revenue_rank,
    customer_name,
    customer_id,
    segment,
    region,
    total_orders,
    total_items,
    CONCAT('$', FORMAT(total_revenue, 2)) AS revenue,
    CONCAT('$', FORMAT(total_profit, 2)) AS profit,
    CONCAT(profit_margin_pct, '%') AS profit_margin,
    CONCAT('$', FORMAT(total_revenue / total_orders, 2)) AS avg_order_value,
    CONCAT(ROUND(avg_discount * 100, 1), '%') AS avg_discount,
    first_order_date,
    last_order_date,
    customer_lifetime_days,
    profit_rank,
    -- Revenue contribution
    CONCAT(ROUND((total_revenue / (SELECT SUM(sales) FROM retail_analysis.superstore_sales )) * 100, 2), '%') AS pct_of_total_revenue
FROM ranked_customers
WHERE revenue_rank <= 10
ORDER BY revenue_rank;