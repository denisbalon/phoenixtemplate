---
name: review
description: Dispatch a code review to the project's warm Codex session and report what it posted. Use when asked to review a PR, get a second opinion on a branch, send something to Codex, or check what the reviewer found. Codex reviews and posts to GitHub itself; this skill only dispatches and relays its findings verbatim, never judging them.
---

# review — dispatch to the reviewer session, relay verbatim

> **Scope: this skill assumes Codex as the reviewer.** It reads Codex session
> state from `$CODEX_HOME` (default `~/.codex`) and dispatches with
> `codex exec resume`. That is a deliberate choice recorded in B-051, not an
> oversight — the kit names no default reviewer in its *rubric*, but this
> skill is Codex-shaped and a project using a different reviewer should not
> adopt it. Session paths resolve per-user; nothing here assumes root.

The second reviewer is a **long-lived Codex session per project**, holding the accumulated context of everything it has reviewed here. This skill presses `review-post!` in that session from the current window and brings back what landed on GitHub.

## The one rule

**Never judge what Codex returns.** Present its findings verbatim — its words, its order, its severities. Do not rank, filter, dismiss, agree, summarise into your own phrasing, or pre-empt with your own read. The whole value of a second model is that it is not you; relaying it through your judgement destroys exactly what it was for.

If the user asks what *you* think, answer then — after they have seen the raw findings, never before.

## Steps

### 1. Resolve the session — pinned, or ask once

**You never choose a reviewer session. You may read a choice the user already made.**

That distinction is the whole rule. Selecting a session is forbidden; recalling one the user pinned is not. Without it, a PR-open node that must *name* a reviewer target can never satisfy that requirement without a round-trip, and bundled review never fires.

Pins live in `~/.claude/codex-review-sessions.json`, keyed by GitHub repo:

```sh
python3 - <<'PY'
import json, os, subprocess
PIN=os.path.expanduser('~/.claude/codex-review-sessions.json')
repo=subprocess.run(['gh','repo','view','--json','nameWithOwner','-q','.nameWithOwner'],
                    capture_output=True, text=True).stdout.strip()
pins=json.load(open(PIN)) if os.path.exists(PIN) else {}
print(f"repo: {repo or '(not a GitHub repo)'}")
print(f"pinned session: {pins.get(repo, '(none)')}")
PY
```

**If a pin exists**, verify it still resolves — the session must exist, be unarchived, and belong to this repo. If it does, use it and say which session you are using. If it does not, **stop and say so**; never silently fall back to another.

**If no pin exists**, list the candidates and stop, asking which number to use. Then record the choice before dispatching, so the next PR-open in this repo needs no round-trip:

```sh
python3 - <<'PY'
import sqlite3, datetime, re, collections, os, subprocess
CODEX=os.environ.get('CODEX_HOME') or os.path.expanduser('~/.codex')
st=sqlite3.connect(f'file:{CODEX}/state_5.sqlite?mode=ro', uri=True)
hi=sqlite3.connect(f'file:{CODEX}/thread_history_1.sqlite?mode=ro', uri=True)
ALL = os.environ.get('ALL')

# Scope to the repository this check is running against. A session that never
# touched this repo cannot be its reviewer, and listing it is noise the user
# would have to filter by eye.
here=subprocess.run(['gh','repo','view','--json','nameWithOwner','-q','.nameWithOwner'],
                    capture_output=True, text=True).stdout.strip()
rows=list(st.execute("select id,updated_at_ms,cwd,thread_source from threads "
  "where archived is null or archived=0 order by updated_at_ms desc"))
seen=set(); shown=[]; sub=[]; older=0; other=0
for i,up,cwd,src in rows:
    repos=collections.Counter()
    for (ij,) in hi.execute("select item_json from thread_items "
        "where thread_id=? and item_type='commandExecution'", (i,)):
        for m in re.finditer(r'repos/([\w.-]+/[\w.-]+)', ij): repos[m.group(1)]+=1
    if not repos: other+=1; continue
    repo=repos.most_common(1)[0][0]
    if here and repo != here: other+=1; continue
    # Subagents are NEVER selectable, in any display mode. Codex spawned them;
    # they are children of a parent run with no reviewer context, and their
    # cwd and repo look identical to a real session here. ALL=1 lists them
    # unnumbered below, so they can be seen but never picked.
    if src=='subagent': sub.append((up,i)); continue
    if repo in seen: older+=1; continue
    seen.add(repo)
    shown.append((up,(cwd or '?').replace(os.path.expanduser('~')+'/projects/','').replace(os.path.expanduser('~'),'~'),repo,i))
print(f"  repo: {here or '(not a GitHub repo — showing all)'}\n")
print(f"  {'#':<4}{'last used':<14}{'launched in':<24}session")
for n,(up,folder,repo,i) in enumerate(shown,1):
    when=datetime.datetime.fromtimestamp((up or 0)/1000, datetime.UTC).strftime('%m-%d %H:%M')
    print(f"  {n:<4}{when:<14}{folder:<24}{i}")
if not shown: print("  (none — no session on this host has posted to this repo)")
if older: print(f"\n  {older} older session(s) for this repo hidden — a newer one exists.")
if other: print(f"  {other} session(s) hidden — other repos, or no GitHub activity.")
if sub:
    print(f"\n  {len(sub)} subagent session(s) — NOT selectable, shown for reference only:")
    if ALL:
        for up,i in sub:
            when=datetime.datetime.fromtimestamp((up or 0)/1000, datetime.UTC).strftime('%m-%d %H:%M')
            print(f"      {when}  {i}  (spawned by Codex; dispatching here injects into a worker)")
    else:
        print( "      re-run with ALL=1 to see them")
PY
```

