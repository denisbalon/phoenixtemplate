#!/usr/bin/env bash
# Export the project-starter kit (PROJECT_STARTER.md + companion docs +
# templates/) as a portable archive for transferring to another machine or
# seeding a fresh project per PROJECT_STARTER.md §1.3 ("quick path").
#
# Output (always): $OUT_DIR/project-starter-v<VERSION>-<YYYY-MM-DD>.tar.gz
# Output (if zip installed): $OUT_DIR/project-starter-v<VERSION>-<YYYY-MM-DD>.zip
#
# $OUT_DIR defaults to ~/Downloads (auto-created if missing); override by
# exporting OUT_DIR before invocation.
#
# The archive contains a top-level project-starter-v<VERSION>-<DATE>/
# directory holding PROJECT_STARTER.md + its companion split docs
# (TEMPLATE_INVENTORY.md, DEPLOY_BASELINE.md, HARNESS_QUIRKS.md as of
# v1.22.0; WORKFLOW.md and BOOTSTRAP.md as they ship in v1.22.1/v1.22.2)
# alongside the contents of templates/, so consumers can:
#   tar -xzf <archive> --strip-components=1
# directly into a new project root and all PROJECT_STARTER.md cross-links
# resolve in the extracted layout.
#
# Fails loud (set -euo pipefail) if PROJECT_STARTER.md or templates/ are
# missing, or if the host doesn't have tar. Missing companion docs are
# treated as fatal too (they're listed in ROOT_DOCS below).

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${OUT_DIR:-$HOME/Downloads}"

if [ ! -f "$ROOT/VERSION" ]; then
  echo "✗ $ROOT/VERSION not found." >&2
  exit 1
fi
# Meta-repo root docs that ship in the archive alongside templates/ contents.
# PROJECT_STARTER.md is the entry-point index; the others are its split
# companions (Codex Phase 4 #2 — see B-021/B-025 in docs/spec.md).
ROOT_DOCS=(
  "PROJECT_STARTER.md"
  "TEMPLATE_INVENTORY.md"
  "DEPLOY_BASELINE.md"
  "HARNESS_QUIRKS.md"
  "WORKFLOW.md"
)

for doc in "${ROOT_DOCS[@]}"; do
  if [ ! -f "$ROOT/$doc" ]; then
    echo "✗ $ROOT/$doc not found." >&2
    exit 1
  fi
done
if [ ! -d "$ROOT/templates" ]; then
  echo "✗ $ROOT/templates not found." >&2
  exit 1
fi

VERSION=$(cat "$ROOT/VERSION")
DATE=$(date +%F)  # YYYY-MM-DD
NAME="project-starter-v${VERSION}-${DATE}"

mkdir -p "$OUT_DIR"

# Stage in a tempdir under NAME so the archive's top-level directory
# matches NAME (consumers strip it with --strip-components=1).
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

STAGE_NAME="$STAGE/$NAME"
mkdir -p "$STAGE_NAME"

for doc in "${ROOT_DOCS[@]}"; do
  cp "$ROOT/$doc" "$STAGE_NAME/"
done
# Trailing /. promotes the *contents* of templates/ into $STAGE_NAME (instead
# of nesting templates/ as a subdir). This matches PROJECT_STARTER §1.3's
# quick-path flow where tar -xzf --strip-components=1 + chmod +x scripts/*.sh
# expects scripts/ at the project root, not under templates/.
cp -R "$ROOT/templates/." "$STAGE_NAME/"

# tar.gz (always)
TAR_OUT="$OUT_DIR/${NAME}.tar.gz"
( cd "$STAGE" && tar -czf "$TAR_OUT" "$NAME" )
SIZE=$(du -h "$TAR_OUT" | cut -f1)
echo "✓ wrote $TAR_OUT ($SIZE)"

# zip (optional — common to be missing on minimal Linux installs)
if command -v zip >/dev/null 2>&1; then
  ZIP_OUT="$OUT_DIR/${NAME}.zip"
  ( cd "$STAGE" && zip -qr "$ZIP_OUT" "$NAME" )
  SIZE=$(du -h "$ZIP_OUT" | cut -f1)
  echo "✓ wrote $ZIP_OUT ($SIZE)"
else
  echo "  (zip not installed — skipped .zip; tar.gz is sufficient on Linux/macOS)"
fi
