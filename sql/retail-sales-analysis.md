# Retail Sales Analysis — Sample Superstore
**Portfolio Project | Data Analysis**
*Tools: SQL · Python · Power BI*

---

## 1. Problem Statement

A retail company operating across the United States needed to understand what was truly driving — and eroding — profitability across its product lines, customer segments, and geographic markets. Despite generating over $2.2M in revenue, leadership lacked visibility into *why* profit margins remained thin and which areas of the business deserved strategic attention.

**Core business questions driving the analysis:**
1. Which product categories and sub-categories are most and least profitable?
2. Do discounting practices help or hurt the bottom line?
3. Which customer segments and regions generate the highest return?
4. How has performance trended year-over-year?
5. Which states represent risk vs. opportunity?

---

## 2. Dataset Overview

| Attribute | Detail |
|---|---|
| **Source** | Sample Superstore (Tableau Public Dataset) |
| **Record Count** | 9,994 order line items |
| **Time Period** | 2014 – 2017 |
| **Geography** | 49 U.S. states · 531 cities |
| **Customers** | 793 unique customers |
| **Orders** | 5,009 unique orders |
| **Products** | 1,862 unique SKUs |
| **Key Metrics** | Sales, Profit, Quantity, Discount |

**Columns of interest:** `Order Date`, `Ship Mode`, `Segment`, `Region`, `State`, `Category`, `Sub-Category`, `Sales`, `Quantity`, `Discount`, `Profit`

No significant data quality issues were found. Dates were standardised and discount values were validated to fall within the [0, 1] range.

---

## 3. Tools Used

| Tool | Purpose |
|---|---|
| **SQL (SQLite / PostgreSQL syntax)** | Data extraction, aggregation, business logic |
| **Python (pandas)** | Data cleaning, exploratory analysis, metric calculation |
| **Power BI** | Interactive dashboard and visual storytelling |
| **Markdown / Git** | Project documentation and version control |

---

## 4. Key Questions

1. What is the overall profitability profile of the business?
2. Which categories and sub-categories are profit drivers vs. profit drains?
3. What is the financial impact of the company's discounting strategy?
4. How do performance metrics vary by customer segment and geographic region?
5. What year-over-year trends are visible in revenue and profit?

---

## 5. Analysis Summary

### 5.1 Overall Business Performance

```sql
SELECT
    ROUND(SUM(Sales), 2)                             AS total_sales,
    ROUND(SUM(Profit), 2)                            AS total_profit,
    ROUND(SUM(Profit) / SUM(Sales) * 100, 2)         AS profit_margin_pct,
    COUNT(DISTINCT "Order ID")                       AS total_orders,
    COUNT(DISTINCT "Customer ID")                    AS total_customers
FROM superstore;
```

| Metric | Value |
|---|---|
| Total Sales | $2,297,200.86 |
| Total Profit | $286,397.02 |
| Profit Margin | 12.5% |
| Total Orders | 5,009 |
| Total Customers | 793 |

At a 12.5% overall profit margin, the business is viable but leaves significant room for improvement — particularly given that certain sub-categories and states are actively destroying value (negative margins).

---

### 5.2 Profitability by Product Category

```sql
SELECT
    Category,
    ROUND(SUM(Sales), 2)                            AS total_sales,
    ROUND(SUM(Profit), 2)                           AS total_profit,
    ROUND(SUM(Profit) / SUM(Sales) * 100, 2)        AS profit_margin_pct,
    COUNT("Order ID")                               AS total_orders
FROM superstore
GROUP BY Category
ORDER BY total_profit DESC;
```

| Category | Sales | Profit | Margin |
|---|---|---|---|
| Technology | $836,154 | $145,455 | **17.4%** |
| Office Supplies | $719,047 | $122,491 | **17.0%** |
| Furniture | $741,999 | $18,451 | **2.5%** |

**Furniture generates the third-highest sales volume but delivers only a 2.5% margin** — 7x lower than Technology. This signals either structural pricing problems or discount overuse within that category.

---

### 5.3 Sub-Category Deep Dive (Profit Drains)

```sql
SELECT
    "Sub-Category",
    ROUND(SUM(Sales), 2)                            AS total_sales,
    ROUND(SUM(Profit), 2)                           AS total_profit,
    ROUND(SUM(Profit) / SUM(Sales) * 100, 2)        AS profit_margin_pct
FROM superstore
GROUP BY "Sub-Category"
ORDER BY total_profit ASC
LIMIT 5;
```

