-- Football Squad Efficiency Lab: synthetic player proof of concept
-- Requires data/synthetic/player_season_sample.csv to have been loaded to RAW.PLAYER_SEASON_RAW.
-- All player records are synthetic, NOT observed performance.

CREATE SCHEMA IF NOT EXISTS FOOTBALL_EFFICIENCY_LAB.STAGING;
CREATE SCHEMA IF NOT EXISTS FOOTBALL_EFFICIENCY_LAB.ANALYTICS;

CREATE OR REPLACE TABLE FOOTBALL_EFFICIENCY_LAB.STAGING.PLAYER_SEASON AS
SELECT player_id, player_name, team_name, competition, season, position,
       age, minutes, starts, appearances, goals, assists, shots, key_passes,
       tackles_won, interceptions, progressive_carries,
       errors_leading_to_shot, availability_days, data_status
FROM FOOTBALL_EFFICIENCY_LAB.RAW.PLAYER_SEASON_RAW
WHERE data_status = 'synthetic';

CREATE OR REPLACE TABLE FOOTBALL_EFFICIENCY_LAB.ANALYTICS.PLAYER_EFFICIENCY AS
SELECT player_id, player_name, team_name, position, season, minutes,
       appearances, goals, assists, goals + assists AS goal_contributions,
       ROUND(minutes / 90.0, 2) AS full_match_equivalents,
       ROUND((goals + assists) * 90.0 / NULLIF(minutes, 0), 2)
           AS goal_contributions_per_90,
       data_status
FROM FOOTBALL_EFFICIENCY_LAB.STAGING.PLAYER_SEASON;

-- Quality checks: expected 12 rows, 12 unique players, 0 missing IDs, 0 non-synthetic.
SELECT COUNT(*) AS total_rows, COUNT(DISTINCT player_id) AS unique_players,
       COUNT_IF(player_id IS NULL) AS missing_player_ids,
       COUNT_IF(data_status <> 'synthetic' OR data_status IS NULL) AS not_synthetic
FROM FOOTBALL_EFFICIENCY_LAB.RAW.PLAYER_SEASON_RAW;
