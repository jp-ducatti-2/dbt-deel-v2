{{
    config(
        materialized = 'incremental',
        incremental_strategy = 'merge',
        unique_key = 'external_ref'
    )
}}

WITH

payments AS (
    SELECT * FROM {{ref('int_payments_joined_chargeback')}}
),

acceptance_transactions AS (
    SELECT
        external_ref,
    
        sum(case when state = 'ACCEPTED' THEN 1 ELSE 0 END) OVER 
            (PARTITION BY transaction_date ORDER BY transaction_date ASC) AS acceptances_day,

        count(external_ref) OVER (PARTITION BY transaction_date ORDER BY transaction_date ASC) AS transactions_day,
    
        sum(case when state = 'ACCEPTED' THEN 1 ELSE 0 END) 
            OVER (ORDER BY transaction_date ASC) AS acceptances_cum,
    
        count(external_ref) OVER (ORDER BY transaction_date ASC) AS transactions_cum

    FROM payments

)

SELECT
    p.external_ref,
    p.ref,
    p.transaction_timestamp,
    p.transaction_date,
    p.state,
    p.is_cvv_provided,
    p.amount_usd,
    p.country,
    p.currency,
    p.amount_currency,
    p.is_chargeback,
    round(cast(a.acceptances_day as integer)/cast(a.transactions_day as integer),4) as acceptance_rate_day,
    round(cast(a.acceptances_cum as integer)/cast(a.transactions_cum as integer),4) as acceptance_rate_cum,  
    p.rate_aud,
    p.rate_cad,
    p.rate_eur,
    p.rate_gbp,
    p.rate_mxn,
    p.rate_sgd,
    p.rate_usd
FROM payments p
    LEFT JOIN acceptance_transactions a ON a.external_ref = p.external_ref

{% if is_incremental() %}

  WHERE transaction_date >= (SELECT max(transaction_date) FROM {{ this }})

{% endif %}
ORDER BY transaction_date asc