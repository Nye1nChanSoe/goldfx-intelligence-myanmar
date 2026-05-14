# Myanmar Gold Market Intelligence Pipeline (MGM)

This project builds a small but realistic data engineering pipeline for tracking how global gold prices and foreign exchange rates interact with Myanmar’s official and unofficial "Hundi" market prices.

---

## Business Context

Myanmar has multiple price realities:

| Type            | Description                              |
| --------------- | ---------------------------------------- |
| Official FX     | CBM fixed USD/MMK rate                   |
| Unofficial FX   | Market / hundi USD-MMK buy-sell rate     |
| Global Gold     | XAU/USD from Gold API                    |
| Official Gold   | Government reference gold price          |
| Unofficial Gold | Local Myanmar market buy-sell gold price |

### Example Market Reference Prices

The project currently uses manually collected Myanmar market reference values because reliable real-time unofficial pricing sources are limited.

In `14-May-2026`

| Market Input                          |  Example Value |
| ------------------------------------- | -------------: |
| Official USD/MMK                      |      2,100 MMK |
| Unofficial USD/MMK Buy                |      4,150 MMK |
| Unofficial USD/MMK Sell               |      4,260 MMK |
| Official 16K Gold, 1 kyat-thar        |  7,100,000 MMK |
| Unofficial 16K Gold Buy, 1 kyat-thar  | 10,520,000 MMK |
| Unofficial 16K Gold Sell, 1 kyat-thar | 10,420,000 MMK |

Gold unit reference:

```txt
1 kyat-thar = 16.3293 grams
```

---

## Deployment

Run:

```bash
chmod +x scripts/*.sh
./scripts/00_bootstrap_all.sh
```

This will:

1. Enable APIs
2. Create buckets
3. Create service accounts
4. Create or update secrets
5. Grant IAM permissions
6. Build and deploy Cloud Run services
7. Create Cloud Scheduler jobs
8. Create Eventarc trigger
9. Create BigQuery resources

** Before deployment, update `scripts/00_set_env.sh` with your GCP project ID, region, bucket names, and service account names. **

---

## Current Data Sources

### Gold API

Fetches XAU/USD gold price and gold gram prices by purity.

Example output is stored in:

```txt
examples/bronze-gold-json.json
examples/silver-gold-parquet.json
```

### Exchange Rate API

Fetches official-style USD/THB and USD/MMK rates.

Example output is stored in:

```txt
examples/bronze-fx-json.json
examples/silver-fx-parquet.json
```

### Manual Myanmar Market Reference Inputs

Because reliable real-time Myanmar unofficial FX/gold scraping is difficult, the project currently uses manually seeded reference values.

Reference examples:

```txt
examples/mm-unofficial-fxrates-14-5-2026.jpeg
examples/mm-unofficial-goldprice-14-5-2026.jpeg
examples/unit-conversions.txt
examples/gold-purity-scale.txt
```

These values are stored in BigQuery:

```txt
mgm_reference.market_reference_inputs
```

---

## Architecture Overview

```txt
Gold API / FX API
        ↓
Cloud Scheduler
        ↓
Cloud Run ingestion services
        ↓
GCS Bronze Bucket: raw JSON
        ↓
Eventarc trigger
        ↓
Cloud Run silver transformer
        ↓
GCS Silver Bucket: Parquet
        ↓
BigQuery external tables
        ↓
BigQuery Gold tables
        ↓
Data Studio BI dashboard
```

---

## Data Layers

### Bronze Layer

The Bronze layer stores raw API responses as JSON.

Bucket:

```txt
gs://mgm-bronze-raw-json-data
```

Path format:

```txt
source=<source>/year=<yyyy>/month=<mm>/day=<dd>/<timestamp>.json
```

Sources:

```txt
source=goldapi_xau_usd
source=exchange_rate_api
```

Purpose:

- Keep raw API response unchanged
- Allow replay/debugging
- Preserve audit trail

---

### Silver Layer

The Silver layer stores cleaned and flattened Parquet files.

Bucket:

```txt
gs://mgm-silver-processed-data
```

Path format:

```txt
table=<table_name>/year=<yyyy>/month=<mm>/day=<dd>/<timestamp>.parquet
```

Silver tables:

```txt
table=gold_prices
table=fx_rates
```

BigQuery external tables:

```txt
mgm_silver.silver_gold_prices_ext
mgm_silver.silver_fx_rates_ext
```

