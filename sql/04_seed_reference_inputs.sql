-- | Run time             | reference_date | market_name           | Result           |
-- | -------------------- | -------------: | --------------------- | ---------------- |
-- | First run today      |     2026-05-15 | myanmar_market_manual | Inserts 1 row    |
-- | Second run today     |     2026-05-15 | myanmar_market_manual | Updates same row |
-- | Tomorrow’s first run |     2026-05-16 | myanmar_market_manual | Inserts new row  |



-- update manually each day (Idempotent)
-- It creates at most one record per day per market name
-- merge condition prevents duplicates for the same
MERGE `project-7abcab2d-24a7-4f5d-80a.mgm_reference.market_reference_inputs` T
USING (
  SELECT
    CURRENT_DATE('Asia/Bangkok') AS reference_date,
    'myanmar_market_manual' AS market_name,

    2100.0 AS official_usd_mmk_rate,

    4150.0 AS unofficial_usd_mmk_buy_rate,
    4260.0 AS unofficial_usd_mmk_sell_rate,

    7100000.0 AS official_gold_kyat_thar_16k_mmk,

    10520000.0 AS unofficial_gold_kyat_thar_16k_buy_mmk,
    10420000.0 AS unofficial_gold_kyat_thar_16k_sell_mmk,

    'kyat_thar' AS gold_unit_name,
    16.3293 AS gold_unit_grams,
    '16K' AS gold_karat,

    'Manual Myanmar market reference input. USD/MMK official is CBM fixed rate. Unofficial FX and gold values are manually collected for project analytics.' AS source_note,
    CURRENT_TIMESTAMP() AS created_at
) S
ON
  T.reference_date = S.reference_date
  AND T.market_name = S.market_name

WHEN MATCHED THEN UPDATE SET
  official_usd_mmk_rate = S.official_usd_mmk_rate,

  unofficial_usd_mmk_buy_rate = S.unofficial_usd_mmk_buy_rate,
  unofficial_usd_mmk_sell_rate = S.unofficial_usd_mmk_sell_rate,

  official_gold_kyat_thar_16k_mmk = S.official_gold_kyat_thar_16k_mmk,

  unofficial_gold_kyat_thar_16k_buy_mmk = S.unofficial_gold_kyat_thar_16k_buy_mmk,
  unofficial_gold_kyat_thar_16k_sell_mmk = S.unofficial_gold_kyat_thar_16k_sell_mmk,

  gold_unit_name = S.gold_unit_name,
  gold_unit_grams = S.gold_unit_grams,
  gold_karat = S.gold_karat,

  source_note = S.source_note,
  created_at = S.created_at

WHEN NOT MATCHED THEN INSERT (
  reference_date,
  market_name,

  official_usd_mmk_rate,

  unofficial_usd_mmk_buy_rate,
  unofficial_usd_mmk_sell_rate,

  official_gold_kyat_thar_16k_mmk,

  unofficial_gold_kyat_thar_16k_buy_mmk,
  unofficial_gold_kyat_thar_16k_sell_mmk,

  gold_unit_name,
  gold_unit_grams,
  gold_karat,

  source_note,
  created_at
)
VALUES (
  S.reference_date,
  S.market_name,

  S.official_usd_mmk_rate,

  S.unofficial_usd_mmk_buy_rate,
  S.unofficial_usd_mmk_sell_rate,

  S.official_gold_kyat_thar_16k_mmk,

  S.unofficial_gold_kyat_thar_16k_buy_mmk,
  S.unofficial_gold_kyat_thar_16k_sell_mmk,

  S.gold_unit_name,
  S.gold_unit_grams,
  S.gold_karat,

  S.source_note,
  S.created_at
);