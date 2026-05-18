#!/usr/bin/env bash
# Shared parser for .env.example schema. Sourced by bootstrap.sh + check-env.sh;
# NOT invoked directly (leading underscore + no executable bit by convention).
#
# Input: $EXAMPLE — absolute path to the .env.example file to parse.
#
# Outputs (associative arrays populated in caller's scope):
#   VARS=()              — ordered list of var names as declared in .env.example
#   DESCRIPTIONS[var]    — @description value (empty if not given)
#   DEFAULTS[var]        — @default value if given, else value after `=` in the file
#   VALIDATORS[var]      — @validator ERE pattern (empty if not given)
#   IS_OPTIONAL[var]=1   — set iff @optional was the last @required/@optional directive
#   IS_SENSITIVE[var]=1  — set iff @sensitive given OR var name matches TOKEN/SECRET/KEY/DSN/PASSWORD
#   COMMENTS[var]        — raw multi-line comment block (free-text + directives) preceding the var
#
# Recognized directives (case-insensitive):
#   @description: <text>   — human-readable purpose
#   @required              — default if neither @required nor @optional given
#   @optional              — mutually exclusive with @required (last wins)
#   @default: <value>      — overrides value-after-= as bootstrap.sh's prompt default
#   @validator: <ERE>      — bootstrap.sh checks input against pattern
#   @sensitive             — bootstrap.sh masks the value in display output
#
# Unknown @-prefixed names emit a stderr warning and are ignored (catches typos
# like @requried). Duplicate directives use last-wins. Free-text comments
# (lines without @ prefix) are kept in COMMENTS for display but not parsed.

[ -n "${EXAMPLE:-}" ] || { echo "✗ _env-schema-parse.sh: \$EXAMPLE not set" >&2; exit 2; }
[ -f "$EXAMPLE" ] || { echo "✗ _env-schema-parse.sh: $EXAMPLE not found" >&2; exit 2; }

declare -a VARS=()
declare -A DESCRIPTIONS=() DEFAULTS=() VALIDATORS=() IS_OPTIONAL=() IS_SENSITIVE=() COMMENTS=()

_sens_name_re='(TOKEN|SECRET|KEY|DSN|PASSWORD)'
_known_directives_re='^(description|required|optional|default|validator|sensitive)$'

# Per-block accumulators (reset after each VAR= line)
_blk_comment=""
_blk_description=""
_blk_default=""
_blk_validator=""
_blk_optional=""
_blk_sensitive=""

while IFS= read -r line || [ -n "$line" ]; do
  # Blank line — add to comment block, continue
  if [[ -z "${line// }" ]]; then
    _blk_comment+="$line"$'\n'
    continue
  fi
  # Comment line
  if [[ "$line" =~ ^[[:space:]]*# ]]; then
    _blk_comment+="$line"$'\n'
    # Check for @directive
    if [[ "$line" =~ ^[[:space:]]*#[[:space:]]*@([A-Za-z]+)([[:space:]]*:[[:space:]]*(.*))?[[:space:]]*$ ]]; then
      _d_name="${BASH_REMATCH[1],,}"  # lowercase for case-insensitive match
      _d_value="${BASH_REMATCH[3]-}"
      if ! [[ "$_d_name" =~ $_known_directives_re ]]; then
        echo "⚠ $EXAMPLE: unknown directive @${BASH_REMATCH[1]} — ignored" >&2
        continue
      fi
      case "$_d_name" in
        description) _blk_description="$_d_value" ;;
        required)    _blk_optional="" ;;
        optional)    _blk_optional=1 ;;
        default)     _blk_default="$_d_value" ;;
        validator)   _blk_validator="$_d_value" ;;
        sensitive)   _blk_sensitive=1 ;;
      esac
    fi
    continue
  fi
  # VAR= line
  if [[ "$line" =~ ^([A-Z_][A-Z0-9_]*)=(.*)$ ]]; then
    var="${BASH_REMATCH[1]}"
    raw_default="${BASH_REMATCH[2]}"
    VARS+=("$var")
    COMMENTS["$var"]="$_blk_comment"
    DESCRIPTIONS["$var"]="$_blk_description"
    if [ -n "$_blk_default" ]; then
      DEFAULTS["$var"]="$_blk_default"
    else
      DEFAULTS["$var"]="$raw_default"
    fi
    [ -n "$_blk_validator" ] && VALIDATORS["$var"]="$_blk_validator"
    [ -n "$_blk_optional" ] && IS_OPTIONAL["$var"]=1
    # @sensitive directive OR auto-detect by name substring
    if [ -n "$_blk_sensitive" ]; then
      IS_SENSITIVE["$var"]=1
    elif [[ "$var" =~ $_sens_name_re ]]; then
      IS_SENSITIVE["$var"]=1
    fi
    # Reset accumulators for next block
    _blk_comment=""
    _blk_description=""
    _blk_default=""
    _blk_validator=""
    _blk_optional=""
    _blk_sensitive=""
  fi
done < "$EXAMPLE"

unset _blk_comment _blk_description _blk_default _blk_validator _blk_optional _blk_sensitive
unset _sens_name_re _known_directives_re _d_name _d_value var raw_default
