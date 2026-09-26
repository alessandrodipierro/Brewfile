#!/usr/bin/env python3
"""Salva l'arrangement iTerm2 'Work' via API Python."""
import asyncio
import os
import subprocess
import sys

import iterm2

ARRANGEMENT = "Work"


def get_cookie() -> str:
    """Richiede un cookie API a iTerm2 via osascript."""
    result = subprocess.run(
        ["/usr/bin/osascript", "-e", 'tell application "iTerm" to request cookie'],
        capture_output=True, text=True, check=False,
    )
    return result.stdout.strip()


async def main(connection):
    await iterm2.Arrangement.async_save(connection, ARRANGEMENT)


if __name__ == "__main__":
    cookie = get_cookie()
    if not cookie:
        print("ERROR: unable to obtain iTerm2 cookie", file=sys.stderr)
        sys.exit(1)
    os.environ["ITERM2_COOKIE"] = cookie
    iterm2.run_until_complete(main)
