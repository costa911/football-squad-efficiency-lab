# Lab notebook 01 — Python → Snowflake → Power BI

**Session:** 28 October 2026  
**Status:** Working proof of concept; not a finished football analysis  
**Stack:** Python 3.12, Snowflake SQL, Power BI Desktop, Git  
**Source:** [OpenFootball](https://github.com/openfootball/football.json) match snapshot; **synthetic** player sample

## Analytical question

Can I build a repeatable, quality-checked football reporting pipeline, with documented transformations and an interactive self-service dashboard? The first iteration tests the technical chain and data grain, rather than drawing definitive football conclusions.

## Architecture

```text
Public football JSON ──> Python preparation ──> processed CSV ─┐
                                                               ├──> Snowflake RAW
Synthetic player CSV ───────────────────────────────────────────┘         │
                                                                        v
                                                                    STAGING
                                                                        │
                                                                        v
                                                                    ANALYTICS
                                                                        │
                                                                        v
                                                                 Power BI Desktop
```

## 1. Synthetic player prototype

Uploaded `data/synthetic/player_season_sample.csv` to Snowflake as `FOOTBALL_EFFICIENCY_LAB.RAW.PLAYER_SEASON_RAW`. The sample comprises 12 **fictional** players and is not evidence of real player performance.

The initial quality check returned 12 rows, 12 unique player IDs, zero missing IDs, and zero incorrectly labelled records. `sql/01_player_pipeline.sql` creates a curated staging table and player-efficiency analytics table.

Metrics: `full_match_equivalents = minutes / 90`; `goal_contributions_per_90 = (goals + assists) * 90 / minutes`. The SQL uses `NULLIF(minutes, 0)` to avoid divide-by-zero. The per-90 rate should not be summed across players; a minimum-minute threshold should be applied when ranking.

Connected Power BI Desktop to the Snowflake `ANALYTICS.PLAYER_EFFICIENCY` table (Import mode) and built a bar chart with team and minutes-range slicers. The `.pbix` remains **local-only** pending a metadata/privacy review.

## 2. Match-source inspection: a useful data-quality discovery

The OpenFootball Championship 2026/27 snapshot contains 552 fixture records. Inspecting nested `score` values revealed **different representations**:

| Source score shape | Number | Handling |
| --- | ---: | --- |
| Dictionary with a valid `ft` pair | 88 | `RESULT_RECORDED` (structurally valid, not independently verified) |
| Two-item list, e.g. `[0, 0]` | 7 | `SCORE_REVIEW` (ambiguous, not assumed to be a draw) |
| Missing score (`null`) | 457 | `NO_RESULT` (not necessarily confirmed unplayed) |

**Decision:** Do not silently turn ambiguous zero-zero lists into draws. Preserve all 552 fixtures; leave goals blank for ambiguous/missing results and retain explicit quality flags. This safeguards calculations from accidental false results.

`python scripts/prepare_matches.py` outputs `data/processed/championship_matches.csv` with flattened fields and status/quality columns. Match IDs are **snapshot-sequential** and are not stable identifiers across future source updates.

## 3. Snowflake transformations and grain

After uploading the processed CSV to `RAW.CHAMPIONSHIP_MATCHES_RAW`, `sql/02_match_pipeline.sql` prepares cleaned match fields and builds `ANALYTICS.TEAM_MATCH_PERFORMANCE`.

**Fact grain:** one **team per completed match**, achieved by `UNION ALL` of the home and away team perspectives. Each eligible fixture produces exactly two fact rows.

The pipeline filters to `RESULT_RECORDED` with `data_quality_flag = 'OK'`. Wins award 3 points, draws 1 and losses 0. A team-level `GROUP BY` then calculates played, wins, draws, losses, goals for/against, goal difference and points. See `sql/03_validation_and_standings.sql`.

## 4. Recorded validation evidence

| Test | Observed result |
| --- | ---: |
| Imported fixtures | 552 |
| Distinct match IDs | 552 |
| Recorded FT results | 88 |
| Scores needing review | 7 |
| No result recorded | 457 |
| Unexpected goals on non-result rows | 0 |
| Team-match fact rows | 176 |
| Unique matches in team fact | 88 |
| Home / away fact rows | 88 / 88 |
| Invalid league-points values | 0 |

The standings SQL returned 24 teams. These are **provisional calculations based on the source snapshot** and should not be presented as an official, independently checked 2026/27 table.

## 5. Decisions, limitations and next actions

- **Data provenance:** Verify the season, competition membership and results against a trustworthy source before drawing public football conclusions. The project is a learning demonstration until then.
- **Player metrics:** Synthetic players are for technology testing only; do not mix them with real data in purported real-world analysis.
- **Licensing:** Keep StrikerAPI extracts and credentials local; raw redistribution is restricted by provider terms. Keep the public GitHub dataset limited to material whose licence permits publication.
- **Costs:** Snowflake is a trial, not a permanent free backend. Keep X-Small/auto-suspend and plan a local reproducible option.
- **Version control:** Save the SQL (this update), then add repeatable tests. Review `.pbix` metadata before deciding how to share Power BI output.
- **Next technical milestone:** Create a durable standings model, import it to Power BI, and capture a safe screenshot for the README.

## Reproduce at a high level

1. Clone this repository and inspect the source/licensing notes in `README.md`.
2. Run `python scripts/prepare_matches.py` from the repo root (Python standard library only).
3. Create Snowflake database `FOOTBALL_EFFICIENCY_LAB` and schemas `RAW`, `STAGING`, `ANALYTICS`.
4. Use Snowflake's CSV uploader to create `RAW.PLAYER_SEASON_RAW` and `RAW.CHAMPIONSHIP_MATCHES_RAW` from the public/synthetic input files; confirm inferred types and null handling.
5. Run the SQL files in numerical order. Note: SQL files 01 and 02 use `CREATE OR REPLACE`; do not run them against a database containing tables you need to preserve.
6. In Power BI Desktop, connect to your own Snowflake server, warehouse and `ANALYTICS.PLAYER_EFFICIENCY` table. Do not share passwords or connection keys.

**Notebook lesson:** A readable result is not automatically a reliable result. Validate the source's shape, protect the intended data grain, and state clearly what the evidence does—and does not—establish.
