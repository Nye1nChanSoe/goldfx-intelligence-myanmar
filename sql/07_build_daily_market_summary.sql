-- daily BI summary table
-- aggregates the "market_adjusted_gold_fx" table into one row per day

-- What happened today overall?
-- What was the average global gold price?
-- How large was the Myanmar FX market premium today?
-- How large was the Myanmar gold market premium today?
-- How many data points were included today?

CREATE OR REPLACE TABLE `project-7abcab2d-24a7-4f5d-80a.mgm_gold.daily_market_summary`
PARTITION BY summary_date AS
SELECT
  snapshot_date AS summary_date,

  market_name,

  AVG(xau_usd_price) AS avg_xau_usd_price,
  MIN(xau_usd_price) AS min_xau_usd_price,
  MAX(xau_usd_price) AS max_xau_usd_price,

  ANY_VALUE(official_usd_mmk_rate) AS official_usd_mmk_rate,
  ANY_VALUE(unofficial_usd_mmk_buy_rate) AS unofficial_usd_mmk_buy_rate,
  ANY_VALUE(unofficial_usd_mmk_sell_rate) AS unofficial_usd_mmk_sell_rate,
  ANY_VALUE(unofficial_usd_mmk_mid_rate) AS unofficial_usd_mmk_mid_rate,

  ANY_VALUE(official_gold_kyat_thar_16k_mmk) AS official_gold_kyat_thar_16k_mmk,
  ANY_VALUE(unofficial_gold_kyat_thar_16k_buy_mmk) AS unofficial_gold_kyat_thar_16k_buy_mmk,
  ANY_VALUE(unofficial_gold_kyat_thar_16k_sell_mmk) AS unofficial_gold_kyat_thar_16k_sell_mmk,
  ANY_VALUE(unofficial_gold_kyat_thar_16k_mid_mmk) AS unofficial_gold_kyat_thar_16k_mid_mmk,

  AVG(implied_gold_kyat_thar_16k_official_mmk)
    AS avg_implied_gold_kyat_thar_16k_official_mmk,

  AVG(implied_gold_kyat_thar_16k_unofficial_mid_mmk)
    AS avg_implied_gold_kyat_thar_16k_unofficial_mid_mmk,

  AVG(fx_market_premium_mid_pct)
    AS avg_fx_market_premium_mid_pct,

  AVG(gold_official_to_market_mid_premium_pct)
    AS avg_gold_official_to_market_mid_premium_pct,

  AVG(gold_market_buy_sell_abs_spread_mmk)
    AS avg_gold_market_buy_sell_abs_spread_mmk,

  AVG(gold_market_buy_sell_abs_spread_pct)
    AS avg_gold_market_buy_sell_abs_spread_pct,

  COUNT(*) AS total_gold_records,
  CURRENT_TIMESTAMP() AS processed_at

FROM `project-7abcab2d-24a7-4f5d-80a.mgm_gold.market_adjusted_gold_fx`

GROUP BY
  summary_date,
  market_name;