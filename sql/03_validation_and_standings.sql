-- Read-only validation of imported match data.
SELECT COUNT(*) AS total_matches, COUNT(DISTINCT match_id) AS unique_matches,
       COUNT_IF(match_status = 'RESULT_RECORDED') AS results_recorded,
       COUNT_IF(match_status = 'SCORE_REVIEW') AS scores_requiring_review,
       COUNT_IF(match_status = 'NO_RESULT') AS no_result,
       COUNT_IF(match_status <> 'RESULT_RECORDED'
                AND (home_goals IS NOT NULL OR away_goals IS NOT NULL)) AS unexpected_scores
FROM FOOTBALL_EFFICIENCY_LAB.RAW.CHAMPIONSHIP_MATCHES_RAW;

-- Read-only validation of team-match grain.
SELECT COUNT(*) AS total_rows, COUNT(DISTINCT match_id) AS unique_matches,
       COUNT_IF(venue = 'HOME') AS home_records,
       COUNT_IF(venue = 'AWAY') AS away_records,
       COUNT_IF(points NOT IN (0, 1, 3)) AS invalid_points
FROM FOOTBALL_EFFICIENCY_LAB.ANALYTICS.TEAM_MATCH_PERFORMANCE;

-- Exploratory standings, based only on recorded and structurally valid results.
-- NOT an official league table: seven ambiguous scores are excluded.
SELECT team_name, COUNT(*) AS played,
       COUNT_IF(points = 3) AS wins, COUNT_IF(points = 1) AS draws,
       COUNT_IF(points = 0) AS losses,
       SUM(goals_for) AS goals_for, SUM(goals_against) AS goals_against,
       SUM(goals_for - goals_against) AS goal_difference,
       SUM(points) AS total_points
FROM FOOTBALL_EFFICIENCY_LAB.ANALYTICS.TEAM_MATCH_PERFORMANCE
GROUP BY team_name
ORDER BY total_points DESC, goal_difference DESC, goals_for DESC, team_name;
