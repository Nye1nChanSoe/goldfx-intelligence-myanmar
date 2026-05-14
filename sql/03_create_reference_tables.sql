CREATE TABLE IF NOT EXISTS `project-7abcab2d-24a7-4f5d-80a.mgm_reference.market_reference_inputs`
(
  reference_date DATE NOT NULL,
  market_name STRING NOT NULL,

  official_usd_mmk_rate FLOAT64 NOT NULL,

  unofficial_usd_mmk_buy_rate FLOAT64 NOT NULL,
  unofficial_usd_mmk_sell_rate FLOAT64 NOT NULL,

  official_gold_kyat_thar_16k_mmk FLOAT64 NOT NULL,

  unofficial_gold_kyat_thar_16k_buy_mmk FLOAT64 NOT NULL,
  unofficial_gold_kyat_thar_16k_sell_mmk FLOAT64 NOT NULL,

  gold_unit_name STRING NOT NULL,
  gold_unit_grams FLOAT64 NOT NULL,
  gold_karat STRING NOT NULL,

  source_note STRING,
  created_at TIMESTAMP NOT NULL
);