Purpose:

- Convert raw JSON into structured analytics-friendly format
- Store as Parquet for efficient BigQuery external table reads
- Preserve Hive-style partitioning

---

### Reference Layer

The Reference layer stores manually maintained Myanmar market inputs.

Dataset:

```txt
mgm_reference
```

Table:

```txt
mgm_reference.market_reference_inputs
```

Purpose:

- Store official USD/MMK rate
- Store unofficial USD/MMK buy/sell rates
- Store official Myanmar gold price
- Store unofficial Myanmar gold buy/sell prices
- Store gold unit conversion values

This table is intentionally separated from Silver because these are manually curated market reference inputs, not scraped API data.

---

### Gold Layer

The Gold layer contains business-ready analytical tables.

Dataset:

```txt
mgm_gold
```

Tables:

```txt
mgm_gold.market_adjusted_gold_fx
mgm_gold.daily_market_summary
```

#### `market_adjusted_gold_fx`

Detailed analytical table.

Granularity:

```txt
one row per gold API snapshot
```

Purpose:

- Combine global gold prices with Myanmar reference rates
- Calculate implied Myanmar gold prices
- Calculate FX market premium
- Calculate official-vs-market gold premium
- Support detailed time-series charts

Example schema:

```txt
examples/mgm_gold.market_adjusted_gold_fx.json
```

#### `daily_market_summary`

Daily BI summary table.

Granularity:

```txt
one row per day per market
```

Purpose:

- Summarize daily global gold price
- Summarize Myanmar FX premium
- Summarize Myanmar gold premium
- Support Data Studio scorecards and daily charts

Example schema:

```txt
examples/mgm_gold.daily_market_summary.json
```

Comparison between both Gold tables:

```txt
examples/mgm_gold.diff_two_tables.json
```

---

## Cloud Services Used

| Service                    | Purpose                                                      |
| -------------------------- | ------------------------------------------------------------ |
| Cloud Run                  | Runs ingestion and transformation services                   |
| Cloud Scheduler            | Triggers gold and FX ingestion                               |
| Eventarc                   | Triggers silver transformation when bronze files are created |
| Cloud Storage              | Stores Bronze JSON and Silver Parquet                        |
| BigQuery                   | Hosts external, reference, and Gold analytics tables         |
| BigQuery Scheduled Queries | Rebuilds Gold tables automatically                           |
| Secret Manager             | Stores API keys                                              |
| Artifact Registry          | Stores Docker image                                          |
| Cloud Build                | Builds, deploys, and provisions resources                    |

---

## Cloud Run Services

### `mgm-ingest-gold`

Fetches Gold API data and writes raw JSON to Bronze.

Source file:

```txt
src/ingest_gold.py
```

### `mgm-ingest-fx`

Fetches FX API data and writes raw JSON to Bronze.

Source file:

```txt
src/ingest_fx.py
```

### `mgm-transform-silver`

Triggered by Eventarc when a new Bronze object is created.

Reads one Bronze JSON file, transforms it, and writes a Silver Parquet file.

Source file:

```txt
src/transform_silver.py
```

---

## Scripts

### Bootstrap

```txt
scripts/00_bootstrap_all.sh
```

Runs the full setup flow.

### Environment

```txt
scripts/00_set_env.sh
```

Stores project ID, region, bucket names, and service account names.

### API Enablement

```txt
scripts/01_enable_apis.sh
```

Enables required GCP services.

### Buckets

```txt
scripts/02_create_buckets.sh
```

Creates Bronze and Silver GCS buckets.

### Service Accounts

```txt
scripts/03_create_service_accounts.sh
```

Creates MGM service accounts.

### Secrets

```txt
scripts/04_create_secrets.sh
```

Creates or updates API keys in Secret Manager.

### IAM

```txt
scripts/05_grant_iam.sh
```

Grants required permissions for Cloud Run, Cloud Build, Scheduler, Eventarc, BigQuery, and GCS access.

### Scheduler

```txt
scripts/06_create_scheduler.sh
```

Creates ingestion scheduler jobs if needed.

### BigQuery Resources

```txt
scripts/07_create_bigquery_resources.sh
```

Creates datasets, external tables, reference table, seeds reference inputs, and builds Gold tables.

### Scheduled Queries

```txt
scripts/08_create_scheduled_queries.sh
```

Creates BigQuery scheduled queries for Gold table rebuilds.

