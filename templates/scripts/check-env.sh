#!/usr/bin/env bash
# Verify .env contains every required var declared in .env.example.
# Required = any var whose preceding comment block does NOT contain "Optional".
# Exit 0 = complete. Exit 1 = incomplete. Exit 2 = setup error (missing .env.example).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXAMPLE="$ROOT/.env.example"
ENV_FILE="$ROOT/.env"

if [ ! -f "$EXAMPLE" ]; then
  echo "FATAL: $EXAMPLE not found." >&2
  exit 2
fi

required=()
optional=()
current_comment=""
while IFS= read -r line || [ -n "$line" ]; do
  if [[ "$line" =~ ^[[:space:]]*# ]] || [[ -z "${line// }" ]]; then
    current_comment+="$line"$'\n'
    continue
  fi
  if [[ "$line" =~ ^([A-Z_][A-Z0-9_]*)= ]]; then
    var="${BASH_REMATCH[1]}"
    if echo "$current_comment" | grep -qi 'Optional'; then
      optional+=("$var")
    else
      required+=("$var")
    fi
  fi
  current_comment=""
done < "$EXAMPLE"

declare -A actual=()
if [ -f "$ENV_FILE" ]; then
  while IFS= read -r line || [ -n "$line" ]; do
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${line// }" ]] && continue
    if [[ "$line" =~ ^([A-Z_][A-Z0-9_]*)=(.*)$ ]]; then
      actual["${BASH_REMATCH[1]}"]="${BASH_REMATCH[2]}"
    fi
  done < "$ENV_FILE"
fi

missing=()
empty=()
for var in "${required[@]}"; do
  if [ -z "${actual[$var]+x}" ]; then
    missing+=("$var")
  elif [ -z "${actual[$var]// }" ]; then
    empty+=("$var")
  fi
done

if [ ${#missing[@]} -eq 0 ] && [ ${#empty[@]} -eq 0 ]; then
  echo "✓ .env complete (${#required[@]} required vars present)"
  exit 0
fi

echo "✗ .env incomplete:"
[ ${#missing[@]} -gt 0 ] && printf '  missing: %s\n' "${missing[*]}"
[ ${#empty[@]} -gt 0 ] && printf '  empty:   %s\n' "${empty[*]}"
echo "Run scripts/bootstrap.sh to populate. See docs/setup.md for credential sources."
exit 1
