-- Dim_Location: Shared location dimension
WITH all_locations AS (
    SELECT DISTINCT
        borough,
        zip_code,
        latitude,
        longitude
    FROM {{ ref('stg_motor') }}
    WHERE borough IS NOT NULL

    UNION DISTINCT

    SELECT DISTINCT
        borough,
        incident_zip AS zip_code,
        latitude,
        longitude
    FROM {{ ref('stg_nyc_311service_dot') }}
    WHERE borough IS NOT NULL
),

dim_location AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['borough', 'zip_code']) }} AS location_key,
        borough,
        zip_code,
        CAST(latitude AS FLOAT64) AS latitude,
        CAST(longitude AS FLOAT64) AS longitude,
        CURRENT_TIMESTAMP() AS _marts_loaded_at
    FROM all_locations
)

SELECT * FROM dim_location