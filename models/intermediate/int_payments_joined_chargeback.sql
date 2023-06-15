{{
    config(
        materialized = 'ephemeral'
    )
}}

WITH 

acceptance_payments AS (

    SELECT * FROM {{ref('stg_globepay__acceptance_payments')}}

),

chargeback_payments AS (

    SELECT * FROM {{ref('stg_globepay__chargeback_payments')}}

),

joined_chargeback AS (

    SELECT
        a.external_ref,
        a.ref,
        a.transaction_timestamp,
        a.transaction_date,
        a.state,
        a.is_cvv_provided,
        a.amount_usd,
        a.country,
        a.currency,
        a.amount_currency,
        c.is_chargeback,
        a.rate_aud,
        a.rate_cad,
        a.rate_eur,
        a.rate_gbp,
        a.rate_mxn,
        a.rate_sgd,
        a.rate_usd
    FROM acceptance_payments a
        LEFT JOIN chargeback_payments c ON c.external_ref = a.external_ref

)

SELECT * FROM joined_chargeback
