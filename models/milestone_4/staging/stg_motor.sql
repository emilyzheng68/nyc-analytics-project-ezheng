-- Staging: Motor Vehicle Collisions (Last 5 Years)
WITH source AS (
    SELECT * 
    FROM {{ source('raw', 'motorvehicle_collisions_crashes') }}
),

cleaned AS (
    SELECT
        CAST(collision_id AS STRING) AS collision_id,

        -- Fix date handling
        PARSE_DATE('%Y-%m-%d', crash_date) AS crash_date,                    -- Convert string to DATE
        PARSE_TIME('%H:%M', crash_time) AS crash_time,
        TIMESTAMP(PARSE_DATE('%Y-%m-%d', crash_date), PARSE_TIME('%H:%M', crash_time)) AS crash_datetime,

        borough,
        zip_code,
        CAST(latitude AS FLOAT64) AS latitude,
        CAST(longitude AS FLOAT64) AS longitude,

        CAST(number_of_persons_injured AS INT64) AS number_of_persons_injured,
        CAST(number_of_persons_killed AS INT64) AS number_of_persons_killed,
        CAST(number_of_pedestrians_injured AS INT64) AS number_of_pedestrians_injured,
        CAST(number_of_pedestrians_killed AS INT64) AS number_of_pedestrians_killed,
        CAST(number_of_cyclist_injured AS INT64) AS number_of_cyclist_injured,
        CAST(number_of_cyclist_killed AS INT64) AS number_of_cyclist_killed,
        CAST(number_of_motorist_injured AS INT64) AS number_of_motorist_injured,
        CAST(number_of_motorist_killed AS INT64) AS number_of_motorist_killed,

        contributing_factor_vehicle_1,
        contributing_factor_vehicle_2,
        vehicle_type_code1,
        vehicle_type_code2,

        CURRENT_TIMESTAMP() AS _stg_loaded_at

    FROM source

    WHERE collision_id IS NOT NULL
      AND crash_date IS NOT NULL
      -- Filter to last 5 years (after converting to DATE)
      AND PARSE_DATE('%Y-%m-%d', crash_date) >= DATE_SUB(CURRENT_DATE(), INTERVAL 5 YEAR)
)

SELECT * FROM cleaned