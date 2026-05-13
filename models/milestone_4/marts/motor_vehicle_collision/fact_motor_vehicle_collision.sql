-- Fact_Motor_Vehicle_Collision
WITH stg AS (
    SELECT * FROM {{ ref('stg_motor') }}
),

fact AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['collision_id']) }} AS collision_fact_key,
        
        -- Foreign Keys
        {{ dbt_utils.generate_surrogate_key(['CAST(crash_date AS DATE)']) }} AS date_key,
        {{ dbt_utils.generate_surrogate_key(['borough', 'zip_code']) }} AS location_key,
        {{ dbt_utils.generate_surrogate_key(['contributing_factor_vehicle_1']) }} AS contributing_factor_key,

        -- Degenerate Dimension
        collision_id,

        -- Measures
        1 AS collision_count,
        number_of_persons_injured,
        number_of_persons_killed,
        number_of_pedestrians_injured,
        number_of_pedestrians_killed,

        CURRENT_TIMESTAMP() AS _marts_loaded_at
    FROM stg
)

SELECT * FROM fact