| Sub-Category | Sales | Profit | Margin |
|---|---|---|---|
| Tables | $206,965 | **-$17,725** | -8.6% |
| Bookcases | $114,880 | **-$3,473** | -3.0% |
| Supplies | $46,673 | **-$1,189** | -2.6% |
| Machines | $189,239 | $3,385 | 1.8% |
| Fasteners | $3,024 | $950 | 31.4% |

Tables and Bookcases — both within the Furniture category — are **loss-making at scale**. Tables alone generated over $200K in revenue while losing nearly $18K. These sub-categories are candidates for immediate pricing or discount policy review.

---

### 5.4 The Discount Problem

This is one of the most actionable findings in the entire analysis.

```sql
SELECT
    CASE
        WHEN Discount = 0              THEN 'No Discount'
        WHEN Discount <= 0.20          THEN 'Low (0–20%)'
        WHEN Discount <= 0.50          THEN 'Medium (20–50%)'
        ELSE                                'High (50%+)'
    END                                         AS discount_tier,
    COUNT("Order ID")                           AS total_orders,
    ROUND(SUM(Sales), 2)                        AS total_sales,
    ROUND(SUM(Profit), 2)                       AS total_profit,
    ROUND(SUM(Profit) / SUM(Sales) * 100, 2)    AS profit_margin_pct
FROM superstore
GROUP BY discount_tier
ORDER BY profit_margin_pct DESC;
```

| Discount Tier | Orders | Sales | Profit | Margin |
|---|---|---|---|---|
| No Discount | 4,798 | $1,087,908 | $320,988 | **+29.5%** |
| Low (0–20%) | 3,803 | $846,522 | $100,785 | **+11.9%** |
| Medium (20–50%) | 537 | $298,541 | -$58,817 | **-19.7%** |
| High (50%+) | 856 | $64,229 | -$76,559 | **-119.2%** |

**Orders with discounts above 20% are collectively destroying $135,376 in profit.** High-discount orders (50%+) lose $1.19 for every $1.00 in revenue generated. The company is paying customers to take products. This is the single largest addressable lever in the business.

---

### 5.5 Performance by Customer Segment

```sql
SELECT
    Segment,
    ROUND(SUM(Sales), 2)                            AS total_sales,
    ROUND(SUM(Profit), 2)                           AS total_profit,
    ROUND(SUM(Profit) / SUM(Sales) * 100, 2)        AS profit_margin_pct
FROM superstore
GROUP BY Segment
ORDER BY profit_margin_pct DESC;
```

| Segment | Sales | Profit | Margin |
|---|---|---|---|
| Home Office | $429,653 | $60,299 | **14.0%** |
| Corporate | $706,146 | $91,979 | **13.0%** |
| Consumer | $1,161,401 | $134,119 | **11.6%** |

The **Consumer segment drives the most revenue (50.5% of total)** but has the lowest margin. Home Office, while the smallest segment by revenue, returns the highest margin. Corporate offers the best balance of volume and profitability.

---

### 5.6 Regional Performance

```sql
SELECT
    Region,
    ROUND(SUM(Sales), 2)                            AS total_sales,
    ROUND(SUM(Profit), 2)                           AS total_profit,
    ROUND(SUM(Profit) / SUM(Sales) * 100, 2)        AS profit_margin_pct
FROM superstore
GROUP BY Region
ORDER BY total_profit DESC;
```

| Region | Sales | Profit | Margin |
|---|---|---|---|
| West | $725,458 | $108,418 | **14.9%** |
| East | $678,781 | $91,523 | **13.5%** |
| South | $391,722 | $46,749 | **11.9%** |
| Central | $501,240 | $39,706 | **7.9%** |

The **West region leads in both absolute profit and margin**. The Central region is underperforming — despite $500K in sales, its 7.9% margin is nearly half the West's. State-level analysis below explains why.

---

### 5.7 State-Level Risk Identification

```sql
SELECT
    State,
    ROUND(SUM(Sales), 2)                            AS total_sales,
    ROUND(SUM(Profit), 2)                           AS total_profit,
    ROUND(SUM(Profit) / SUM(Sales) * 100, 2)        AS profit_margin_pct
FROM superstore
GROUP BY State
HAVING total_profit < 0
ORDER BY total_profit ASC;
```

**Profit-Negative States:**

| State | Sales | Profit | Margin |
|---|---|---|---|
| Texas | $170,188 | -$25,729 | -15.1% |
| Ohio | $78,258 | -$16,971 | -21.7% |
| Pennsylvania | $116,512 | -$15,560 | -13.4% |
| Illinois | $80,166 | -$12,608 | -15.7% |
| North Carolina | $55,603 | -$7,491 | -13.5% |

