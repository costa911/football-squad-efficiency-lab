#!/usr/bin/env python3
"""Fetch private Championship data from StrikerAPI.

The API key is read from STRIKER_API_KEY and is never written to disk.
Raw responses are saved below data/private/strikerapi/, which is ignored by Git.
"""

import argparse
import json
import os
import sys
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen


ROOT = Path(__file__).resolve().parents[1]
OUTPUT_DIR = ROOT / "data" / "private" / "strikerapi"
BASE_URL = "https://mcp.strikerapi.com/v1/championship"


def fetch(tool: str, payload: dict) -> dict:
    api_key = os.environ.get("STRIKER_API_KEY")
    if not api_key:
        raise RuntimeError("STRIKER_API_KEY is not set")

    request = Request(
        f"{BASE_URL}/{tool}",
        data=json.dumps(payload).encode("utf-8"),
        headers={
            "Content-Type": "application/json",
            "x-api-key": api_key,
        },
        method="POST",
    )

    with urlopen(request, timeout=30) as response:
        return json.load(response)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("resource", choices=("player", "game"))
    parser.add_argument("resource_id", help="StrikerAPI player_id or game_id")
    args = parser.parse_args()

    if args.resource == "player":
        tool = "get_player"
        payload = {"player_id": args.resource_id}
        filename = f"player_{args.resource_id}.json"
    else:
        tool = "get_game"
        payload = {"game_id": args.resource_id}
        filename = f"game_{args.resource_id}.json"

    try:
        result = fetch(tool, payload)
    except (HTTPError, URLError, TimeoutError, RuntimeError) as error:
        print(f"StrikerAPI request failed: {error}", file=sys.stderr)
        return 1

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    output_path = OUTPUT_DIR / filename
    output_path.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print(f"Saved private response to {output_path.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
