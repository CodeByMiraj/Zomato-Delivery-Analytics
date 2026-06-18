-- ============================================
-- ZOMATO DELIVERY OPERATIONS — SQL ANALYSIS
-- Author: Miraj Rajendra Patil
-- Dataset: Zomato Delivery Operations Analytics
-- Purpose: Business intelligence queries to support
--          operational decision making
-- ============================================

-- ── Query 1: City-wise delivery performance summary ──
-- Business Question: Which city has the worst delivery performance?


SELECT 
    City,
    COUNT(*) AS total_deliveries,
    ROUND(AVG(Time_taken_min), 2) AS avg_delivery_time,
    ROUND(MIN(Time_taken_min), 2) AS min_delivery_time,
    ROUND(MAX(Time_taken_min), 2) AS max_delivery_time,
    ROUND(SUM(CASE WHEN Time_taken_min > 35 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS sla_breach_pct
FROM zomato_deliveries
GROUP BY City
ORDER BY avg_delivery_time DESC;



-- ── Query 2: Traffic density impact on delivery time ──
-- Business Question: How much does traffic increase delivery time?

SELECT
    Road_traffic_density,
    COUNT(*) AS total_deliveries,
    ROUND(AVG(Time_taken_min), 2) AS avg_delivery_time,
    ROUND(AVG(Time_taken_min) - (SELECT AVG(Time_taken_min) FROM zomato_deliveries), 2) AS deviation_from_mean
FROM zomato_deliveries
GROUP BY Road_traffic_density
ORDER BY avg_delivery_time DESC;



-- ── Query 3: Multiple deliveries impact ──
-- Business Question: How do simultaneous deliveries affect time?

SELECT
    multiple_deliveries,
    COUNT(*) AS total_deliveries,
    ROUND(AVG(Time_taken_min), 2) AS avg_delivery_time,
    ROUND((AVG(Time_taken_min) - MIN(AVG(Time_taken_min)) OVER()) * 100.0 / 
          MIN(AVG(Time_taken_min)) OVER(), 2) AS pct_increase_from_best
FROM zomato_deliveries
GROUP BY multiple_deliveries
ORDER BY multiple_deliveries;



-- ── Query 4: Top and bottom performing delivery partners ──
-- Business Question: What separates high performers from low performers?

SELECT
    CASE 
        WHEN Delivery_person_Ratings >= 4.5 THEN 'High Rated'
        WHEN Delivery_person_Ratings >= 4.0 THEN 'Mid Rated'
        ELSE 'Low Rated'
    END AS rating_category,
    COUNT(*) AS total_deliveries,
    ROUND(AVG(Delivery_person_Ratings), 2) AS avg_rating,
    ROUND(AVG(Time_taken_min), 2) AS avg_delivery_time,
    ROUND(AVG(Delivery_person_Age), 2) AS avg_age
FROM zomato_deliveries
GROUP BY rating_category
ORDER BY avg_delivery_time ASC;



-- ── Query 5: Worst performing conditions combined ──
-- Business Question: What combination of factors causes the most delays?

SELECT
    City,
    Road_traffic_density,
    Weather_conditions,
    COUNT(*) AS total_deliveries,
    ROUND(AVG(Time_taken_min), 2) AS avg_delivery_time
FROM zomato_deliveries
WHERE Time_taken_min > 35
GROUP BY City, Road_traffic_density, Weather_conditions
HAVING COUNT(*) > 50
ORDER BY avg_delivery_time DESC
LIMIT 10;