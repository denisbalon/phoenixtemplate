#!/usr/bin/env bash
# Interactive populator for .env, driven by .env.example.
# Just run it — no flags or arguments needed:
#   ./scripts/bootstrap.sh
#
# You'll see a menu listing every variable + its current value. Type a number
# to edit that variable, 'a' to walk through all in order (first-time setup),
# 'q' to quit. Saves automatically after every edit.
#
# Power-user shortcuts (optional):
#   ./scripts/bootstrap.sh VAR_NAME    edit one variable and exit
#   ./scripts/bootstrap.sh --all       walk through all and exit
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_NAME="$(basename "$ROOT")"
EXAMPLE="$ROOT/.env.example"
ENV_FILE="$ROOT/.env"

[ -f "$EXAMPLE" ] || { echo "FATAL: $EXAMPLE not found." >&2; exit 2; }

# --- Parse .env.example schema via shared helper -----------------------------
# Populates VARS / DESCRIPTIONS / DEFAULTS / VALIDATORS / IS_OPTIONAL /
# IS_SENSITIVE / COMMENTS based on @directive comments per docs/spec.md B-020.
# shellcheck source=/dev/null
source "$(dirname "${BASH_SOURCE[0]}")/_env-schema-parse.sh"

# --- Load existing .env -------------------------------------------------------

