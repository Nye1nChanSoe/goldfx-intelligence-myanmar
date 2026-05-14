CREATE TABLE IF NOT EXISTS `project-7abcab2d-24a7-4f5d-80a.mgm_gold.market_adjusted_gold_fx`
(
  snapshot_date DATE NOT NULL,
  snapshot_timestamp TIMESTAMP NOT NULL,

  market_name STRING NOT NULL,

  gold_symbol STRING,
  gold_metal STRING,
  gold_currency STRING,

  xau_usd_price FLOAT64,
  xau_usd_bid FLOAT64,
  xau_usd_ask FLOAT64,
  xau_usd_change FLOAT64,
  xau_usd_change_percent FLOAT64,

  xau_usd_price_gram_16k FLOAT64,
  xau_usd_price_gram_24k FLOAT64,

  official_usd_mmk_rate FLOAT64,

  unofficial_usd_mmk_buy_rate FLOAT64,
  unofficial_usd_mmk_sell_rate FLOAT64,
  unofficial_usd_mmk_mid_rate FLOAT64,

  official_gold_kyat_thar_16k_mmk FLOAT64,

  unofficial_gold_kyat_thar_16k_buy_mmk FLOAT64,
  unofficial_gold_kyat_thar_16k_sell_mmk FLOAT64,
  unofficial_gold_kyat_thar_16k_mid_mmk FLOAT64,

  gold_unit_name STRING,
  gold_unit_grams FLOAT64,
  gold_karat STRING,

  implied_gold_kyat_thar_16k_official_mmk FLOAT64,
  implied_gold_kyat_thar_16k_unofficial_buy_mmk FLOAT64,
  implied_gold_kyat_thar_16k_unofficial_sell_mmk FLOAT64,
  implied_gold_kyat_thar_16k_unofficial_mid_mmk FLOAT64,

  fx_market_premium_buy_pct FLOAT64,
  fx_market_premium_sell_pct FLOAT64,
  fx_market_premium_mid_pct FLOAT64,

  gold_official_to_market_buy_premium_pct FLOAT64,
  gold_official_to_market_sell_premium_pct FLOAT64,
  gold_official_to_market_mid_premium_pct FLOAT64,

  gold_market_buy_sell_abs_spread_mmk FLOAT64,
  gold_market_buy_sell_abs_spread_pct FLOAT64,

  source_note STRING,
  processed_at TIMESTAMP NOT NULL
)
PARTITION BY snapshot_date;


-- analytical answers
CREATE TABLE IF NOT EXISTS `project-7abcab2d-24a7-4f5d-80a.mgm_gold.daily_market_summary`
(
  summary_date DATE NOT NULL,

  market_name STRING NOT NULL,

  avg_xau_usd_price FLOAT64,
  min_xau_usd_price FLOAT64,
  max_xau_usd_price FLOAT64,

  official_usd_mmk_rate FLOAT64,
  unofficial_usd_mmk_buy_rate FLOAT64,
  unofficial_usd_mmk_sell_rate FLOAT64,
  unofficial_usd_mmk_mid_rate FLOAT64,

  official_gold_kyat_thar_16k_mmk FLOAT64,
  unofficial_gold_kyat_thar_16k_buy_mmk FLOAT64,
  unofficial_gold_kyat_thar_16k_sell_mmk FLOAT64,
  unofficial_gold_kyat_thar_16k_mid_mmk FLOAT64,

  avg_implied_gold_kyat_thar_16k_official_mmk FLOAT64,
  avg_implied_gold_kyat_thar_16k_unofficial_mid_mmk FLOAT64,

  avg_fx_market_premium_mid_pct FLOAT64,
  avg_gold_official_to_market_mid_premium_pct FLOAT64,

  avg_gold_market_buy_sell_abs_spread_mmk FLOAT64,
  avg_gold_market_buy_sell_abs_spread_pct FLOAT64,

  total_gold_records INT64,
  processed_at TIMESTAMP NOT NULL
)
PARTITION BY summary_date;