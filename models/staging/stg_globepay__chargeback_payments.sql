{{
    config(
        materialized = 'view'
    )
}}

WITH source_model AS (

    SELECT * FROM {{source('payments','chargeback')}}

)

SELECT 
    external_ref,
    chargeback AS is_chargeback
FROM source_model
    
