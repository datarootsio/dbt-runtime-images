import re
import sys
from pathlib import Path

def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: extract_release_notes.py <version>", file=sys.stderr)
        return 2

    version = sys.argv[1]
    changelog = Path("CHANGELOG.md")
    if not changelog.exists():
        print("ERROR: CHANGELOG.md not found", file=sys.stderr)
        return 1

    text = changelog.read_text(encoding="utf-8")

    pattern = rf"^## \[{re.escape(version)}\].*?$([\s\S]*?)(?=^## \[|\Z)"
    m = re.search(pattern, text, flags=re.MULTILINE)
    if not m:
        print(f"ERROR: Could not find changelog section for [{version}] in CHANGELOG.md", file=sys.stderr)
        return 1

    notes = m.group(0).strip() + "\n"
    Path("release_notes.md").write_text(notes, encoding="utf-8")
    print("Wrote release_notes.md")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
