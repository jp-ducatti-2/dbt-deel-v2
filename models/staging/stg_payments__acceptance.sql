-- stg_payments__acceptance.sql

{{
    config(
        materialized = 'view'
    )
}}

with source_model AS (

{{ flatten_json(
    model_name= source('payments','acceptance'),
    json_column= 'rates'
)}}

),

treatment AS (
    SELECT 
        -- ids
        external_ref,
        ref,
        status,
        source,
        date_time,
        state,
        cvv_provided,
        amount AS amount_usd,
        country,
        currency,
        
        CASE
            WHEN currency = 'AUD' THEN round(amount*AUD,2)
            WHEN currency = 'CAD' THEN round(amount*CAD,2)
            WHEN currency = 'EUR' THEN round(amount*EUR,2)
            WHEN currency = 'GBP' THEN round(amount*GBP,2)
            WHEN currency = 'MXN' THEN round(amount*MXN,2)
            WHEN currency = 'SGD' THEN round(amount*SGD,2)
            WHEN currency = 'USD' THEN amount
        END AS amount_currency,

        AUD AS rate_aud,
        CAD AS rate_cad,
        EUR AS rate_eur,
        GBP AS rate_gbp,
        MXN AS rate_mxn,
        SGD AS rate_sgd,
        USD AS rate_usd

    FROM source_model
)

SELECT 
currency,
avg(amount_currency) 
FROM treatment
group by 1
order by avg(amount_currency) desc