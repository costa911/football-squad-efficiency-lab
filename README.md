# Football Squad Efficiency Lab

A hands-on football analytics project built alongside Codecademy.

## Project aim

Use West Ham United as the featured club and compare squad and team efficiency against English Championship benchmarks for the 2026/27 season.

The project will be developed locally first, then loaded into Snowflake and explored in Snowsight.

## Current status

- Public match-level source validated: OpenFootball `English Championship 2026/27`
- Local snapshot: `data/raw/championship-2026-27.json`
- Snapshot checked: 2026-10-27
- Matches in snapshot: 552
- Player-level data: not yet added; the first player dataset will be synthetic

## Source and licensing policy

The public pipeline currently uses [OpenFootball](https://github.com/openfootball/football.json), whose football database and datasets are dedicated to the public domain according to the project’s [licence statement](https://github.com/openfootball/openfootball.github.io/blob/master/index.md#license).

API-Football is not used in the public pipeline. Its terms state that it does not grant a publication licence for supplied data and that users are responsible for obtaining any required rights-holder permissions.

Until a clearly reusable player-statistics source is validated, player-level records in this repository will be synthetic and labelled as such.

## Planned data flow

```text
source snapshots -> raw -> staging -> fact/dimension model -> efficiency metrics -> Snowflake/Snowsight
```

Planned core entities:

- `dim_competition`
- `dim_team`
- `dim_player`
- `fact_match`
- `fact_player_match`
- `fact_player_season`

## Repository hygiene

API keys, passwords, tokens, private Snowflake details, and local environment files must never be committed.
