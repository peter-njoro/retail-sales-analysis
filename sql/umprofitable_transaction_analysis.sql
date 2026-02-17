-- =====================================================
-- Unprofitable Transactions Analysis
-- =====================================================
-- Focus on discounted items that resulted in losses

SELECT 
    category,
    sub_category,
    COUNT(*) AS loss_transactions,
    CONCAT('$', FORMAT(SUM(sales), 2)) AS revenue_from_losses,
    CONCAT('$', FORMAT(SUM(profit), 2)) AS total_loss_amount,
    CONCAT(ROUND(AVG(discount) * 100, 1), '%') AS avg_discount_on_losses,
    CONCAT('$', FORMAT(AVG(sales), 2)) AS avg_sale_price,
    CONCAT('$', FORMAT(AVG(profit), 2)) AS avg_loss_per_transaction,
    -- Compare to category average
    (SELECT CONCAT(ROUND(AVG(discount) * 100, 1), '%')
     FROM superstore_sales s2 
     WHERE s2.category = s1.category) AS category_avg_discount
FROM retail_analysis.superstore_sales s1
WHERE profit < 0
GROUP BY category, sub_category
ORDER BY SUM(profit) ASC
LIMIT 20;