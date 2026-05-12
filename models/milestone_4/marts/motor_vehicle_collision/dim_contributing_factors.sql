-- Dim_Contributing_Factor (Only for Motor Vehicle Collisions)
WITH contributing_factors AS (
    SELECT DISTINCT
        contributing_factor_vehicle_1 AS contributing_factor_description
    FROM {{ ref('stg_motor') }}
    WHERE contributing_factor_vehicle_1 IS NOT NULL

    UNION DISTINCT

    SELECT DISTINCT
        contributing_factor_vehicle_2 AS contributing_factor_description
    FROM {{ ref('stg_motor') }}
    WHERE contributing_factor_vehicle_2 IS NOT NULL
),

dim_contributing_factor AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['contributing_factor_description']) }} AS contributing_factor_key,
        
        contributing_factor_description,
        'Vehicle Crash' AS factor_category,
        
        CURRENT_TIMESTAMP() AS _marts_loaded_at
    FROM contributing_factors
)

SELECT * FROM dim_contributing_factor