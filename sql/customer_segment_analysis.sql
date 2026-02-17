-- =====================================================
-- Customer Segment Analysis
-- =====================================================

SELECT 
    segment,
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(DISTINCT order_id) AS total_orders,
    CONCAT('$', FORMAT(SUM(sales), 2)) AS total_revenue,
    CONCAT('$', FORMAT(SUM(profit), 2)) AS total_profit,
    CONCAT('$', FORMAT(AVG(sales), 2)) AS avg_transaction_value,
    CONCAT(ROUND((SUM(profit) / NULLIF(SUM(sales), 0)) * 100, 2), '%') AS profit_margin,
    CONCAT(ROUND(AVG(discount) * 100, 1), '%') AS avg_discount,
    -- Per customer metrics
    CONCAT('$', FORMAT(SUM(sales) / COUNT(DISTINCT customer_id), 2)) AS revenue_per_customer,
    ROUND(COUNT(DISTINCT order_id) / COUNT(DISTINCT customer_id), 1) AS orders_per_customer
FROM retail_analysis.superstore_sales
GROUP BY segment
ORDER BY SUM(sales) DESC;