declare -A EXISTING=()
if [ -f "$ENV_FILE" ]; then
  while IFS= read -r line || [ -n "$line" ]; do
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${line// }" ]] && continue
    if [[ "$line" =~ ^([A-Z_][A-Z0-9_]*)=(.*)$ ]]; then
      EXISTING["${BASH_REMATCH[1]}"]="${BASH_REMATCH[2]}"
    fi
  done < "$ENV_FILE"
fi

# Normalize input: trim whitespace + strip surrounding quotes + drop common
# paste artifacts (control chars, box-drawing). Returns cleaned value via stdout.
normalize() {
  local s="$1"
  # Trim leading + trailing whitespace
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  # Strip matching surrounding single or double quotes
  if [ "${#s}" -ge 2 ]; then
    case "$s" in
      \"*\") s="${s:1:${#s}-2}" ;;
      \'*\') s="${s:1:${#s}-2}" ;;
    esac
    # Re-trim after quote strip
    s="${s#"${s%%[![:space:]]*}"}"
    s="${s%"${s##*[![:space:]]}"}"
  fi
  # Drop control chars (preserves printable ASCII + most UTF-8); LC_ALL=C makes tr work byte-wise
  s="$(printf '%s' "$s" | LC_ALL=C tr -d '\000-\010\013\014\016-\037\177')"
  printf '%s' "$s"
}

mask() {
  local var="$1" val="$2"
  if [ -z "$val" ]; then echo "(empty)"; return; fi
  if [ -n "${IS_SENSITIVE[$var]-}" ]; then
    if [ "${#val}" -ge 8 ]; then
      echo "(set, ${#val} chars, ends …${val: -4})"
    else
      echo "(set, ${#val} chars)"
    fi
  else
    echo "$val"
  fi
}

# --- Per-variable prompt -----------------------------------------------------

prompt_var() {
  local var="$1"
  local current="${EXISTING[$var]-}"
  local default="${DEFAULTS[$var]-}"
  local validator="${VALIDATORS[$var]-}"
  local optional="${IS_OPTIONAL[$var]-}"
  local description="${DESCRIPTIONS[$var]-}"
  local input

  echo
  echo "──────────────────────────────────────────────"
  if [ -n "$description" ]; then
    echo "  $var — $description"
  else
    echo "  $var"
  fi
  local flags=""
  [ -n "$optional" ] && flags+="optional"
  [ -n "${IS_SENSITIVE[$var]-}" ] && flags+="${flags:+, }sensitive"
  [ -n "$flags" ] && echo "  ($flags)"

  while true; do
    if [ -n "$current" ]; then
      echo "  Current: $(mask "$var" "$current")"
      read -r -p "  ${var} [Enter=keep, '-'=clear, or new value]: " input
      if [ -z "$input" ]; then
        input="$current"
      elif [ "$input" = "-" ]; then
        input=""
      fi
    else
      read -r -p "  ${var}${default:+ [default: $default]}: " input
      [ -z "$input" ] && input="$default"
    fi

    # Normalize: trim whitespace, strip quotes, drop control chars
    if [ -n "$input" ]; then
      raw="$input"
      input="$(normalize "$input")"
      if [ "$raw" != "$input" ]; then
        echo "  → cleaned: $(mask "$var" "$input")"
      fi
    fi

    if [ -z "$input" ]; then
      if [ -n "$optional" ]; then
        EXISTING["$var"]=""
        echo "  → cleared"
        return
      fi
      echo "  ✗ $var is required. Try again."
      continue
    fi

    if [ -n "$validator" ] && ! [[ "$input" =~ $validator ]]; then
      echo "  ⚠ value doesn't match expected pattern: $validator"
      echo "    got: $(mask "$var" "$input")"
      read -r -p "    Use anyway? [y/N]: " override
      if [[ ! "$override" =~ ^[Yy]$ ]]; then
        continue
      fi
    fi

    EXISTING["$var"]="$input"
    echo "  → set: $(mask "$var" "$input")"
    return
  done
}

# --- Write .env from EXISTING + .env.example template -------------------------

write_env() {
  local out=""
  while IFS= read -r line || [ -n "$line" ]; do
    if [[ "$line" =~ ^[[:space:]]*# ]] || [[ -z "${line// }" ]]; then
      out+="$line"$'\n'
      continue
    fi
    if [[ "$line" =~ ^([A-Z_][A-Z0-9_]*)= ]]; then
      local v="${BASH_REMATCH[1]}"
      out+="${v}=${EXISTING[$v]-${DEFAULTS[$v]-}}"$'\n'
      continue
    fi
    out+="$line"$'\n'
  done < "$EXAMPLE"

  local tmp; tmp="$(mktemp)"
  printf '%s' "$out" > "$tmp"
  mv "$tmp" "$ENV_FILE"
  chmod 600 "$ENV_FILE"
}

# --- Main interactive menu ---------------------------------------------------

show_menu() {
  echo
  echo "════════════════════════════════════════════════════════════"
  echo "  $PROJECT_NAME — credential setup"
  echo "════════════════════════════════════════════════════════════"
  echo

  local set_count=0 req_count=0 missing=()
  for var in "${VARS[@]}"; do
    [ -z "${IS_OPTIONAL[$var]-}" ] && req_count=$((req_count+1))
    if [ -n "${EXISTING[$var]-}" ]; then
      set_count=$((set_count+1))
    elif [ -z "${IS_OPTIONAL[$var]-}" ]; then
      missing+=("$var")
    fi
  done

  if [ ${#missing[@]} -eq 0 ]; then
    echo "  ✓ All $req_count required vars are set."
  else
    echo "  Status: $set_count of $req_count required vars set; ${#missing[@]} missing."
  fi
  echo

  local i=0
  for var in "${VARS[@]}"; do
    i=$((i+1))
    local val="${EXISTING[$var]-}"
    local mark="   "
    local suffix=""
    if [ -z "$val" ]; then
      if [ -n "${IS_OPTIONAL[$var]-}" ]; then
        suffix="  (optional)"
      else
        mark=" ! "
      fi
    fi
    printf "  [%2d]%s %-28s %s%s\n" "$i" "$mark" "$var" "$(mask "$var" "$val")" "$suffix"
  done

  echo
  echo "  ──────────────────────────────────────────────────────────"
  echo "  Type a number to edit that variable."
  echo "  Type 'a' to walk through ALL variables (good for first-time setup)."
  echo "  Type 'q' to save and quit."
  echo "  ──────────────────────────────────────────────────────────"
  echo
}

main_menu() {
  while true; do
    show_menu
    read -r -p "  Your choice: " sel

    case "$sel" in
      ''|[Qq]|quit|exit)
        echo
        echo "✓ saved to $ENV_FILE"
        "$ROOT/scripts/check-env.sh" || true
        return
        ;;
      [Aa]|all)
        for var in "${VARS[@]}"; do
          prompt_var "$var"
          write_env
        done
        ;;
      *)
        if [[ "$sel" =~ ^[0-9]+$ ]]; then
          local idx=$((sel-1))
          if [ "$idx" -ge 0 ] && [ "$idx" -lt "${#VARS[@]}" ]; then
            prompt_var "${VARS[$idx]}"
            write_env
          else
            echo "  ✗ out of range — pick a number 1 to ${#VARS[@]}"
            sleep 1
          fi
        elif [ -n "${COMMENTS[$sel]-}" ]; then
          prompt_var "$sel"
          write_env
        else
          echo "  ✗ didn't understand '$sel'. Type a number, 'a', or 'q'."
          sleep 1
        fi
        ;;
    esac
  done
}

# --- Mode dispatch -----------------------------------------------------------

case "${1:-}" in
  '')
    main_menu
    ;;
  --all)
    for var in "${VARS[@]}"; do
      prompt_var "$var"
      write_env
    done
    echo
    echo "✓ saved to $ENV_FILE"
    "$ROOT/scripts/check-env.sh" || true
    ;;
  -h|--help)
    sed -n '2,15p' "$0"
    ;;
  -*)
    echo "Unknown flag: $1" >&2
    echo "Run '$0 --help' for usage." >&2
    exit 1
    ;;
  *)
    if [ -z "${COMMENTS[$1]-}" ]; then
      echo "FATAL: unknown variable: $1" >&2
      echo "Available: ${VARS[*]}" >&2
      exit 1
    fi
    prompt_var "$1"
    write_env
    echo "✓ updated $1"
    "$ROOT/scripts/check-env.sh" || true
    ;;
esac
