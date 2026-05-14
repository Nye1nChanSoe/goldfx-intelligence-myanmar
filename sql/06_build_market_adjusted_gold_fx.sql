-- main business intelligence table.
-- Silver gold API data + Manual Myanmar market reference data + Derived market distortion metrics

-- How different is official USD/MMK from real market USD/MMK?
-- How different is official Myanmar gold price from unofficial market gold price?
-- What should 1 kyat-thar of 16K gold approximately cost if we use global gold + unofficial FX?
-- Is Myanmar gold trading at a premium compared to global implied value?

CREATE OR REPLACE TABLE `project-7abcab2d-24a7-4f5d-80a.mgm_gold.market_adjusted_gold_fx`
PARTITION BY snapshot_date AS
WITH gold_clean AS (
  SELECT
    DATE(TIMESTAMP(ingested_at), 'Asia/Bangkok') AS snapshot_date,
    TIMESTAMP(ingested_at) AS snapshot_timestamp,

    symbol AS gold_symbol,
    metal AS gold_metal,
    currency AS gold_currency,

    price AS xau_usd_price,
    bid AS xau_usd_bid,
    ask AS xau_usd_ask,
    change AS xau_usd_change,
    change_percent AS xau_usd_change_percent,

    price_gram_16k AS xau_usd_price_gram_16k,
    price_gram_24k AS xau_usd_price_gram_24k

  FROM `project-7abcab2d-24a7-4f5d-80a.mgm_silver.silver_gold_prices_ext`
),

reference_clean AS (
  SELECT
    reference_date,
    market_name,

    official_usd_mmk_rate,

    unofficial_usd_mmk_buy_rate,
    unofficial_usd_mmk_sell_rate,
    (
      unofficial_usd_mmk_buy_rate + unofficial_usd_mmk_sell_rate
    ) / 2.0 AS unofficial_usd_mmk_mid_rate,

    official_gold_kyat_thar_16k_mmk,

    unofficial_gold_kyat_thar_16k_buy_mmk,
    unofficial_gold_kyat_thar_16k_sell_mmk,
    (
      unofficial_gold_kyat_thar_16k_buy_mmk + unofficial_gold_kyat_thar_16k_sell_mmk
    ) / 2.0 AS unofficial_gold_kyat_thar_16k_mid_mmk,

    gold_unit_name,
    gold_unit_grams,
    gold_karat,

    source_note,

    ROW_NUMBER() OVER (
      PARTITION BY reference_date, market_name
      ORDER BY created_at DESC
    ) AS rn

  FROM `project-7abcab2d-24a7-4f5d-80a.mgm_reference.market_reference_inputs`
)

SELECT
  g.snapshot_date,
  g.snapshot_timestamp,

  r.market_name,

  g.gold_symbol,
  g.gold_metal,
  g.gold_currency,

  g.xau_usd_price,
  g.xau_usd_bid,
  g.xau_usd_ask,
  g.xau_usd_change,
  g.xau_usd_change_percent,

  g.xau_usd_price_gram_16k,
  g.xau_usd_price_gram_24k,

  r.official_usd_mmk_rate,

  r.unofficial_usd_mmk_buy_rate,
  r.unofficial_usd_mmk_sell_rate,
  r.unofficial_usd_mmk_mid_rate,

  r.official_gold_kyat_thar_16k_mmk,

  r.unofficial_gold_kyat_thar_16k_buy_mmk,
  r.unofficial_gold_kyat_thar_16k_sell_mmk,
  r.unofficial_gold_kyat_thar_16k_mid_mmk,

  r.gold_unit_name,
  r.gold_unit_grams,
  r.gold_karat,

  g.xau_usd_price_gram_16k
    * r.gold_unit_grams
    * r.official_usd_mmk_rate
    AS implied_gold_kyat_thar_16k_official_mmk,

  g.xau_usd_price_gram_16k
    * r.gold_unit_grams
    * r.unofficial_usd_mmk_buy_rate
    AS implied_gold_kyat_thar_16k_unofficial_buy_mmk,

  g.xau_usd_price_gram_16k
    * r.gold_unit_grams
    * r.unofficial_usd_mmk_sell_rate
    AS implied_gold_kyat_thar_16k_unofficial_sell_mmk,

  g.xau_usd_price_gram_16k
    * r.gold_unit_grams
    * r.unofficial_usd_mmk_mid_rate
    AS implied_gold_kyat_thar_16k_unofficial_mid_mmk,

  SAFE_DIVIDE(
    r.unofficial_usd_mmk_buy_rate - r.official_usd_mmk_rate,
    r.official_usd_mmk_rate
  ) * 100.0 AS fx_market_premium_buy_pct,

  SAFE_DIVIDE(
    r.unofficial_usd_mmk_sell_rate - r.official_usd_mmk_rate,
    r.official_usd_mmk_rate
  ) * 100.0 AS fx_market_premium_sell_pct,

  SAFE_DIVIDE(
    r.unofficial_usd_mmk_mid_rate - r.official_usd_mmk_rate,
    r.official_usd_mmk_rate
  ) * 100.0 AS fx_market_premium_mid_pct,

  SAFE_DIVIDE(
    r.unofficial_gold_kyat_thar_16k_buy_mmk - r.official_gold_kyat_thar_16k_mmk,
    r.official_gold_kyat_thar_16k_mmk
  ) * 100.0 AS gold_official_to_market_buy_premium_pct,

  SAFE_DIVIDE(
    r.unofficial_gold_kyat_thar_16k_sell_mmk - r.official_gold_kyat_thar_16k_mmk,
    r.official_gold_kyat_thar_16k_mmk
  ) * 100.0 AS gold_official_to_market_sell_premium_pct,

  SAFE_DIVIDE(
    r.unofficial_gold_kyat_thar_16k_mid_mmk - r.official_gold_kyat_thar_16k_mmk,
    r.official_gold_kyat_thar_16k_mmk
  ) * 100.0 AS gold_official_to_market_mid_premium_pct,

  ABS(
    r.unofficial_gold_kyat_thar_16k_sell_mmk
    - r.unofficial_gold_kyat_thar_16k_buy_mmk
  ) AS gold_market_buy_sell_abs_spread_mmk,

  SAFE_DIVIDE(
    ABS(
      r.unofficial_gold_kyat_thar_16k_sell_mmk
      - r.unofficial_gold_kyat_thar_16k_buy_mmk
    ),
    r.unofficial_gold_kyat_thar_16k_mid_mmk
  ) * 100.0 AS gold_market_buy_sell_abs_spread_pct,

  r.source_note,
  CURRENT_TIMESTAMP() AS processed_at

FROM gold_clean g
JOIN reference_clean r
  ON g.snapshot_date = r.reference_date

WHERE r.rn = 1;