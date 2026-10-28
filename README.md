# ⚽ Football Squad Efficiency Lab

**Python · SQL · Snowflake · Power BI · Data Quality · Football Analytics**

A hands-on football analytics portfolio project exploring squad productivity, player efficiency and team performance, with **West Ham United** as the featured club.

The project demonstrates how raw football data can be prepared, validated, transformed into analytical datasets and presented through interactive reporting.

## 🎯 Project aim

Compare squad and team efficiency against English Championship benchmarks for the 2026/27 season.

Beyond football analysis, the objective is to demonstrate a practical end-to-end analytics workflow:

- Python data preparation and automation
- SQL transformations and metric development
- Snowflake data warehousing
- Data-quality checks and exception handling
- Interactive reporting with Microsoft Power BI
- Reproducible documentation and transparent analytical decisions

## 🏗️ Data architecture

```text
Public match data           Synthetic player data
       |                            |
       v                            v
   Python ETL                  CSV import
       |                            |
       v                            v
          Snowflake RAW schema
                    |
                    v
          Snowflake STAGING schema
                    |
                    v
         Snowflake ANALYTICS schema
                    |
                    v
           Power BI / Snowsight
```

The project separates source data, cleaned datasets and reporting-ready analytical tables.

## ✅ Current progress — 28 October 2026

### 1. Python match-data pipeline

Developed `scripts/prepare_matches.py` to:

- Read a JSON match-data snapshot.
- Standardise match records into a consistent CSV structure.
- Identify missing, valid and ambiguous score formats.
- Preserve questionable records for review rather than inventing results.
- Generate an import-ready dataset.

Initial processing results:

| Data-quality category | Records |
|---|---:|
| Total match records | 552 |
| Results recorded in source | 88 |
| Ambiguous scores requiring review | 7 |
| No result recorded | 457 |

These categories describe the supplied source snapshot; they do not establish that the scores have been independently verified.

### 2. Snowflake data warehouse

Created a Snowflake learning environment using three schemas:

- `RAW` — imported source data.
- `STAGING` — cleaned and standardised records.
- `ANALYTICS` — reporting-ready datasets and calculated metrics.

Implemented SQL transformations covering player contribution rates and team match performance.

### 3. Player efficiency analysis

Using a clearly labelled **synthetic player dataset**, created analytical metrics including:

- Goals and assists
- Total goal contributions
- Full-match equivalents
- Goal contributions per 90 minutes

Used `NULLIF` to protect rate calculations against division by zero.

### 4. Team performance analysis

Transformed match-level records into team-level observations.

Each valid match contributes one home-team row and one away-team row, enabling analysis of:

- Games played
- Wins, draws and losses
- Goals for and against
- Goal difference
- League points

Verified that 88 source-recorded results generated 176 team-match observations, with no invalid points values.

### 5. Power BI reporting

Connected Power BI Desktop to the Snowflake analytical dataset and created an initial interactive player-efficiency report featuring:

- Player contribution rankings
- Team filtering
- Minutes-played filtering

The Power BI report is currently retained locally while connection details and publication suitability are reviewed.

## 📓 Technical walkthrough

**[Read the Snowflake + Power BI Analytics Lab walkthrough](docs/01-snowflake-powerbi-lab.md)**

The walkthrough documents the development process, SQL transformations, data validation, analytical decisions and lessons learned.

Supporting SQL scripts are available in the [`sql/`](sql/) directory.

## 📊 Data sources and licensing

**OpenFootball**

The public match-data pipeline uses [OpenFootball](https://github.com/openfootball/football.json), whose datasets are described by the project as dedicated to the public domain.

Original match snapshot: `data/raw/championship-2026-27.json`

Snapshot checked: 27 October 2026.

The supplied snapshot contains 552 match records. Match results and league standings derived from it should be treated as project outputs, **not independently verified official standings**.

**StrikerAPI**

StrikerAPI was explored as a source of Championship player and match statistics, including minutes, goals, assists, shots, xG, lineups and match events.

Its [terms](https://strikerapi.com/terms) restrict redistribution of raw data. API extracts therefore remain private under `data/private/strikerapi/` and are excluded from Git.

**Synthetic data**

The public player dataset, `data/synthetic/player_season_sample.csv`, is synthetic and is used to demonstrate modelling and reporting techniques without publishing restricted source material.

API-Football is not used in the public pipeline.

## 📁 Project structure

```text
football-squad-efficiency-lab/
├── data/
│   ├── raw/
│   ├── synthetic/
│   ├── processed/       # Generated locally
│   └── private/         # Excluded from Git
├── scripts/
│   └── prepare_matches.py
├── sql/
│   ├── 01_player_pipeline.sql
│   ├── 02_match_pipeline.sql
│   └── 03_validation_and_standings.sql
├── docs/
│   └── 01-snowflake-powerbi-lab.md
└── README.md
```

## 🔭 Next development stages

The next phase will extend the initial analytics prototype into a more complete football efficiency product.

Planned core entities:

- `dim_competition`
- `dim_team`
- `dim_player`
- `fact_match`
- `fact_player_match`
- `fact_player_season`

Further work will include a persistent league standings dataset, improved Power BI reporting, more extensive data-quality validation and additional squad-efficiency measures.

The current player analysis is synthetic; future comparisons using licensed real player data will be clearly distinguished from demonstration data.

## 🔐 Repository hygiene

No API keys, passwords, tokens, private API extracts, personal Snowflake connection settings or proprietary business datasets should be committed.

Power BI project files are kept local until reviewed for safe publication.

---

**Project status:** Active development — initial Python, Snowflake SQL and Power BI pipeline completed on 28 October 2026.