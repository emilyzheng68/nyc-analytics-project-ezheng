-- Fact_Illegal_Parking_Complaint
WITH stg AS (
    SELECT * 
    FROM {{ ref('stg_nyc_311service_dot') }}        -- FIXED: Correct reference name
    WHERE complaint_type LIKE '%Illegal Parking%'
       OR complaint_type LIKE '%Parking%'
),

fact AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['unique_key']) }} AS complaint_fact_key,

        -- Foreign Keys
        {{ dbt_utils.generate_surrogate_key(['CAST(created_date AS DATE)']) }} AS date_created_key,
        {{ dbt_utils.generate_surrogate_key(['CAST(closed_date AS DATE)']) }} AS date_closed_key,
        {{ dbt_utils.generate_surrogate_key(['borough', 'incident_zip']) }} AS location_key,
        {{ dbt_utils.generate_surrogate_key(['complaint_type', 'descriptor']) }} AS complaint_type_key,
        {{ dbt_utils.generate_surrogate_key(['agency', 'agency_name']) }} AS agency_key,

        -- Measures
        1 AS complaint_count,
        TIMESTAMP_DIFF(closed_date, created_date, MINUTE) AS resolution_time_minutes,

        CURRENT_TIMESTAMP() AS _marts_loaded_at

    FROM stg
)

SELECT * FROM fact