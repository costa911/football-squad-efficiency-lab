
import csv
import json
from collections import Counter
from datetime import date
from pathlib import Path

# Project folders
PROJECT_ROOT = Path(__file__).resolve().parent.parent
INPUT_FILE = PROJECT_ROOT / "data" / "raw" / "championship-2026-27.json"
OUTPUT_FILE = PROJECT_ROOT / "data" / "processed" / "championship_matches.csv"

COLUMNS = [
    "match_id",
    "competition",
    "matchday",
    "match_date",
    "kickoff_time",
    "home_team",
    "away_team",
    "home_goals",
    "away_goals",
    "match_status",
    "score_format",
    "data_quality_flag",
]


def prepare_match(match, competition, row_number):
    score = match.get("score")
    home_goals = None
    away_goals = None

    if score is None:
        status = "NO_RESULT"
        score_format = "missing"
        quality_flag = "MISSING_SCORE"

    elif isinstance(score, dict):
        score_format = "dictionary"
        full_time = score.get("ft")

        if (
            isinstance(full_time, list)
            and len(full_time) == 2
            and all(type(goal) is int and goal >= 0 for goal in full_time)
        ):
            home_goals, away_goals = full_time
            status = "RESULT_RECORDED"
            quality_flag = "OK"
        else:
            status = "SCORE_REVIEW"
            quality_flag = "INVALID_FULL_TIME_SCORE"

    elif isinstance(score, list):
        status = "SCORE_REVIEW"
        score_format = "list"
        quality_flag = "AMBIGUOUS_SCORE_FORMAT"

    else:
        status = "SCORE_REVIEW"
        score_format = type(score).__name__
        quality_flag = "UNKNOWN_SCORE_FORMAT"

    # A sequential ID for this particular source snapshot.
    # It is not a permanent match identifier across updates.
    return {
        "match_id": f"CH26-{row_number:04d}",
        "competition": competition,
        "matchday": match.get("round"),
        "match_date": match.get("date"),
        "kickoff_time": match.get("time"),
        "home_team": match.get("team1"),
        "away_team": match.get("team2"),
        "home_goals": home_goals,
        "away_goals": away_goals,
        "match_status": status,
        "score_format": score_format,
        "data_quality_flag": quality_flag,
    }


def main():
    with INPUT_FILE.open("r", encoding="utf-8") as file:
        source = json.load(file)

    matches = source["matches"]
    competition = source["name"]

    rows = [
        prepare_match(match, competition, index)
        for index, match in enumerate(matches, start=1)
    ]

    # Validate before writing the output.
    assert len(rows) == len(matches), "Match count changed"
    assert len({row["match_id"] for row in rows}) == len(rows), (
        "Duplicate match IDs detected"
    )

    counts = Counter(row["match_status"] for row in rows)

    OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)

    with OUTPUT_FILE.open("w", newline="", encoding="utf-8") as file:
        writer = csv.DictWriter(file, fieldnames=COLUMNS)
        writer.writeheader()
        writer.writerows(rows)

    print(f"Source matches: {len(matches)}")
    print(f"Results recorded: {counts['RESULT_RECORDED']}")
    print(f"Scores requiring review: {counts['SCORE_REVIEW']}")
    print(f"No result recorded: {counts['NO_RESULT']}")
    print(f"CSV created: {OUTPUT_FILE}")


if __name__ == "__main__":
    main()
