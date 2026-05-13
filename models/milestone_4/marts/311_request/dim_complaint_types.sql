-- Dim_Complaint_Type (Only for 311 / Illegal Parking)
WITH complaint_types AS (
    SELECT DISTINCT
        complaint_type,
        descriptor AS complaint_category
    FROM {{ ref('stg_nyc_311service_dot') }}        -- Make sure this matches your staging file name
    WHERE complaint_type IS NOT NULL
),

dim_complaint_type AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['complaint_type', 'complaint_category']) }} AS complaint_type_key,
        
        complaint_type AS complaint_type_name,
        complaint_category,
        
        CURRENT_TIMESTAMP() AS _marts_loaded_at
    FROM complaint_types
)

SELECT * FROM dim_complaint_type