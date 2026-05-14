CREATE OR REPLACE EXTERNAL TABLE `project-7abcab2d-24a7-4f5d-80a.mgm_silver.silver_gold_prices_ext`
WITH PARTITION COLUMNS (
  year INT64,
  month INT64,
  day INT64
)
OPTIONS (
  format = 'PARQUET',
  uris = [
    'gs://mgm-silver-processed-data/table=gold_prices/*'
  ],
  hive_partition_uri_prefix = 'gs://mgm-silver-processed-data/table=gold_prices/',
  require_hive_partition_filter = TRUE
);

CREATE OR REPLACE EXTERNAL TABLE `project-7abcab2d-24a7-4f5d-80a.mgm_silver.silver_fx_rates_ext`
WITH PARTITION COLUMNS (
  year INT64,
  month INT64,
  day INT64
)
OPTIONS (
  format = 'PARQUET',
  uris = [
    'gs://mgm-silver-processed-data/table=fx_rates/*'
  ],
  hive_partition_uri_prefix = 'gs://mgm-silver-processed-data/table=fx_rates/',
  require_hive_partition_filter = TRUE
);