-- =====================================================
-- Business Question 5: Discount Impact on Profit
-- =====================================================
-- Purpose: Analyze correlation between discount levels and profitability
-- Techniques: CASE WHEN, bucketing, correlation analysis
-- =====================================================

-- Discount Tier Performance Analysis
WITH discount_tiers AS (
    SELECT 
        *,
        CASE 
            WHEN discount = 0 THEN 'No Discount'
            WHEN discount > 0 AND discount <= 0.10 THEN '1-10%'
            WHEN discount > 0.10 AND discount <= 0.20 THEN '11-20%'
            WHEN discount > 0.20 AND discount <= 0.30 THEN '21-30%'
            WHEN discount > 0.30 THEN '30%+'
            ELSE 'Unknown'
        END AS discount_tier,
        CASE 
            WHEN profit > 0 THEN 'Profitable'
            WHEN profit = 0 THEN 'Break-even'
            ELSE 'Loss'
        END AS profit_status
    FROM retail_analysis.superstore_sales
)
SELECT 
    discount_tier,
    COUNT(*) AS total_transactions,
    COUNT(DISTINCT order_id) AS total_orders,
    CONCAT('$', FORMAT(SUM(sales), 2)) AS total_revenue,
    CONCAT('$', FORMAT(SUM(profit), 2)) AS total_profit,
    CONCAT('$', FORMAT(AVG(sales), 2)) AS avg_transaction_value,
    CONCAT('$', FORMAT(AVG(profit), 2)) AS avg_profit_per_transaction,
    CONCAT(ROUND((SUM(profit) / NULLIF(SUM(sales), 0)) * 100, 2), '%') AS profit_margin,
    CONCAT(ROUND(AVG(discount) * 100, 1), '%') AS avg_discount_in_tier,
    -- Profitability breakdown
    SUM(CASE WHEN profit_status = 'Profitable' THEN 1 ELSE 0 END) AS profitable_transactions,
    SUM(CASE WHEN profit_status = 'Loss' THEN 1 ELSE 0 END) AS loss_transactions,
    CONCAT(
        ROUND((SUM(CASE WHEN profit_status = 'Loss' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 1), 
        '%'
    ) AS loss_rate
FROM discount_tiers
GROUP BY discount_tier
ORDER BY 
    FIELD(discount_tier, 'No Discount', '1-10%', '11-20%', '21-30%', '30%+', 'Unknown');
