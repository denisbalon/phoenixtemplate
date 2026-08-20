---
name: review
description: Dispatch a code review to the project's warm Codex session and report what it posted. Use when asked to review a PR, get a second opinion on a branch, send something to Codex, or check what the reviewer found. Codex reviews and posts to GitHub itself; this skill only dispatches and relays its findings verbatim, never judging them.
---

# review — dispatch to Codex, relay verbatim

The second reviewer is a **long-lived Codex session per project**, holding the accumulated context of everything it has reviewed here. This skill presses `review-post!` in that session from the current window and brings back what landed on GitHub.

## The one rule

**Never judge what Codex returns.** Present its findings verbatim — its words, its order, its severities. Do not rank, filter, dismiss, agree, summarise into your own phrasing, or pre-empt with your own read. The whole value of a second model is that it is not you; relaying it through your judgement destroys exactly what it was for.

If the user asks what *you* think, answer then — after they have seen the raw findings, never before.

## Steps

### 1. Let the user pick the session — never choose one yourself

**The user names the review session. You do not select it, infer it, or fall back to a default.**

If the user supplied a session UUID or a number with the invocation, use exactly that. Otherwise print this numbered list and **stop, asking which number to use**:

```sh
python3 - <<'PY'
import sqlite3, datetime, re, collections, os
st=sqlite3.connect('file:/root/.codex/state_5.sqlite?mode=ro', uri=True)
hi=sqlite3.connect('file:/root/.codex/thread_history_1.sqlite?mode=ro', uri=True)
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
        # Touched no GitHub repo: cannot be the review session for one, and
        # ancient sessions have no local transcript to tell us either way.
        norepo+=1
        if not ALL: continue
        repo='-'
    else:
        repo=repos.most_common(1)[0][0]
    # One row per repo, most recent first. Rows are ordered by recency, so the
    # first sighting of a repo IS its latest session.
    if not ALL and repo in seen:
        older+=1; continue
    seen.add(repo)
    shown.append((up,(cwd or '?').replace('/root/projects/','').replace('/root','~'),repo))
print(f"  {'#':<4}{'last used':<14}{'github repo':<34}launched in")
for n,(up,folder,repo) in enumerate(shown,1):
    when=datetime.datetime.fromtimestamp((up or 0)/1000, datetime.UTC).strftime('%m-%d %H:%M')
    print(f"  {n:<4}{when:<14}{repo:<34}{folder}")
if not ALL and (older or norepo):
    print()
    if older:  print(f"  {older} older session(s) hidden — a newer one exists for the same repo.")
    if norepo: print(f"  {norepo} session(s) hidden — touched no GitHub repo (or no local transcript).")
    print( "  Re-run with ALL=1 to list every session.")
PY
```

Show it as printed and wait for a number. Do not rank the entries, do not recommend one, and **do not proceed on a single result — one candidate is not consent.**

The two columns that identify a session are **launched in** and **github repo**. When they disagree — a thread opened in one project that has been operating on another — that session lost track of what it reviews. Do not dispatch into one without the user explicitly choosing it anyway.

**Why this is a hard rule.** Dispatching sends an autonomous agent (`approval: never`, `workspace-write`, GitHub write access) into whichever session you name. Threads carry no label — the `name` column is unused — so the only machine-readable signals are recency and the opening message, and both are wrong the moment the user has ever opened Codex in this repo for something other than review. Sessions like *"how to login diff account for codex"* and *"i am working on a cyber security thesis"* already exist. Sending `review-post!` into one of those is not a bad review; it is an agent acting on a repo with no idea why.

Recency was tried and rejected for exactly this reason. It appears to work only because Codex is used here almost exclusively for review; the first exception breaks it silently.

**If the chosen session does not exist, is archived, or belongs to a different `cwd`**, stop and say so. Do not substitute a nearby one.

### 2. Check the session is free

A thread has **exactly one writer**. If a Codex TUI has it open, dispatch fails with `already has an active writer`. Find the holder:

```sh
ps -eo pid,cmd | grep '[c]odex resume' | while read p rest; do echo "$p $(readlink /proc/$p/cwd)"; done
```

If one is running in this project's directory, tell the user which PID to close and stop. Do not kill it yourself — it may hold unsaved context the user is mid-way through.

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
