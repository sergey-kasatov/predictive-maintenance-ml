-- ============================================================
-- 02_maintenance_by_route_and_conditions.sql
-- Project: Predictive Maintenance - Maintenance Required Prediction
-- Purpose: Analyze maintenance rates across routes, road, and weather conditions
-- ============================================================


-- Maintenance rate and cost by route type
SELECT
    r.Route_Info,
    COUNT(*)                                        AS vehicle_count,
    ROUND(AVG(v.Maintenance_Required) * 100, 1)     AS maintenance_rate_pct,
    ROUND(AVG(v.Maintenance_Cost), 2)               AS avg_cost,
    ROUND(AVG(v.Downtime_Maintenance), 2)           AS avg_downtime_hrs,
    ROUND(AVG(v.Delivery_Times), 1)                 AS avg_delivery_time
FROM vehicle v
JOIN route r ON v.route_id = r.route_id
GROUP BY r.Route_Info
ORDER BY maintenance_rate_pct DESC;


-- Maintenance rate by brake condition
SELECT
    b.Brake_Condition,
    COUNT(*)                                        AS vehicle_count,
    ROUND(AVG(v.Maintenance_Required) * 100, 1)     AS maintenance_rate_pct,
    ROUND(AVG(v.Maintenance_Cost), 2)               AS avg_cost,
    ROUND(AVG(v.Vibration_Levels), 3)               AS avg_vibration
FROM vehicle v
JOIN brake b ON v.brake_id = b.brake_id
GROUP BY b.Brake_Condition
ORDER BY maintenance_rate_pct DESC;


-- Maintenance rate by weather conditions
SELECT
    w.Weather_Conditions,
    COUNT(*)                                        AS vehicle_count,
    ROUND(AVG(v.Maintenance_Required) * 100, 1)     AS maintenance_rate_pct,
    ROUND(AVG(v.Maintenance_Cost), 2)               AS avg_cost
FROM vehicle v
JOIN weather w ON v.weather_id = w.weather_id
GROUP BY w.Weather_Conditions
ORDER BY maintenance_rate_pct DESC;


-- Maintenance rate by road conditions
SELECT
    rd.Road_Conditions,
    COUNT(*)                                        AS vehicle_count,
    ROUND(AVG(v.Maintenance_Required) * 100, 1)     AS maintenance_rate_pct,
    ROUND(AVG(v.Maintenance_Cost), 2)               AS avg_cost
FROM vehicle v
JOIN road rd ON v.road_id = rd.road_id
GROUP BY rd.Road_Conditions
ORDER BY maintenance_rate_pct DESC;


-- Overloaded vehicles vs normal load
SELECT
    CASE
        WHEN Actual_Load > Load_Capacity THEN 'Overloaded'
        ELSE 'Normal Load'
    END                                             AS load_status,
    COUNT(*)                                        AS vehicle_count,
    ROUND(AVG(Maintenance_Required) * 100, 1)       AS maintenance_rate_pct,
    ROUND(AVG(Maintenance_Cost), 2)                 AS avg_cost,
    ROUND(AVG(Vibration_Levels), 3)                 AS avg_vibration
FROM vehicle
GROUP BY load_status
ORDER BY maintenance_rate_pct DESC;
