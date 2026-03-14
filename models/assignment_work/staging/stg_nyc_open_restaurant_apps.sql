-- stg_nyc_open_restaurant_apps.sql
-- Clean and standardize NYC Open Restaurant Applications data
-- One row per restaurant application

WITH source AS (
    SELECT * FROM {{ source('raw', 'source_nyc_open_restaurant_apps') }}
),

cleaned AS (
    SELECT
        * EXCEPT (
            objectid,
            seating_interest_sidewalk,
            restaurant_name,
            legal_business_name,
            doing_business_as_dba,
            zip,
            food_service_establishment,
            approved_for_sidewalk_seating,
            approved_for_roadway_seating,
            qualify_alcohol,
            landmark_district_or_building,
            latitude,
            longitude,
            time_of_submission
        ),

        CAST(objectid AS STRING) AS restaurant_id,
        UPPER(TRIM(CAST(restaurant_name AS STRING))) AS restaurant_name,
        UPPER(TRIM(CAST(legal_business_name AS STRING))) AS legal_business_name,
        UPPER(TRIM(CAST(doing_business_as_dba AS STRING))) AS doing_business_as_dba,

        CASE
            WHEN LOWER(TRIM(seating_interest_sidewalk)) = 'sidewalk' THEN 'Sidewalk'
            WHEN LOWER(TRIM(seating_interest_sidewalk)) = 'roadway' THEN 'Roadway'
            WHEN LOWER(TRIM(seating_interest_sidewalk)) = 'both' THEN 'Both'
            WHEN LOWER(TRIM(seating_interest_sidewalk)) = 'openstreets' THEN 'Open Streets'
            ELSE 'Unknown'
        END AS seating_interest,

        CASE WHEN LOWER(TRIM(approved_for_sidewalk_seating)) = 'yes' THEN TRUE ELSE FALSE END AS approved_for_sidewalk_seating,
        CASE WHEN LOWER(TRIM(approved_for_roadway_seating)) = 'yes' THEN TRUE ELSE FALSE END AS approved_for_roadway_seating,
        CASE WHEN LOWER(TRIM(qualify_alcohol)) = 'yes' THEN TRUE ELSE FALSE END AS qualifies_for_alcohol,
        CASE WHEN LOWER(TRIM(landmark_district_or_building)) = 'yes' THEN TRUE ELSE FALSE END AS is_landmark,

        CASE
            WHEN TRIM(CAST(zip AS STRING)) IS NULL THEN NULL
            WHEN UPPER(TRIM(CAST(zip AS STRING))) IN ('N/A', 'NA', '') THEN NULL
            WHEN LENGTH(TRIM(CAST(zip AS STRING))) = 5 THEN TRIM(CAST(zip AS STRING))
            WHEN LENGTH(TRIM(CAST(zip AS STRING))) = 4
                AND REGEXP_CONTAINS(TRIM(CAST(zip AS STRING)), r'^\d{4}$')
            THEN CONCAT('0', TRIM(CAST(zip AS STRING)))
            ELSE NULL
        END AS zip,

        CAST(food_service_establishment AS STRING) AS food_service_permit,
        CAST(latitude AS DECIMAL) AS latitude,
        CAST(longitude AS DECIMAL) AS longitude,
        CAST(time_of_submission AS TIMESTAMP) AS submitted_at,

        ROW_NUMBER() OVER (
            PARTITION BY objectid
            ORDER BY time_of_submission DESC
        ) AS row_num,

        CURRENT_TIMESTAMP() AS _stg_loaded_at

    FROM source
    WHERE objectid IS NOT NULL
),

deduped AS (
    SELECT * EXCEPT (row_num)
    FROM cleaned
    WHERE row_num = 1
)

SELECT * FROM deduped