---

## SQL Files

### `sql/01_create_datasets.sql`

Creates:

```txt
mgm_silver
mgm_reference
mgm_gold
```

### `sql/02_create_external_tables.sql`

Creates external tables over Silver Parquet files.

### `sql/03_create_reference_tables.sql`

Creates manual Myanmar market reference input table.

### `sql/04_seed_reference_inputs.sql`

Seeds or updates daily Myanmar market reference values.

### `sql/05_create_gold_tables.sql`

Creates Gold table schemas.

### `sql/06_build_market_adjusted_gold_fx.sql`

Builds the detailed Gold analytical table.

### `sql/07_build_daily_market_summary.sql`

Builds the daily Gold BI summary table.

---

## Manual Testing

Force-run ingestion:

```bash
gcloud scheduler jobs run mgm-ingest-gold-every-15m \
  --location=asia-southeast1 \
  --project=project-7abcab2d-24a7-4f5d-80a

gcloud scheduler jobs run mgm-ingest-fx-every-15m \
  --location=asia-southeast1 \
  --project=project-7abcab2d-24a7-4f5d-80a
```

Check Bronze:

```bash
gcloud storage ls -r gs://mgm-bronze-raw-json-data/**
```

Check Silver:

```bash
gcloud storage ls -r gs://mgm-silver-processed-data/**
```

Query Silver external table:

```sql
SELECT *
FROM `project-7abcab2d-24a7-4f5d-80a.mgm_silver.silver_gold_prices_ext`
LIMIT 10;
```

Query Gold table:

```sql
SELECT *
FROM `project-7abcab2d-24a7-4f5d-80a.mgm_gold.market_adjusted_gold_fx`
ORDER BY snapshot_timestamp DESC
LIMIT 20;
```

---

## BI Dashboard Direction

Recommended Data Studio tables:

| Dashboard Purpose    | Table                                   |
| -------------------- | --------------------------------------- |
| Daily scorecards     | `mgm_gold.daily_market_summary`         |
| Detailed time series | `mgm_gold.market_adjusted_gold_fx`      |
| Validation/debugging | `mgm_silver.silver_gold_prices_ext`     |
| Manual market inputs | `mgm_reference.market_reference_inputs` |

Suggested charts:

- XAU/USD price over time
- Official vs unofficial USD/MMK premium
- Official vs unofficial Myanmar gold premium
- Implied gold price using official vs unofficial FX
- Daily market summary scorecards

---

## Limitations

### Limited API Quotas

This project currently uses free-tier API access for gold and forex data. Because of that, ingestion frequency and historical data depth are limited by API quota, rate limits, and provider availability.

Current impact:

- Gold price ingestion may be limited by free-tier Gold API quotas.
- Forex ingestion may be limited by free-tier Exchange Rate API quotas.
- Higher-frequency ingestion may not be sustainable without upgrading API plans.
- Historical backfill may be limited or unavailable depending on API provider support.

### Limited Real-Time Myanmar Market Data

Reliable real-time unofficial Myanmar gold and forex market data is difficult to access programmatically.

Current impact:

- Unofficial USD/MMK buy-sell prices are manually maintained in `mgm_reference.market_reference_inputs`.
- Unofficial Myanmar gold prices are manually maintained instead of fully scraped in real time.
- Manual reference inputs may not perfectly represent the entire market.
- The Gold layer should be interpreted as market-adjusted analytics, not official financial advice or trading signals.

### Manual Reference Inputs

Because unofficial Myanmar market prices are not yet fully automated, the project depends on daily manual reference updates.

Current impact:

- `sql/04_seed_reference_inputs.sql` must be updated when new market reference values are available.
- The quality of Gold-layer analytics depends on the accuracy of manually entered reference data.
- Future improvement should include a more reliable scraping or data collection workflow for Myanmar unofficial FX and gold prices.

### Market Interpretation

Myanmar’s gold and FX markets are affected by policy controls, unofficial market behavior, liquidity differences, and local supply-demand conditions.

Current impact:

- Official rates and real market rates can diverge significantly.
- Implied gold prices are analytical estimates, not exact tradable prices.
- Gold premiums and FX premiums should be interpreted as market distortion indicators.

---

## Data Studio BI Dashboard Link

🔗 https://datastudio.google.com/reporting/1a2f31ff-c112-4ac3-bfba-ed753a70063a
