#!/usr/bin/env bash
# Render a deterministic example instantiation of the template kit, so
# consumers can see "what does a real project actually look like once
# the placeholders are substituted" without invoking the full smoke
# test (which requires uv + Python + network for dep resolution).
#
# Spec: B-035 in docs/spec.md (v1.32.1).
#
# Substitution logic intentionally matches scripts/smoke-test.sh phase 3
# byte-for-byte — same canonical pattern (one mv for the package-dir
# rename, one sed across the same multi-extension file set). If the
# smoke-test substitution logic changes, this script changes in the same
# commit. The smoke test is the executable-and-tested reference; this
# script is the inspectable-by-humans companion.
#
# Output: OUT_DIR (default ~/Downloads/phoenixproject-example/). The
# directory is wiped + recreated on every run so reruns are clean.
# Override OUT_DIR via env: OUT_DIR=/tmp/foo ./scripts/render-example.sh
#
# Canonical substitution map (every B-024 canonical placeholder; values
# chosen to be unambiguous + obviously-example):
#   <PROJECT_NAME>         -> ExampleProject
#   <PROJECT_SLUG>         -> example-project
#   <PROJECT_DESCRIPTION>  -> An example project rendered from the kit.
#   <package_name>         -> exampleproj
#   <PACKAGE_NAME>         -> EXAMPLEPROJ
#   <GITHUB_USER>          -> example-org
#   <HOST>                 -> example.host
#   <DOMAIN>               -> example.com
#   <COPYRIGHT_HOLDER>     -> Example Org
#   <YEAR>                 -> $(date +%Y)

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${OUT_DIR:-$HOME/Downloads/phoenixproject-example}"

if [ ! -d "$ROOT/templates" ]; then
  echo "✗ $ROOT/templates not found" >&2
  exit 1
fi

echo "== render-example =="
echo "   source:  $ROOT/templates"
echo "   out:     $OUT_DIR"

rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR"

# Copy templates/ contents (not the directory itself) into OUT_DIR,
# matching the export-starter.sh archive layout (B-015).
cp -R "$ROOT/templates/." "$OUT_DIR/"

# Canonical substitution map. Each entry is "PATTERN|REPLACEMENT" where
# PATTERN is the full <NAME> form. YEAR resolves at runtime; everything
# else is a literal.
YEAR="$(date +%Y)"
SUBSTITUTIONS=(
  "<PROJECT_NAME>|ExampleProject"
  "<PROJECT_SLUG>|example-project"
  "<PROJECT_DESCRIPTION>|An example project rendered from the kit."
  "<PACKAGE_NAME>|EXAMPLEPROJ"
  "<GITHUB_USER>|example-org"
  "<HOST>|example.host"
  "<DOMAIN>|example.com"
  "<COPYRIGHT_HOLDER>|Example Org"
  "<YEAR>|$YEAR"
)

# <package_name> handled separately because the literal also appears in
# the src/ directory name (same pattern as smoke-test.sh phase 3 — mv
# first, sed second).
mv "$OUT_DIR/src/<package_name>" "$OUT_DIR/src/exampleproj"

# sed across the same multi-extension set smoke-test.sh phase 3 uses.
# Keeps the substitution-logic invariant per B-035.
find "$OUT_DIR" -type f \( -name '*.py' -o -name '*.toml' -o -name 'Makefile' -o -name '*.yml' -o -name '*.yaml' -o -name '*.sh' -o -name '*.example' \) -exec sed -i "s/<package_name>/exampleproj/g" {} +

# Apply the rest of the canonical substitution map across every text
# file in the rendered tree. Same multi-extension scope as the
# <package_name> pass — only files that participate in the consumer's
# substitution step get touched.
for entry in "${SUBSTITUTIONS[@]}"; do
  pattern="${entry%|*}"
  replacement="${entry#*|}"
  find "$OUT_DIR" -type f \( -name '*.md' -o -name '*.py' -o -name '*.toml' -o -name 'Makefile' -o -name '*.yml' -o -name '*.yaml' -o -name '*.sh' -o -name '*.example' -o -name 'LICENSE' \) -exec sed -i "s|${pattern}|${replacement}|g" {} +
done

# Count what we produced for the final summary.
FILE_COUNT=$(find "$OUT_DIR" -type f | wc -l)

echo
echo "✓ rendered ${FILE_COUNT} files into ${OUT_DIR}"
echo "  browse: ls -la ${OUT_DIR}"
echo "  diff vs templates: diff -r ${ROOT}/templates ${OUT_DIR}"
