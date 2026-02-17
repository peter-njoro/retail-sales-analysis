-- =====================================================
-- High-Value Customer Preferences
-- =====================================================
-- What do top customers buy?

SELECT 
    category,
    sub_category,
    COUNT(DISTINCT s.customer_id) AS customers_in_top_100,
    COUNT(DISTINCT s.order_id) AS total_orders,
    CONCAT('$', FORMAT(SUM(s.sales), 2)) AS revenue_from_top_customers,
    CONCAT('$', FORMAT(AVG(s.sales), 2)) AS avg_transaction_value
FROM retail_analysis.superstore_sales s  
WHERE s.customer_id IN (
    SELECT customer_id
    FROM (
        SELECT customer_id, SUM(sales) AS total_revenue
        FROM retail_analysis.superstore_sales
        GROUP BY customer_id
        ORDER BY total_revenue DESC
        LIMIT 100
    ) top_customers
)
GROUP BY category, sub_category
ORDER BY SUM(s.sales) DESC;