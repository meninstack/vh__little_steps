"""Downloads the Twemoji artwork listed in tool/asset_map.json.

asset_map.json maps each card, routine icon and sticker id to the code point
of the emoji that draws it. This script copies the matching SVG into
assets/cards/, assets/icons/ or assets/stickers/ under the app's own id.
Files that already exist are left alone, so it only fetches what is new.

The artwork is Twemoji (CC-BY 4.0), taken unmodified from the npm package
pinned below.

Usage:
    python tool/fetch_twemoji.py
"""

import json
import sys
import urllib.request
from pathlib import Path

SOURCE = "https://cdn.jsdelivr.net/npm/@twemoji/svg@15.0.0/{code}.svg"

ROOT = Path(__file__).resolve().parent.parent


def main():
    asset_map = json.loads((ROOT / "tool" / "asset_map.json").read_text("utf-8"))
    fetched = 0
    for folder, entries in asset_map.items():
        for asset_id, code in entries.items():
            target = ROOT / "assets" / folder / f"{asset_id}.svg"
            if target.exists():
                continue
            with urllib.request.urlopen(SOURCE.format(code=code)) as response:
                data = response.read()
            if not data.startswith(b"<svg"):
                sys.exit(f"{asset_id} ({code}): the download is not an SVG")
            target.write_bytes(data)
            fetched += 1
            print(f"{target.relative_to(ROOT)}  <- {code}")
    print(f"{fetched} file(s) fetched")


if __name__ == "__main__":
    main()
