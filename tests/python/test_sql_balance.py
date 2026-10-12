"""Static balance checks for the repository's SQL files.

Validates, without needing a live database:
  * block comments are balanced and terminated,
  * single-quoted string literals are terminated,
  * parentheses balance once comments/strings are stripped,
  * no SQA audit annotations leak into the SQL sources.

Run from anywhere:  python tests/python/test_sql_balance.py
Exit code 0 = all files pass.
"""

import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
# Third-party demo data and generated dirs are imported as-is, not audited.
SKIP_PARTS = {"pagila-master", ".git", "docs", "Online_retail"}


def iter_sql_files():
    for path in sorted(REPO_ROOT.rglob("*.sql")):
        if SKIP_PARTS.intersection(path.parts):
            continue
        yield path


def check(path: Path) -> list[str]:
    problems = []
    text = path.read_text(encoding="utf-8", errors="replace")
    parens = 0
    in_line = in_block = in_str = False
    i = 0
    n = len(text)
    while i < n:
        ch = text[i]
        nxt = text[i + 1] if i + 1 < n else ""
        if in_line:
            if ch == "\n":
                in_line = False
        elif in_block:
            if ch == "*" and nxt == "/":
                in_block = False
                i += 1
        elif in_str:
            if ch == "'":
                if nxt == "'":  # escaped quote inside a string literal
                    i += 1
                else:
                    in_str = False
        else:
            if ch == "-" and nxt == "-":
                in_line = True
                i += 1
            elif ch == "/" and nxt == "*":
                in_block = True
                i += 1
            elif ch == "'":
                in_str = True
            elif ch == "(":
                parens += 1
            elif ch == ")":
                parens -= 1
                if parens < 0:
                    problems.append("unbalanced ')' encountered")
                    parens = 0
        i += 1
    if in_block:
        problems.append("unterminated block comment")
    if in_str:
        problems.append("unterminated string literal")
    if parens != 0:
        problems.append(f"paren imbalance: {parens:+d}")
    if "SQA" in text:
        problems.append("residual SQA audit annotation")
    return problems


def main() -> int:
    failed = 0
    total = 0
    for path in iter_sql_files():
        total += 1
        problems = check(path)
        rel = path.relative_to(REPO_ROOT)
        if problems:
            failed += 1
            print(f"FAIL {rel}: {'; '.join(problems)}")
        else:
            print(f"OK   {rel}")
    print(f"\n{total - failed}/{total} SQL files passed")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
