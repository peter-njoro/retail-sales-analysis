-- =====================================================
-- Profit vs Discount Correlation by Sub-Category
-- =====================================================

SELECT 
    sub_category,
    category,
    -- No discount performance
    SUM(CASE WHEN discount = 0 THEN sales END) AS revenue_no_discount,
    SUM(CASE WHEN discount = 0 THEN profit END) AS profit_no_discount,
    ROUND(
        (SUM(CASE WHEN discount = 0 THEN profit END) / 
         NULLIF(SUM(CASE WHEN discount = 0 THEN sales END), 0)) * 100, 
        2
    ) AS margin_no_discount,
    -- With discount performance
    SUM(CASE WHEN discount > 0 THEN sales END) AS revenue_with_discount,
    SUM(CASE WHEN discount > 0 THEN profit END) AS profit_with_discount,
    ROUND(
        (SUM(CASE WHEN discount > 0 THEN profit END) / 
         NULLIF(SUM(CASE WHEN discount > 0 THEN sales END), 0)) * 100, 
        2
    ) AS margin_with_discount,
    -- Impact calculation
    ROUND(
        ((SUM(CASE WHEN discount > 0 THEN profit END) / 
          NULLIF(SUM(CASE WHEN discount > 0 THEN sales END), 0)) - 
         (SUM(CASE WHEN discount = 0 THEN profit END) / 
          NULLIF(SUM(CASE WHEN discount = 0 THEN sales END), 0))) * 100,
        2
    ) AS margin_impact_pp,
    AVG(CASE WHEN discount > 0 THEN discount END) AS avg_discount_rate
FROM retail_analysis.superstore_sales
GROUP BY sub_category, category
HAVING 
    SUM(CASE WHEN discount = 0 THEN sales END) > 0 
    AND SUM(CASE WHEN discount > 0 THEN sales END) > 0
ORDER BY margin_impact_pp ASC;