Do not rank the entries, do not recommend one, and **do not proceed on a single result — one candidate is not consent.** Record the pin only after the user names it; writing a pin the user did not choose is choosing.

**Changing or clearing a pin** is a normal request — rewrite the entry, or delete the key so the next run asks again.

### 2. Check that session is free — before proposing, and authoritatively

A thread has **exactly one writer**. B-048 requires this checked **before** the bundled node is proposed: a proposal that half-executes is worse than two proposals, so dispatch-time failure cannot serve as the gate.

Run it with the session id resolved in step 1 — substitute it for `<uuid>`:

```sh
CODEX="${CODEX_HOME:-$HOME/.codex}" SESSION=<uuid> python3 - <<'PY'
import os, glob
codex=os.environ['CODEX']; uuid=os.environ['SESSION']
lock=os.path.join(codex,'thread-writer-locks',f'{uuid}.lock')
if not os.path.exists(lock):
    print(f'FREE — no writer lock for {uuid[:8]}'); raise SystemExit(0)
# A lock file can outlive its process, so attribute it: a Codex client holds
# the thread open by keeping a descriptor on the lock. Scan /proc for one.
holder=None
for fd in glob.glob('/proc/[0-9]*/fd/*'):
    try:
        if os.path.realpath(fd)==os.path.realpath(lock):
            holder=fd.split('/')[2]; break
    except OSError:
        continue
if holder:
    try: cmd=open(f'/proc/{holder}/cmdline','rb').read().decode('utf8','replace').replace('\0',' ').strip()
    except OSError: cmd='(exited)'
    print(f'HELD by pid {holder} — {cmd[:70]}')
else:
    print(f'FREE — lock file for {uuid[:8]} is stale, no process holds it')
PY
```

**`HELD`** → do not propose the bundled node. Name the pid and what it is, and say which thread is held. Do not kill it; it may hold context the user is mid-way through.

**`FREE`** → the thread is dispatchable and the bundled node may be proposed.

**Never substitute `ps | grep codex`.** It is a proxy over the whole process table: it cannot tell which thread a process holds, matches unrelated Codex work in other repositories, and matches a dispatch this session started itself. It was observed reporting a lock that did not exist and asking the user to close a client already closed. Attributing the lock file to a live file descriptor answers the actual question — *is this thread held* — rather than *does any Codex process exist*.

### 3. Dispatch

```sh
codex exec resume <uuid> "review-post!" --output-last-message /tmp/codex-review.txt
```

Send **exactly** `review-post!` and nothing else. The session already knows the repo and the rubric; coaching it changes what it reviews and defeats the point. Run it in the background if the harness supports it — reviews take minutes and the user should not wait.

`review-post!` reviews **every PR open at that moment** and publishes immediately (B-045). If the user wants only one PR reviewed, say that this command does not scope that way rather than inventing a different prompt.

### 4. Collect and relay

Fetch what actually landed on GitHub — not what the transcript claims:

```sh
gh api repos/<owner>/<repo>/pulls/<N>/comments --jq '.[] | "\(.path):\(.line)\n\(.body)\n"'
gh api repos/<owner>/<repo>/pulls/<N>/reviews  --jq '.[] | "[\(.state)] \(.body)\n"'
```

Show every finding in full. If nothing was posted, say that plainly — do not describe what the run *seemed* to do.

### 5. Propose the fixes in the same message — never ask whether to

After the verbatim findings, **in the same message**, propose the concrete change that addresses each one. Do not ask *"want me to fix these?"* — the answer is always yes, so the question is a null option (B-038) and a message that ends with it has no concrete proposal (B-027). It costs the user a round-trip to say something you already knew.

**Proposing a fix is not judging a finding.** Judging is deciding a finding is valid, ranking it, dismissing it, or agreeing with it ahead of the user. Proposing is: *given this finding as written, here is the change that addresses it.* The proposal endorses nothing — the user still decides, but decides on a real plan instead of on whether to be shown one.

Each proposed fix names specific files and specific changes, the way any proposal does. Vague restatement of the finding is not a proposal.

**Mechanical findings are already fixed, not proposed.** Under B-048's constraint (4), a bundled address-review node fixes findings needing no interpretation — a broken link, a stale version reference, a missing required entry — commits, updates the PR and re-dispatches. Those never reach this step. Only findings requiring judgement arrive here, and they arrive *with a plan attached*.

Shape the invitation so acting on everything is one keystroke, since that is the common case:

```
1 gogogo!    fix all three findings
2 gogogo!    fix the two Blocks only, leave the Strong
3            discuss finding 2 before deciding
```

**What this step must never do:** dispute a finding, rank findings by your own severity, tell the user which to skip, or characterise one as wrong. If you believe a finding is mistaken, the fix you propose for it may be *"reply on the PR explaining why this does not apply"* — that is still a concrete action the user can authorise, and it keeps the disagreement on the record where the reviewer can answer it, rather than in your summary where it silently overrides them.

**The only file this skill writes is the session pin** (`~/.claude/codex-review-sessions.json`), and only after the user names a session. That is a user-scoped preference record outside every repository — the same class of write the gate already exempts. It edits no tracked file, no project file, and nothing under the repository. Acting on a finding is always a separate gated proposal.

## Notes

- Codex posts to GitHub itself and verifies each write with a read-back. You are not in the transport path and should not add yourself to it.
- Watch for contract gaps worth mentioning *after* the findings: the rubric requires one comment per commit including clean ones, and a run may post only inline comments plus a summary. Reporting a gap in coverage is not judging a finding.
- Reviews are the reviewer's; commits are yours. Never edit or "tidy" a posted comment.
