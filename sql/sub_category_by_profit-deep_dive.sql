-- =====================================================
-- Sub-Category Deep Dive
-- =====================================================
WITH subcategory_performance AS (
	select
		category,
        sub_category,
        count(distinct order_id) as total_orders,
        sum(sales) as total_revenue,
        sum(profit) as total_profit,
        avg(discount) as avg_discount,
        round((sum(profit) / nullif(sum(sales), 0)) * 100, 2) as profit_margin_pct
	from retail_analysis.superstore_sales
    group by category, sub_category
)
select
	category,
    sub_category,
    total_orders,
    concat('$', format(total_revenue, 2)) as revenue,
    concat('$', format(total_profit, 2)) as profit,
    concat(round(avg_discount * 100, 1), '%') as avg_discount,
    -- ranking within category
    rank() over (partition by category order by total_profit desc) as profit_rank_in_category,
	-- overall ranking
    rank() over (order by total_profit desc) as overall_profit_rank
from subcategory_performance
order by total_profit desc;