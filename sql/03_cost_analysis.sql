-- ============================================================
-- 03_cost_analysis.sql
-- Project: Predictive Maintenance - Maintenance Required Prediction
-- Purpose: Maintenance cost breakdown by model, route, and maintenance type
-- ============================================================


-- Cost summary by maintenance type
SELECT
    mt.Maintenance_Type,
    COUNT(*)                                        AS vehicle_count,
    ROUND(AVG(v.Maintenance_Cost), 2)               AS avg_cost,
    ROUND(MIN(v.Maintenance_Cost), 2)               AS min_cost,
    ROUND(MAX(v.Maintenance_Cost), 2)               AS max_cost,
    ROUND(SUM(v.Maintenance_Cost), 0)               AS total_cost
FROM vehicle v
JOIN maintenance_type mt ON v.maintenance_id = mt.maintenance_id
GROUP BY mt.Maintenance_Type
ORDER BY avg_cost DESC;


-- Cost breakdown by model and route (cross-tab style)
SELECT
    m.Make_and_Model,
    r.Route_Info,
    COUNT(*)                                        AS vehicle_count,
    ROUND(AVG(v.Maintenance_Cost), 2)               AS avg_cost,
    ROUND(SUM(v.Maintenance_Cost), 0)               AS total_cost,
    ROUND(AVG(v.Maintenance_Required) * 100, 1)     AS maintenance_rate_pct
FROM vehicle v
JOIN model m ON v.model_id = m.model_id
JOIN route r ON v.route_id = r.route_id
GROUP BY m.Make_and_Model, r.Route_Info
ORDER BY avg_cost DESC;


-- Cost percentile distribution (LOW / MID / HIGH buckets)
SELECT
    CASE
        WHEN Maintenance_Cost < 300  THEN '1 - Low  (<$300)'
        WHEN Maintenance_Cost < 1000 THEN '2 - Mid  ($300-$1000)'
        ELSE                              '3 - High (>$1000)'
    END                                             AS cost_bucket,
    COUNT(*)                                        AS vehicle_count,
    ROUND(AVG(Maintenance_Required) * 100, 1)       AS maintenance_rate_pct,
    ROUND(AVG(Usage_Hours), 0)                      AS avg_usage_hours
FROM vehicle
GROUP BY cost_bucket
ORDER BY cost_bucket;
