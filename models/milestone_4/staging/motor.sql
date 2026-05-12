-- Staging: Motor Vehicle Collisions
-- Cleaned and standardized version of raw crash data

WITH source AS (
    SELECT * 
    FROM {{ source('raw', 'motorvehicle_collisions_crashes') }}
),

cleaned AS (
    SELECT
        -- Surrogate / Unique Key
        CAST(collision_id AS STRING) AS collision_id,

        -- Dates & Time
        CAST(crash_date AS DATE) AS crash_date,
        PARSE_TIME('%H:%M', crash_time) AS crash_time,           -- Convert text time to TIME type
        TIMESTAMP(crash_date, PARSE_TIME('%H:%M', crash_time)) AS crash_datetime,

        -- Location
        borough,
        zip_code,
        CAST(latitude AS FLOAT64) AS latitude,
        CAST(longitude AS FLOAT64) AS longitude,

        -- Measures (Facts)
        CAST(number_of_persons_injured AS INT64) AS number_of_persons_injured,
        CAST(number_of_persons_killed AS INT64) AS number_of_persons_killed,
        CAST(number_of_pedestrians_injured AS INT64) AS number_of_pedestrians_injured,
        CAST(number_of_pedestrians_killed AS INT64) AS number_of_pedestrians_killed,
        CAST(number_of_cyclist_injured AS INT64) AS number_of_cyclist_injured,
        CAST(number_of_cyclist_killed AS INT64) AS number_of_cyclist_killed,
        CAST(number_of_motorist_injured AS INT64) AS number_of_motorist_injured,
        CAST(number_of_motorist_killed AS INT64) AS number_of_motorist_killed,

        -- Contributing Factors & Vehicle Types
        contributing_factor_vehicle_1,
        contributing_factor_vehicle_2,
        vehicle_type_code1,
        vehicle_type_code2,

        -- Metadata
        CURRENT_TIMESTAMP() AS _stg_loaded_at

    FROM source

    WHERE collision_id IS NOT NULL
      AND crash_date IS NOT NULL
)

SELECT * FROM cleaned