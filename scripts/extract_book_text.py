#!/usr/bin/env python3
"""
Extract book text from author.today via their API.

Usage:
    python3 extract_book_text.py --work-id 565614 --email YOU@example.com --password SECRET
    python3 extract_book_text.py --work-id 565614  # reads AT_EMAIL / AT_PASSWORD env vars

Output:
    book_<work_id>.txt  in the current directory
"""

import argparse
import os
import sys
import time
import re

try:
    import requests
except ImportError:
    sys.exit("Install requests first:  pip install requests")


BASE_URL = "https://api.author.today/v1"


def login(session: requests.Session, email: str, password: str) -> str:
    resp = session.post(
        f"{BASE_URL}/account/login-by-password",
        json={"login": email, "password": password},
    )
    if resp.status_code != 200:
        sys.exit(f"Login failed ({resp.status_code}): {resp.text}")
    data = resp.json()
    token = data.get("token") or data.get("accessToken") or data.get("auth_token")
    if not token:
        # Try nested
        for key in ("data", "result", "user"):
            if key in data and isinstance(data[key], dict):
                token = data[key].get("token") or data[key].get("accessToken")
                if token:
                    break
    if not token:
        sys.exit(f"Could not find token in login response. Keys: {list(data.keys())}\n{data}")
    print(f"[+] Logged in. Token starts with: {token[:8]}...")
    return token


def fetch_chapters(session: requests.Session, work_id: int) -> list[dict]:
    resp = session.get(f"{BASE_URL}/work/{work_id}/content")
    if resp.status_code != 200:
        sys.exit(f"Failed to fetch chapter list ({resp.status_code}): {resp.text}")
    data = resp.json()
    # Try common response shapes
    chapters = (
        data.get("chapters")
        or data.get("content")
        or (data if isinstance(data, list) else None)
    )
    if chapters is None:
        sys.exit(f"Could not find chapters in response. Keys: {list(data.keys())}\n{data}")
    print(f"[+] Found {len(chapters)} chapters.")
    return chapters


def fetch_chapter_text(session: requests.Session, work_id: int, chapter_id: int) -> str:
    resp = session.get(f"{BASE_URL}/work/{work_id}/chapter/{chapter_id}/text")
    if resp.status_code != 200:
        print(f"  [!] Chapter {chapter_id} returned {resp.status_code}, skipping.", file=sys.stderr)
        return ""
    data = resp.json()
    text = data.get("text") or data.get("content") or data.get("body") or ""
    if not text and isinstance(data, str):
        text = data
    return text


def strip_html(text: str) -> str:
    """Remove HTML tags and decode common entities."""
    text = re.sub(r"<br\s*/?>", "\n", text, flags=re.IGNORECASE)
    text = re.sub(r"<p[^>]*>", "\n", text, flags=re.IGNORECASE)
    text = re.sub(r"</p>", "\n", text, flags=re.IGNORECASE)
    text = re.sub(r"<[^>]+>", "", text)
    entities = {
        "&amp;": "&", "&lt;": "<", "&gt;": ">",
        "&quot;": '"', "&#39;": "'", "&nbsp;": " ",
        "&mdash;": "—", "&ndash;": "–", "&laquo;": "«",
        "&raquo;": "»", "&hellip;": "…",
    }
    for ent, char in entities.items():
        text = text.replace(ent, char)
    # Clean up excessive blank lines
    text = re.sub(r"\n{3,}", "\n\n", text)
    return text.strip()


def main():
    parser = argparse.ArgumentParser(description="Extract book text from author.today")
    parser.add_argument("--work-id", type=int, default=565614, help="Work ID (default: 565614)")
    parser.add_argument("--email", default=os.environ.get("AT_EMAIL"), help="author.today email (or AT_EMAIL env var)")
    parser.add_argument("--password", default=os.environ.get("AT_PASSWORD"), help="author.today password (or AT_PASSWORD env var)")
    parser.add_argument("--output", help="Output file path (default: book_<work_id>.txt)")
    parser.add_argument("--delay", type=float, default=0.3, help="Delay between chapter requests in seconds (default: 0.3)")
    args = parser.parse_args()

    if not args.email or not args.password:
        parser.error(
            "Provide credentials via --email/--password or AT_EMAIL/AT_PASSWORD env vars."
        )

    output_path = args.output or f"book_{args.work_id}.txt"

    session = requests.Session()
    session.headers.update({"User-Agent": "ATReader/1.0"})

    # Authenticate
    token = login(session, args.email, args.password)
    session.headers.update({"Authorization": f"Bearer {token}"})

    # Fetch chapter list
    chapters = fetch_chapters(session, args.work_id)

    # Sort by order if available
    chapters.sort(key=lambda c: c.get("order", c.get("sortOrder", 0)))

    # Fetch and write text
    with open(output_path, "w", encoding="utf-8") as f:
        for i, chapter in enumerate(chapters, 1):
            chapter_id = chapter.get("id")
            title = chapter.get("title") or f"Chapter {i}"
            print(f"  Fetching chapter {i}/{len(chapters)}: [{chapter_id}] {title}")

            text = fetch_chapter_text(session, args.work_id, chapter_id)
            if text:
                text = strip_html(text)

            f.write(f"\n{'='*60}\n")
            f.write(f"Глава {i}: {title}\n")
            f.write(f"{'='*60}\n\n")
            if text:
                f.write(text)
                f.write("\n")
            else:
                f.write("[Текст недоступен]\n")

            if args.delay > 0 and i < len(chapters):
                time.sleep(args.delay)

    print(f"\n[+] Done! Text saved to: {output_path}")


if __name__ == "__main__":
    main()
