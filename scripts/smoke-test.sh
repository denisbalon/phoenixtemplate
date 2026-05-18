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
