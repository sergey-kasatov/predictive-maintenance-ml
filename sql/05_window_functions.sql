-- ============================================================
-- 05_window_functions.sql
-- Project: Predictive Maintenance - Maintenance Required Prediction
-- Purpose: Demonstrate window functions for fleet ranking and percentile analysis
-- ============================================================


-- ROW_NUMBER: rank vehicles within each type by maintenance cost (highest first)
SELECT
    vt.Vehicle_Type,
    v.Vehicle_ID,
    m.Make_and_Model,
    ROUND(v.Maintenance_Cost, 2)                    AS maintenance_cost,
    v.Usage_Hours,
    v.Maintenance_Required,
    ROW_NUMBER() OVER (
        PARTITION BY vt.Vehicle_Type
        ORDER BY v.Maintenance_Cost DESC
    )                                               AS rank_in_type
FROM vehicle v
JOIN vehicle_type vt ON v.vehicle_type_id = vt.vehicle_type_id
JOIN model        m  ON v.model_id        = m.model_id
ORDER BY vt.Vehicle_Type, rank_in_type
LIMIT 50;


-- RANK with ties: rank vehicles by usage hours within each route
-- (vehicles with equal hours get the same rank, next rank is skipped)
SELECT
    r.Route_Info,
    v.Vehicle_ID,
    m.Make_and_Model,
    v.Usage_Hours,
    v.Maintenance_Required,
    RANK() OVER (
        PARTITION BY r.Route_Info
        ORDER BY v.Usage_Hours DESC
    )                                               AS usage_rank_in_route
FROM vehicle v
JOIN route r ON v.route_id = r.route_id
JOIN model m ON v.model_id = m.model_id
ORDER BY r.Route_Info, usage_rank_in_route
LIMIT 60;


-- NTILE(4): split the entire fleet into cost quartiles
-- Q4 = most expensive 25%; Q1 = least expensive 25%
SELECT
    v.Vehicle_ID,
    m.Make_and_Model,
    vt.Vehicle_Type,
    ROUND(v.Maintenance_Cost, 2)                    AS maintenance_cost,
    v.Usage_Hours,
    v.Maintenance_Required,
    NTILE(4) OVER (ORDER BY v.Maintenance_Cost)     AS cost_quartile
FROM vehicle v
JOIN model        m  ON v.model_id        = m.model_id
JOIN vehicle_type vt ON v.vehicle_type_id = vt.vehicle_type_id
ORDER BY cost_quartile, maintenance_cost DESC
LIMIT 80;


-- Quartile summary: aggregate stats per cost quartile
SELECT
    cost_quartile,
    COUNT(*)                                        AS vehicle_count,
    ROUND(MIN(maintenance_cost), 2)                 AS min_cost,
    ROUND(MAX(maintenance_cost), 2)                 AS max_cost,
    ROUND(AVG(maintenance_cost), 2)                 AS avg_cost,
    ROUND(AVG(Maintenance_Required) * 100, 1)       AS maintenance_rate_pct,
    ROUND(AVG(Usage_Hours), 0)                      AS avg_usage_hours
FROM (
    SELECT
        v.Maintenance_Cost                                      AS maintenance_cost,
        v.Maintenance_Required,
        v.Usage_Hours,
        NTILE(4) OVER (ORDER BY v.Maintenance_Cost)             AS cost_quartile
    FROM vehicle v
)
GROUP BY cost_quartile
ORDER BY cost_quartile;


-- Running total of maintenance cost by usage hours bucket
-- Shows cumulative fleet spend as usage hours increase
SELECT
    usage_bucket,
    vehicle_count,
    bucket_total_cost,
    ROUND(
        SUM(bucket_total_cost) OVER (
            ORDER BY usage_bucket
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ), 0
    )                                               AS running_total_cost,
    ROUND(AVG(maintenance_rate_pct), 1)             AS maintenance_rate_pct
FROM (
    SELECT
        CASE
            WHEN Usage_Hours < 2000  THEN '1 - <2000 h'
            WHEN Usage_Hours < 4000  THEN '2 - 2000-4000 h'
            WHEN Usage_Hours < 6000  THEN '3 - 4000-6000 h'
            ELSE                          '4 - >6000 h'
        END                                         AS usage_bucket,
        COUNT(*)                                    AS vehicle_count,
        ROUND(SUM(Maintenance_Cost), 0)             AS bucket_total_cost,
        ROUND(AVG(Maintenance_Required) * 100, 1)   AS maintenance_rate_pct
    FROM vehicle
    GROUP BY usage_bucket
)
ORDER BY usage_bucket;
