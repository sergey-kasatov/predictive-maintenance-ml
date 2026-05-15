-- ============================================================
-- 01_fleet_overview.sql
-- Project: Predictive Maintenance - Maintenance Required Prediction
-- Purpose: High-level fleet summary and maintenance rate by vehicle type and model
-- ============================================================


-- Overall fleet KPIs
SELECT
    COUNT(*)                                        AS total_vehicles,
    SUM(Maintenance_Required)                       AS needs_maintenance,
    ROUND(AVG(Maintenance_Required) * 100, 1)       AS maintenance_rate_pct,
    ROUND(AVG(Usage_Hours), 0)                      AS avg_usage_hours,
    ROUND(AVG(2024 - Year_of_Manufacture), 1)       AS avg_vehicle_age_years,
    ROUND(AVG(Maintenance_Cost), 2)                 AS avg_maintenance_cost
FROM vehicle;


-- Fleet breakdown by vehicle type
SELECT
    vt.Vehicle_Type,
    COUNT(*)                                        AS vehicle_count,
    ROUND(AVG(v.Maintenance_Required) * 100, 1)     AS maintenance_rate_pct,
    ROUND(AVG(v.Usage_Hours), 0)                    AS avg_usage_hours,
    ROUND(AVG(v.Maintenance_Cost), 2)               AS avg_cost
FROM vehicle v
JOIN vehicle_type vt ON v.vehicle_type_id = vt.vehicle_type_id
GROUP BY vt.Vehicle_Type
ORDER BY maintenance_rate_pct DESC;


-- Fleet breakdown by make and model
SELECT
    m.Make_and_Model,
    COUNT(*)                                        AS vehicle_count,
    ROUND(AVG(v.Maintenance_Required) * 100, 1)     AS maintenance_rate_pct,
    ROUND(AVG(v.Usage_Hours), 0)                    AS avg_usage_hours,
    ROUND(AVG(v.Maintenance_Cost), 2)               AS avg_cost
FROM vehicle v
JOIN model m ON v.model_id = m.model_id
GROUP BY m.Make_and_Model
ORDER BY maintenance_rate_pct DESC;
