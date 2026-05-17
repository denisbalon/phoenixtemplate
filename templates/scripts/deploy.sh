#!/usr/bin/env bash
# Deploy <PROJECT_NAME> to <TARGET>.
# Prereqs: SSH key access to the target host, .env present locally, working tree clean (or pass --dirty).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOST="${DEPLOY_HOST:-root@<HOST>}"
REMOTE_DIR="${REMOTE_DIR:-<project-name>}"

if [ "${1:-}" != "--dirty" ] && git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1; then
  if ! git -C "$ROOT" diff --quiet --exit-code 2>/dev/null; then
    echo "✗ working tree dirty. Commit or pass --dirty to override." >&2
    exit 1
  fi
fi

echo "→ rsync src/ → $HOST:$REMOTE_DIR/"
rsync -av --delete \
  --exclude .venv --exclude __pycache__ --exclude '*.pyc' \
  --exclude .git --exclude .pytest_cache \
  "$ROOT/src/" "$HOST:$REMOTE_DIR/src/"

echo "→ rsync pyproject + lockfile"
rsync -av "$ROOT/pyproject.toml" "$ROOT/uv.lock" "$HOST:$REMOTE_DIR/" 2>/dev/null || \
  echo "  (lockfile not yet present — first deploy)"

echo "→ uv sync on remote"
ssh "$HOST" "cd $REMOTE_DIR && ~/.local/bin/uv sync --frozen"

# Migrations: enable when applicable
# echo "→ alembic upgrade head"
# ssh "$HOST" "cd $REMOTE_DIR && ~/.local/bin/uv run alembic upgrade head"

echo "→ restart service"
ssh "$HOST" 'systemctl restart <project-name>'

echo "→ healthcheck"
sleep 2
curl -fsS "${WEBHOOK_BASE_URL:-https://<DOMAIN>}/healthz" && echo
echo "✓ deploy complete"
