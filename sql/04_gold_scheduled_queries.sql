INSERT INTO `project-7abcab2d-24a7-4f5d-80a.gold.daily_gold_summary`
(
  summary_date,
  metal,
  currency,

  avg_price,
  min_price,
  max_price,

  avg_price_gram_24k,
  avg_price_gram_22k,

  total_records,
  processed_at
)
SELECT
  DATE(TIMESTAMP_SECONDS(api_timestamp)) AS summary_date,
  metal,
  currency,

  AVG(price) AS avg_price,
  MIN(price) AS min_price,
  MAX(price) AS max_price,

  AVG(price_gram_24k) AS avg_price_gram_24k,
  AVG(price_gram_22k) AS avg_price_gram_22k,

  COUNT(*) AS total_records,
  CURRENT_TIMESTAMP() AS processed_at

FROM `project-7abcab2d-24a7-4f5d-80a.silver.silver_gold_prices_ext`

GROUP BY
  summary_date,
  metal,
  currency;



INSERT INTO `project-7abcab2d-24a7-4f5d-80a.gold.daily_fx_summary`
(
  summary_date,

  pair,
  source_currency,
  target_currency,

  avg_rate,
  min_rate,
  max_rate,

  total_records,
  processed_at
)
SELECT
  DATE(TIMESTAMP(api_time)) AS summary_date,

  pair,
  source_currency,
  target_currency,

  AVG(rate) AS avg_rate,
  MIN(rate) AS min_rate,
  MAX(rate) AS max_rate,

  COUNT(*) AS total_records,
  CURRENT_TIMESTAMP() AS processed_at

FROM `project-7abcab2d-24a7-4f5d-80a.silver.silver_fx_rates_ext`

GROUP BY
  summary_date,
  pair,
  source_currency,
  target_currency;