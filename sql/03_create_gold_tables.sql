CREATE OR REPLACE TABLE `project-7abcab2d-24a7-4f5d-80a.mgm_gold.daily_gold_summary`
(
  summary_date DATE,
  metal STRING,
  currency STRING,

  avg_price FLOAT64,
  min_price FLOAT64,
  max_price FLOAT64,

  avg_price_gram_24k FLOAT64,
  avg_price_gram_22k FLOAT64,

  total_records INT64,
  processed_at TIMESTAMP
)
PARTITION BY summary_date;

CREATE OR REPLACE TABLE `project-7abcab2d-24a7-4f5d-80a.mgm_gold.daily_fx_summary`
(
  summary_date DATE,

  pair STRING,
  source_currency STRING,
  target_currency STRING,

  avg_rate FLOAT64,
  min_rate FLOAT64,
  max_rate FLOAT64,

  total_records INT64,
  processed_at TIMESTAMP
)
PARTITION BY summary_date;