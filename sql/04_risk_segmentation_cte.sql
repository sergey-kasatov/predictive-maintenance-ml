-- ============================================================
-- 04_risk_segmentation_cte.sql
-- Project: Predictive Maintenance - Maintenance Required Prediction
-- Purpose: CTE-based fleet risk scoring and vehicle segmentation
-- ============================================================


-- Multi-step CTE: score each vehicle, then group into risk tiers
WITH vehicle_scores AS (
    -- Step 1: Assign points for each risk factor per vehicle.
    SELECT
        v.Vehicle_ID,
        m.Make_and_Model,
        vt.Vehicle_Type,
        r.Route_Info,
        v.Usage_Hours,
        v.Maintenance_Required,
        v.Maintenance_Cost,
        -- Age risk: older than 10 years scores 1 point
        CASE WHEN (2024 - v.Year_of_Manufacture) > 10 THEN 1 ELSE 0 END AS age_risk,
        -- Usage risk: more than 5000 hours scores 1 point
        CASE WHEN v.Usage_Hours > 5000 THEN 1 ELSE 0 END                AS usage_risk,
        -- Overload risk: actual load exceeds rated capacity scores 1 point
        CASE WHEN v.Actual_Load > v.Load_Capacity THEN 1 ELSE 0 END     AS overload_risk,
        -- Brake risk: poor brake condition scores 1 point
        CASE WHEN b.Brake_Condition = 'Poor' THEN 1 ELSE 0 END          AS brake_risk
    FROM vehicle v
    JOIN model        m  ON v.model_id        = m.model_id
    JOIN vehicle_type vt ON v.vehicle_type_id = vt.vehicle_type_id
    JOIN route        r  ON v.route_id        = r.route_id
    JOIN brake        b  ON v.brake_id        = b.brake_id
),
scored AS (
    -- Step 2: Sum the individual risk flags into a total risk score (0-4).
    SELECT
        Vehicle_ID,
        Make_and_Model,
        Vehicle_Type,
        Route_Info,
        Usage_Hours,
        Maintenance_Required,
        Maintenance_Cost,
        (age_risk + usage_risk + overload_risk + brake_risk) AS risk_score
    FROM vehicle_scores
),
segmented AS (
    -- Step 3: Map the numeric score to a human-readable risk tier.
    SELECT
        *,
        CASE
            WHEN risk_score = 0 THEN '1 - Low'
            WHEN risk_score = 1 THEN '2 - Medium'
            WHEN risk_score = 2 THEN '3 - High'
            ELSE                     '4 - Critical'
        END AS risk_tier
    FROM scored
)
-- Step 4: Aggregate results by risk tier to show business impact.
SELECT
    risk_tier,
    COUNT(*)                                        AS vehicle_count,
    ROUND(AVG(Maintenance_Required) * 100, 1)       AS maintenance_rate_pct,
    ROUND(AVG(Maintenance_Cost), 2)                 AS avg_cost,
    ROUND(SUM(Maintenance_Cost), 0)                 AS total_cost,
    ROUND(AVG(Usage_Hours), 0)                      AS avg_usage_hours
FROM segmented
GROUP BY risk_tier
ORDER BY risk_tier;


-- Drill-down: top 20 highest-risk individual vehicles
WITH vehicle_scores AS (
    SELECT
        v.Vehicle_ID,
        m.Make_and_Model,
        vt.Vehicle_Type,
        r.Route_Info,
        v.Usage_Hours,
        v.Maintenance_Required,
        v.Maintenance_Cost,
        CASE WHEN (2024 - v.Year_of_Manufacture) > 10 THEN 1 ELSE 0 END AS age_risk,
        CASE WHEN v.Usage_Hours > 5000 THEN 1 ELSE 0 END                AS usage_risk,
        CASE WHEN v.Actual_Load > v.Load_Capacity THEN 1 ELSE 0 END     AS overload_risk,
        CASE WHEN b.Brake_Condition = 'Poor' THEN 1 ELSE 0 END          AS brake_risk
    FROM vehicle v
    JOIN model        m  ON v.model_id        = m.model_id
    JOIN vehicle_type vt ON v.vehicle_type_id = vt.vehicle_type_id
    JOIN route        r  ON v.route_id        = r.route_id
    JOIN brake        b  ON v.brake_id        = b.brake_id
)
SELECT
    Vehicle_ID,
    Make_and_Model,
    Vehicle_Type,
    Route_Info,
    Usage_Hours,
    Maintenance_Required,
    ROUND(Maintenance_Cost, 2)                               AS maintenance_cost,
    (age_risk + usage_risk + overload_risk + brake_risk)    AS risk_score,
    age_risk,
    usage_risk,
    overload_risk,
    brake_risk
FROM vehicle_scores
ORDER BY risk_score DESC, Maintenance_Cost DESC
LIMIT 20;


-- Risk tier distribution by vehicle type (cross-tab)
WITH vehicle_scores AS (
    SELECT
        vt.Vehicle_Type,
        (CASE WHEN (2024 - v.Year_of_Manufacture) > 10 THEN 1 ELSE 0 END
         + CASE WHEN v.Usage_Hours > 5000 THEN 1 ELSE 0 END
         + CASE WHEN v.Actual_Load > v.Load_Capacity THEN 1 ELSE 0 END
         + CASE WHEN b.Brake_Condition = 'Poor' THEN 1 ELSE 0 END) AS risk_score
    FROM vehicle v
    JOIN vehicle_type vt ON v.vehicle_type_id = vt.vehicle_type_id
    JOIN brake        b  ON v.brake_id        = b.brake_id
)
SELECT
    Vehicle_Type,
    COUNT(*)                                                        AS total,
    SUM(CASE WHEN risk_score = 0 THEN 1 ELSE 0 END)                AS low_risk,
    SUM(CASE WHEN risk_score = 1 THEN 1 ELSE 0 END)                AS medium_risk,
    SUM(CASE WHEN risk_score >= 2 THEN 1 ELSE 0 END)               AS high_critical_risk,
    ROUND(SUM(CASE WHEN risk_score >= 2 THEN 1 ELSE 0 END) * 100.0
          / COUNT(*), 1)                                            AS high_critical_pct
FROM vehicle_scores
GROUP BY Vehicle_Type
ORDER BY high_critical_pct DESC;
