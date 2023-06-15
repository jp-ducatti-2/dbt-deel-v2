{{
    config(
        materialized = 'view'
    )
}}

SELECT 
    *
FROM 
    {{source('payments','chargeback')}}
