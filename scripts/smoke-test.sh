#!/usr/bin/env bash
# Template self-test: prove the kit instantiates end-to-end and the resulting
# project's core tooling runs cleanly. CI invokes this script on every push
# and PR via .github/workflows/template-self-test.yml; you can also run it
# locally with the same script.
#
# Steps:
#   1. Run scripts/export-starter.sh against this repo (exercises the SAME
#      archive a consumer would receive — not a re-implementation).
#   2. Extract the archive into a temp project dir via the §1.3 quick-path
#      flow (tar -xzf --strip-components=1).
#   3. Substitute the <package_name> placeholder (mv the src/<package_name>
#      directory + sed across files that reference it). Other placeholders
#      like <PROJECT_NAME> stay literal — they don't affect tooling.
#   4. uv sync (generates uv.lock + installs deps).
#   5. uv run pytest.
#   6. uv run ruff check .
#   7. uv run mypy src
#
# Fails loud on any step. Cleans up tempdir on exit. Override the package
# name via PKG env var (default: smoketest).

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PKG="${PKG:-smoketest}"
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

echo "== template self-test =="
echo "   repo:    $ROOT"
echo "   workdir: $WORK"
echo "   package: $PKG"
echo

echo "-- 0. Pre-flight integrity checks (B-031, v1.29.3) --"

echo "   0a: .env.example parses cleanly via _env-schema-parse.sh"
(
  cd "$ROOT"
  export EXAMPLE="$ROOT/templates/.env.example"
  # shellcheck source=/dev/null
  source "$ROOT/templates/scripts/_env-schema-parse.sh"
  if [ "${#VARS[@]}" -eq 0 ]; then
    echo "   ✗ _env-schema-parse.sh sourced clean but VARS array is empty" >&2
    exit 1
  fi
  echo "      ✓ parsed ${#VARS[@]} vars from templates/.env.example"
)

echo "   0b: C4 trio regions all carry substantive content"
C4_REGIONS=(gate-clause proposal-format bare-gogogo env-metadata-contract)
C4_FILES=(WORKFLOW.md templates/CONTRIBUTING.md templates/CLAUDE.md)
MIN_CHARS=100  # non-blank char threshold per region per file
C4_FAIL=0
for region in "${C4_REGIONS[@]}"; do
  for f in "${C4_FILES[@]}"; do
    chars=$(awk -v start="<!-- C4:${region}:start -->" -v end="<!-- C4:${region}:end -->" '
      index($0, start) { capture = 1; next }
      index($0, end)   { capture = 0; next }
      capture          { gsub(/[[:space:]]/, ""); print }
    ' "$ROOT/$f" | wc -c)
    if [ "$chars" -lt "$MIN_CHARS" ]; then
      echo "   ✗ region '$region' in $f has only $chars non-blank chars (< $MIN_CHARS)" >&2
      C4_FAIL=1
    fi
  done
done
if [ "$C4_FAIL" -ne 0 ]; then
  echo "   ✗ pre-flight C4-content check failed" >&2
  exit 1
fi
echo "      ✓ all ${#C4_REGIONS[@]} C4 regions ≥ $MIN_CHARS non-blank chars across ${#C4_FILES[@]} trio files"

echo "   0c: manifest valid (orphans / stale / placeholder-match per B-033)"
( cd "$ROOT" && ./scripts/check-manifest.sh > /dev/null )
echo "      ✓ templates/manifest.yaml passes check-manifest.sh"

echo

echo "-- 1. Export starter --"
OUT_DIR="$WORK" "$ROOT/scripts/export-starter.sh"

ARCHIVE=$(ls "$WORK"/project-starter-*.tar.gz | head -1)
PROJECT_DIR="$WORK/project"
mkdir "$PROJECT_DIR"

echo "-- 2. Extract (--strip-components=1) --"
( cd "$PROJECT_DIR" && tar -xzf "$ARCHIVE" --strip-components=1 )

echo "-- 3. Substitute <package_name> -> $PKG --"
mv "$PROJECT_DIR/src/<package_name>" "$PROJECT_DIR/src/$PKG"
find "$PROJECT_DIR" -type f \( -name '*.py' -o -name '*.toml' -o -name 'Makefile' -o -name '*.yml' -o -name '*.yaml' -o -name '*.sh' -o -name '*.example' \) -exec sed -i "s/<package_name>/$PKG/g" {} +

echo "-- 4. uv sync --"
( cd "$PROJECT_DIR" && uv sync )

echo "-- 5. pytest --"
( cd "$PROJECT_DIR" && uv run pytest -v )

echo "-- 6. ruff check --"
( cd "$PROJECT_DIR" && uv run ruff check . )

echo "-- 7. mypy --"
( cd "$PROJECT_DIR" && uv run mypy src )

echo
echo "✓ template self-test passed: kit instantiates, all tooling green"
