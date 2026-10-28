-- Match pipeline: OpenFootball snapshot, NOT independently validated official results.
-- Prerequisite: run scripts/prepare_matches.py and load its CSV to
-- FOOTBALL_EFFICIENCY_LAB.RAW.CHAMPIONSHIP_MATCHES_RAW via Snowflake UI.
-- CAUTION: CREATE OR REPLACE rebuilds the staging and analytics tables.

CREATE OR REPLACE TABLE FOOTBALL_EFFICIENCY_LAB.STAGING.CHAMPIONSHIP_MATCHES AS
SELECT match_id, competition,
       TRY_TO_NUMBER(REGEXP_SUBSTR(matchday, '[0-9]+')) AS matchday_number,
       match_date, kickoff_time, TRIM(home_team) AS home_team,
       TRIM(away_team) AS away_team, home_goals, away_goals,
       match_status, score_format, data_quality_flag
FROM FOOTBALL_EFFICIENCY_LAB.RAW.CHAMPIONSHIP_MATCHES_RAW;

-- Grain: one row per team per completed match. 88 eligible matches -> 176 rows.
CREATE OR REPLACE TABLE FOOTBALL_EFFICIENCY_LAB.ANALYTICS.TEAM_MATCH_PERFORMANCE AS
WITH valid_matches AS (
    SELECT * FROM FOOTBALL_EFFICIENCY_LAB.STAGING.CHAMPIONSHIP_MATCHES
    WHERE match_status = 'RESULT_RECORDED' AND data_quality_flag = 'OK'
)
SELECT match_id, match_date, matchday_number,
       home_team AS team_name, away_team AS opponent, 'HOME' AS venue,
       home_goals AS goals_for, away_goals AS goals_against,
       CASE WHEN home_goals > away_goals THEN 3
            WHEN home_goals = away_goals THEN 1 ELSE 0 END AS points
FROM valid_matches
UNION ALL
SELECT match_id, match_date, matchday_number,
       away_team AS team_name, home_team AS opponent, 'AWAY' AS venue,
       away_goals AS goals_for, home_goals AS goals_against,
       CASE WHEN away_goals > home_goals THEN 3
            WHEN away_goals = home_goals THEN 1 ELSE 0 END AS points
FROM valid_matches;
