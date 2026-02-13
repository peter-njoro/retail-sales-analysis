-- =====================================================
-- Top 10 Most Profitable vs Bottom 10 Sub-Categories
-- =====================================================
(
select 
	'top 10' as performance_tier,
    sub_category,
    category,
    concat('$', format(sum(profit), 2)) as total_profit,
    concat(round((sum(profit) / nullif(sum(sales), 0)) * 100, 2), '%') as profit_margin
from retail_analysis.superstore_sales
group by sub_category, category
order by sum(profit) desc
limit 10
)
union all
(
	select
		'bottom 10' as performance_tier,
        sub_category,
        category,
        concat('$', format(sum(profit), 2)) as total_profit,
        concat(round((sum(profit) / nullif(sum(sales), 0)) * 100, 2), '%') as profit_margin
	from retail_analysis.superstore_sales
    group by sub_category, category
    order by sum(profit) asc
    limit 10
)
order by
	field(performance_tier, 'top 10', 'bottom 10'),
    case when performance_tier = 'top 10' then -1 else 1 end *
    cast(replace(replace(total_profit, '$', ''), ',', '') as decimal(10,2));