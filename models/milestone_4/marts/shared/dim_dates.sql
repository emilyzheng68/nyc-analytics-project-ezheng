-- Dim_Date: Shared date dimension
WITH all_dates AS (
    -- From Motor Vehicle Collisions
    SELECT DISTINCT CAST(crash_date AS DATE) AS full_date
    FROM {{ ref('stg_motor') }}
    WHERE crash_date IS NOT NULL

    UNION DISTINCT

    -- From 311 Service Requests
    SELECT DISTINCT CAST(created_date AS DATE) AS full_date
    FROM {{ ref('stg_nyc_311service_dot') }}
    WHERE created_date IS NOT NULL
),

dim_date AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['full_date']) }} AS date_key,
        
        full_date,
        EXTRACT(YEAR FROM full_date) AS year,
        EXTRACT(QUARTER FROM full_date) AS quarter,
        EXTRACT(MONTH FROM full_date) AS month,
        FORMAT_DATE('%B', full_date) AS month_name,
        EXTRACT(DAY FROM full_date) AS day,
        EXTRACT(DAYOFWEEK FROM full_date) AS day_of_week,
        FORMAT_DATE('%A', full_date) AS day_name,
        EXTRACT(DAYOFWEEK FROM full_date) IN (1, 7) AS is_weekend,

        CURRENT_TIMESTAMP() AS _marts_loaded_at
    FROM all_dates
)

SELECT * FROM dim_date