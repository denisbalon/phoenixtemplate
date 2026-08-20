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
import sqlite3, datetime, re, collections, os
CODEX=os.environ.get('CODEX_HOME') or os.path.expanduser('~/.codex')
st=sqlite3.connect(f'file:{CODEX}/state_5.sqlite?mode=ro', uri=True)
hi=sqlite3.connect(f'file:{CODEX}/thread_history_1.sqlite?mode=ro', uri=True)
ALL = os.environ.get('ALL')
rows=list(st.execute("select id,updated_at_ms,cwd from threads "
  "where archived is null or archived=0 order by updated_at_ms desc"))
seen=set(); shown=[]; older=0; norepo=0
for i,up,cwd in rows:
    repos=collections.Counter()
    for (ij,) in hi.execute("select item_json from thread_items "
        "where thread_id=? and item_type='commandExecution'", (i,)):
        for m in re.finditer(r'repos/([\w.-]+/[\w.-]+)', ij): repos[m.group(1)]+=1
    if not repos:
        norepo+=1
        if not ALL: continue
        repo='-'
    else:
        repo=repos.most_common(1)[0][0]
    if not ALL and repo in seen:
        older+=1; continue
    seen.add(repo)
    shown.append((up,(cwd or '?').replace(os.path.expanduser('~')+'/projects/','').replace(os.path.expanduser('~'),'~'),repo,i))
print(f"  {'#':<4}{'last used':<14}{'github repo':<34}{'launched in':<22}session")
for n,(up,folder,repo,i) in enumerate(shown,1):
    when=datetime.datetime.fromtimestamp((up or 0)/1000, datetime.UTC).strftime('%m-%d %H:%M')
    print(f"  {n:<4}{when:<14}{repo:<34}{folder:<22}{i}")
if not ALL and (older or norepo):
    print()
    if older:  print(f"  {older} older session(s) hidden — a newer one exists for the same repo.")
    if norepo: print(f"  {norepo} session(s) hidden — touched no GitHub repo (or no local transcript).")
    print( "  Re-run with ALL=1 to list every session.")
PY
```

Do not rank the entries, do not recommend one, and **do not proceed on a single result — one candidate is not consent.** Record the pin only after the user names it; writing a pin the user did not choose is choosing.

**Changing or clearing a pin** is a normal request — rewrite the entry, or delete the key so the next run asks again.

### 2. Check the session is free — authoritatively, not by guessing

A thread has **exactly one writer**. An interactive Codex client holding the chosen thread makes dispatch fail with `already has an active writer`.

Check the lock for **that specific thread**, and confirm its owner is actually alive:

```sh
python3 - <<'PY'
import os, sys
CODEX=os.environ.get('CODEX_HOME') or os.path.expanduser('~/.codex')
uuid=sys.argv[1] if len(sys.argv)>1 else os.environ.get('SESSION','')
lock=os.path.join(CODEX,'thread-writer-locks',f'{uuid}.lock')
if not uuid:
    print('no session id given')
elif not os.path.exists(lock):
    print('FREE — no lock file for this thread')
else:
    # A lock file alone proves nothing: it can outlive the process that made
    # it. Report it as held only if some live codex process could own it.
    live=[p for p in os.listdir('/proc') if p.isdigit()
          and 'codex' in open(f'/proc/{p}/cmdline','rb').read().decode('utf8','replace')]
    print(f'lock present; live codex processes: {live or "none"}')
    print('FREE — lock is stale, no codex process running' if not live
          else 'MAY BE HELD — try the dispatch; the error names the thread if so')
PY
```

**Never use a bare `ps | grep codex` as the check.** It is a proxy over the whole process table: it cannot tell which thread a process holds, matches unrelated Codex work in other repos, and matches a dispatch this session started itself. It reports a lock that does not exist and blocks a dispatch that would have succeeded — an observed failure, not a theoretical one.

**The dispatch itself is the authority.** If the lock state is ambiguous, attempt it: the error is specific, names the thread, and changes nothing when it fails. Only if it fails with `already has an active writer` do you tell the user which client to close — and then say *which thread* is held, not merely that some Codex process exists.

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

### 5. Then stop

Wait for the user. When they decide what to act on, propose the fixes as a normal concrete proposal + `gogogo!`.

## Notes

- Codex posts to GitHub itself and verifies each write with a read-back. You are not in the transport path and should not add yourself to it.
- Watch for contract gaps worth mentioning *after* the findings: the rubric requires one comment per commit including clean ones, and a run may post only inline comments plus a summary. Reporting a gap in coverage is not judging a finding.
- Reviews are the reviewer's; commits are yours. Never edit or "tidy" a posted comment.
