#!/usr/bin/env bash
# apply-github-rulesets.sh — apply the canonical `protect-main` branch-protection
# ruleset (B-055 / D-038 in docs/spec.md) across every non-archived repo of a
# GitHub *user* account.
#
# Why: enabling Claude Code cloud sessions gives the Claude GitHub App write
# access that can direct-push / force-push / delete a default branch. The local
# .githooks/pre-push hook does not travel to a fresh/cloud clone, so the gate
# must be server-side. The account is a User (not an Org), so there is no
# org-level ruleset — the policy is applied per-repo by this loop. Re-run it
# any time to cover newly-created repos (idempotent).
#
# Policy (from the canonical payload docs/branch-protection-ruleset.json):
#   ruleset `protect-main`, target ~DEFAULT_BRANCH, enforcement active,
#   require-PR (0 approvals) + block non_fast_forward + block deletion, sole
#   bypass actor = Repository Admin role (id 5, always). The Claude GitHub App
#   is deliberately NOT a bypass actor.
#
# Default is dry-run: it prints a per-repo plan and makes no changes. Pass
# --apply to write. Requires: gh (authenticated, admin scope on the targets)
# and python3.
#
# Verify after --apply:
#   gh api repos/<owner>/<repo>/rulesets --jq '.[].name'   # lists protect-main
#   a non-admin direct push to the default branch is rejected; an admin direct
#   push and `gh pr merge --rebase` still succeed.

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: apply-github-rulesets.sh [options]

  --apply                 Make changes. Without it, dry-run (print the plan only).
  --owner <login>         GitHub user login to target. Default: `gh api user`.
  --create-only           Only create missing rulesets; never reconcile existing ones.
  --payload <path>        Ruleset JSON. Default: auto-detected (docs/ then
                          templates/docs/ relative to this script).
  --extra-bypass A:T:M    Append a bypass actor to the policy for all repos, as
                          actor_id:actor_type:bypass_mode (repeatable). Use for
                          known non-admin automation that must push to the
                          default branch (a CI bump bot, a release app).
  --include <name>        Limit to these repos (nameWithOwner or bare name; repeatable).
  --exclude <name>        Skip these repos (repeatable).
  -h, --help              This help.
EOF
}

die() { echo "✗ $*" >&2; exit 1; }

APPLY=0 CREATE_ONLY=0 OWNER="" PAYLOAD=""
EXTRA_BYPASS=() INCLUDE=() EXCLUDE=()

while [ $# -gt 0 ]; do
  case "$1" in
    --apply) APPLY=1 ;;
    --create-only) CREATE_ONLY=1 ;;
    --owner) OWNER="${2:-}"; shift ;;
    --payload) PAYLOAD="${2:-}"; shift ;;
    --extra-bypass) EXTRA_BYPASS+=("${2:-}"); shift ;;
    --include) INCLUDE+=("${2:-}"); shift ;;
    --exclude) EXCLUDE+=("${2:-}"); shift ;;
    -h|--help) usage; exit 0 ;;
    *) die "unknown option: $1 (try --help)" ;;
  esac
  shift
done

command -v gh >/dev/null 2>&1 || die "gh not found"
command -v python3 >/dev/null 2>&1 || die "python3 not found"

# Resolve the payload path: --payload wins, else auto-detect the consumer
# layout (docs/) then the meta-repo layout (templates/docs/).
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -z "$PAYLOAD" ]; then
  for cand in "$DIR/../docs/branch-protection-ruleset.json" \
              "$DIR/../templates/docs/branch-protection-ruleset.json"; do
    [ -f "$cand" ] && { PAYLOAD="$cand"; break; }
  done
fi
[ -n "$PAYLOAD" ] && [ -f "$PAYLOAD" ] \
  || die "ruleset payload not found (looked in docs/ and templates/docs/; pass --payload)"

# Resolve the owner.
[ -n "$OWNER" ] || OWNER="$(gh api user --jq .login 2>/dev/null || true)"
[ -n "$OWNER" ] || die "could not resolve owner (pass --owner <login>)"

# Build the effective payload = canonical + any --extra-bypass actors.
EFFECTIVE="$(mktemp)"; trap 'rm -f "$EFFECTIVE"' EXIT
PAYLOAD="$PAYLOAD" python3 - "${EXTRA_BYPASS[@]+"${EXTRA_BYPASS[@]}"}" > "$EFFECTIVE" <<'PY'
import json, os, sys
doc = json.load(open(os.environ['PAYLOAD']))
for spec in sys.argv[1:]:
    parts = spec.split(':')
    if len(parts) != 3:
        sys.exit(f"bad --extra-bypass '{spec}' (want actor_id:actor_type:bypass_mode)")
    aid, atype, mode = parts
    doc.setdefault('bypass_actors', []).append(
        {"actor_id": int(aid), "actor_type": atype, "bypass_mode": mode})
json.dump(doc, sys.stdout)
PY

NAME="$(PAYLOAD="$EFFECTIVE" python3 -c 'import json,os;print(json.load(open(os.environ["PAYLOAD"]))["name"])')"