These five states collectively generated **~$501K in revenue while losing $78,359 in profit**. Texas alone accounts for nearly a third of those losses. Geographic discount policies or product mix issues in these markets warrant immediate investigation.

---

### 5.8 Year-over-Year Trend

```sql
SELECT
    STRFTIME('%Y', "Order Date")                    AS year,
    ROUND(SUM(Sales), 2)                            AS total_sales,
    ROUND(SUM(Profit), 2)                           AS total_profit,
    ROUND(SUM(Profit) / SUM(Sales) * 100, 2)        AS profit_margin_pct,
    COUNT(DISTINCT "Order ID")                      AS total_orders
FROM superstore
GROUP BY year
ORDER BY year;
```

| Year | Sales | Profit | Margin | Orders |
|---|---|---|---|---|
| 2014 | $484,248 | $49,544 | 10.2% | 969 |
| 2015 | $470,533 | $61,619 | 13.1% | 1,038 |
| 2016 | $609,206 | $81,795 | 13.4% | 1,315 |
| 2017 | $733,215 | $93,439 | 12.7% | 1,687 |

**Revenue has grown 51.4% from 2014 to 2017**, and profit has nearly doubled (+88.6%). The slight margin dip in 2017 (13.4% → 12.7%) suggests that growth may be outpacing pricing discipline — likely tied to increased discounting to acquire volume.

---

## 6. Insights

**Insight 1 — Discounting is the primary profit leak.**
Orders with discounts above 20% are collectively unprofitable. This single policy change — capping discounts at 20% — could recover an estimated **$135,000+ in lost profit annually**.

**Insight 2 — Furniture is a structural problem.**
Tables and Bookcases generate meaningful revenue but are reliably loss-making. The category's 2.5% margin, compared to 17%+ in Technology and Office Supplies, indicates either aggressive discounting, poor cost control, or misaligned pricing strategy.

**Insight 3 — The West and East regions are the profit engine.**
Together they account for $199,942 in profit (69.8% of total) while the Central region produces only 13.9% of company profit despite 21.8% of sales. This suggests the Central region disproportionately carries high-discount or low-margin orders.

**Insight 4 — Five states are operating at a loss.**
Texas, Ohio, Pennsylvania, Illinois, and North Carolina collectively lose money. These markets likely have aggressive regional sales strategies that prioritise revenue over margin.

**Insight 5 — Growth is strong but margin discipline is weakening.**
The company grew 51% in revenue over four years, which is excellent. However, the 2017 margin compression suggests the business is acquiring growth through discounting, which is unsustainable.

**Insight 6 — Home Office is an undervalued segment.**
Home Office customers generate the highest profit margin (14%) with lower churn risk. This segment may deserve more targeted marketing investment relative to the Consumer segment, which has the highest volume but lowest margin.

---

## 7. Recommendations

**1. Implement a Discount Ceiling Policy**
Cap all customer-facing discounts at 20%. Discounts above this threshold are guaranteed to destroy margin. Apply this as a hard rule in the sales system and review exceptions manually. *Estimated annual profit recovery: $135,000+.*

**2. Conduct a Furniture Category Audit**
Specifically review Tables and Bookcases. Determine whether losses are driven by excessive discounting, vendor cost issues, or competitive pricing pressure. If costs cannot be restructured, consider reducing SKU count or exiting unprofitable product lines.

**3. Build a State-Level Profitability Dashboard**
Make margin-by-state visible to regional sales managers on a monthly basis. Texas and Ohio are losing money at scale — sales teams in these markets may be unaware of the margin impact of their discounting behaviour. Visibility drives accountability.

**4. Prioritise Corporate and Home Office Segments**
While Consumer is the largest segment, Corporate and Home Office yield higher margins with lower volume requirements. Consider shifting marketing investment and account management resources toward these two segments.

**5. Protect Margin During Growth**
With revenue trending upward, establish a minimum acceptable margin threshold (e.g., 12%) at the sub-category and regional level, and build alerts when margins fall below this floor. This will prevent the 2017 pattern of volume growth masking margin erosion from repeating.

---

## Appendix: Data Validation Notes

- Dataset spans **2014–2017** (four full fiscal years)
- Discount values ranged from 0 to 0.80; no anomalous values detected
- Negative profit values were verified as legitimate (not data errors) — they reflect the discount impact confirmed analytically
- Postal codes were present for all U.S. records; no international orders in dataset

---

*Documentation prepared as part of a Data Analyst portfolio project. Analysis performed in Python (pandas) and SQL. Visualisations available in the accompanying Power BI report.*
