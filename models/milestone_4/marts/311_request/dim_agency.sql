-- Dim_Agency (only used by Illegal Parking Fact)
WITH agencies AS (
    SELECT DISTINCT
        agency,
        agency_name
    FROM {{ ref('stg_nyc_311_dot') }}
    WHERE agency IS NOT NULL
),

dim_agency AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['agency', 'agency_name']) }} AS agency_key,
        agency,
        agency_name,
        CURRENT_TIMESTAMP() AS _marts_loaded_at
    FROM agencies
)

SELECT * FROM dim_agency