in_list() {
  local needle="$1"; shift
  local x
  for x in "$@"; do
    if [ "$x" = "$needle" ] || [ "$x" = "${needle##*/}" ]; then return 0; fi
  done
  return 1
}

# A protect-main ruleset created from this payload, normalized to the
# policy-relevant fields (server-defaulted extras are ignored so an unchanged
# ruleset reads as already-correct, not as a spurious reconcile).
matches_canonical() {
  local full="$1"
  EFFECTIVE="$EFFECTIVE" python3 - "$full" <<'PY'
import json, os, sys
def norm(d):
    rules = {r.get("type"): (r.get("parameters") or {}) for r in (d.get("rules") or [])}
    pr = rules.get("pull_request", {})
    ref = ((d.get("conditions") or {}).get("ref_name") or {})
    return {
        "name": d.get("name"),
        "target": d.get("target"),
        "enforcement": d.get("enforcement"),
        "include": sorted(ref.get("include") or []),
        "rule_types": sorted(rules.keys()),
        "pr_approvals": pr.get("required_approving_review_count"),
        "bypass": sorted(f'{b.get("actor_id")}:{b.get("actor_type")}:{b.get("bypass_mode")}'
                         for b in (d.get("bypass_actors") or [])),
    }
want = json.load(open(os.environ['EFFECTIVE']))
got = json.loads(sys.argv[1])
sys.exit(0 if norm(want) == norm(got) else 1)
PY
}

mapfile -t REPOS < <(gh repo list "$OWNER" --limit 500 --json nameWithOwner,isArchived \
  --jq '.[] | select(.isArchived==false) | .nameWithOwner')

mode_label="DRY-RUN"; [ "$APPLY" -eq 1 ] && mode_label="APPLY"
echo "== apply-github-rulesets ($mode_label) =="
echo "   owner:    $OWNER"
echo "   ruleset:  $NAME"
echo "   payload:  $PAYLOAD"
[ "${#EXTRA_BYPASS[@]}" -gt 0 ] && echo "   extra bypass: ${EXTRA_BYPASS[*]}"
echo "   repos:    ${#REPOS[@]} non-archived"
echo

created=0 reconciled=0 ok=0 skipped=0 failed=0 plan_create=0 plan_reconcile=0

for repo in "${REPOS[@]}"; do
  if [ "${#INCLUDE[@]}" -gt 0 ] && ! in_list "$repo" "${INCLUDE[@]}"; then continue; fi
  if [ "${#EXCLUDE[@]}" -gt 0 ] && in_list "$repo" "${EXCLUDE[@]}"; then
    printf '   %-45s skip (excluded)\n' "$repo"; skipped=$((skipped+1)); continue
  fi

  existing_id="$(gh api "repos/$repo/rulesets" \
    --jq ".[] | select(.name==\"$NAME\") | .id" 2>/dev/null | head -n1 || true)"

  if [ -z "$existing_id" ]; then
    if [ "$APPLY" -eq 1 ]; then
      if err="$(gh api "repos/$repo/rulesets" --method POST --input "$EFFECTIVE" 2>&1 >/dev/null)"; then
        printf '   %-45s created\n' "$repo"; created=$((created+1))
      else
        printf '   %-45s FAILED to create — %s\n' "$repo" "$(echo "$err" | head -n1)"; failed=$((failed+1))
      fi
    else
      printf '   %-45s would create\n' "$repo"; plan_create=$((plan_create+1))
    fi
    continue
  fi

  full="$(gh api "repos/$repo/rulesets/$existing_id" 2>/dev/null || true)"
  if [ -n "$full" ] && matches_canonical "$full"; then
    printf '   %-45s already-correct\n' "$repo"; ok=$((ok+1)); continue
  fi

  if [ "$CREATE_ONLY" -eq 1 ]; then
    printf '   %-45s present, differs — skip (--create-only)\n' "$repo"; skipped=$((skipped+1)); continue
  fi
  if [ "$APPLY" -eq 1 ]; then
    if err="$(gh api "repos/$repo/rulesets/$existing_id" --method PUT --input "$EFFECTIVE" 2>&1 >/dev/null)"; then
      printf '   %-45s reconciled\n' "$repo"; reconciled=$((reconciled+1))
    else
      printf '   %-45s FAILED to reconcile — %s\n' "$repo" "$(echo "$err" | head -n1)"; failed=$((failed+1))
    fi
  else
    printf '   %-45s would reconcile\n' "$repo"; plan_reconcile=$((plan_reconcile+1))
  fi
done

echo
echo "== summary =="
if [ "$APPLY" -eq 1 ]; then
  echo "   created $created · reconciled $reconciled · already-correct $ok · skipped $skipped · failed $failed"
  [ "$failed" -eq 0 ] || exit 1
else
  echo "   would create $plan_create · would reconcile $plan_reconcile · already-correct $ok · skipped $skipped"
  echo "   (dry-run — re-run with --apply to make changes)"
fi
