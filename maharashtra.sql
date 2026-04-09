use real_estate;
# 1-- Price Gap Analysis (Mumbai vs Others)
/*  This query calculates the average price for every city and compares it to Mumbai as a benchmark.
The Goal: Show how much more (or less) expensive other cities are compared to Mumbai.*/

SELECT city,
    AVG(per_sqft) AS city_avg,
    truncate(((AVG(per_sqft) / (SELECT AVG(per_sqft) FROM maharashtra WHERE city = 'Mumbai')) - 1) * 100,2) AS pct_diff
FROM maharashtra
GROUP BY city;

# 2-- city wise price & suppy
/*I calculated how many properties are available in each city and 
their average price to understand supply and pricing differences.”*/

SELECT city,
COUNT(*) AS total_listings,
ROUND(AVG(price_in_INR), 2) AS avg_price
FROM maharashtra
GROUP BY city;

/* 3-- Market Share of Each City
what percentage of total listings each city contributes
to identify dominant markets like Pune and Nagpur.” */

SELECT city,
COUNT(*) AS listings,
ROUND(
COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS market_share
FROM maharashtra
GROUP BY city;

/* 4-- Demand Segmentation
demand segments directly in SQL to analyze buyer affordability patterns.*/

SELECT 
    CASE 
        WHEN price_in_INR < 5000000 THEN 'Low Budget'
        WHEN price_in_INR BETWEEN 5000000 AND 10000000 THEN 'Mid Segment'
        ELSE 'Luxury'
    END AS segment,
    COUNT(*) AS listings_count,
    ROUND(AVG(price_in_INR), 2) AS avg_price
FROM maharashtra
GROUP BY segment
ORDER BY listings_count DESC;

-- 5. TOP INVESTMENT AREAS
/* I ranked areas based on high supply and low price to find good investment opportunities
More listings + lower price = better rank 
Which localities are most popular and still affordable? */

SELECT city, location,
COUNT(*) AS listings,
ROUND(AVG(per_sqft), 2) AS avg_price_sqft,
RANK() OVER (ORDER BY COUNT(*) DESC, AVG(per_sqft) ASC
) AS rank_position
FROM maharashtra
GROUP BY city, location;

-- 6.Property Type Distribution
/*I calculated how much each property type contributes within each city.*/
SELECT city, property_type,
    COUNT(*) AS listings,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY city), 2) AS pct_share
FROM maharashtra
GROUP BY city, property_type
ORDER BY city, pct_share DESC;

-- 7.FURNISHING IMPACT ON  PRICE
/*I analyzed how both furnishing and property status together affect pricing across cities. 
This helped me understand combined impact instead of looking at furnishing in isolation.*/

SELECT city, furnishing, status,
COUNT(*) AS total_listings,
ROUND(AVG(price), 2) AS avg_price,
ROUND(AVG(per_sqft), 2) AS avg_price_sqft
FROM maharashtra
GROUP BY city, furnishing, status
ORDER BY avg_price_sqft DESC;