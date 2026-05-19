# Harness Quirks & Bootstrap.sh Design

Operational gotchas of the Claude Code harness plus the design patterns embodied by `templates/scripts/bootstrap.sh`. Extracted from `PROJECT_STARTER.md` in v1.22.0 as part of the doc split (Codex Phase 4 #2). Read this when something behaves unexpectedly in the harness or before modifying `bootstrap.sh`.

---

## Claude Code harness quirks

Operational gotchas observed during real use. Save future-you the discovery cost.

### Permissions / file write gating

- **`.claude/settings.json` write blocked when authorizing a yet-uncreated script.** The harness treats "self-granting permission to a path that doesn't exist on disk" as a privilege-escalation pattern. Workaround: create the script first (so the path is real), then write `settings.json` referencing it. The reverse order fails.
- **Self-granting permissions** (writing `permissions.allow` for new tools) is gated as privilege escalation even when scripts exist. Surface the proposed rule to the user; let them either approve via `/permissions` UI or paste the JSON themselves.

### SSH / production interactions

- **Ad-hoc `ssh root@host '<arbitrary command>'` is gated** as "production reconnaissance" requiring explicit user approval, even with key auth working. Workaround: wrap read-only operations in a reviewable script (e.g. `scripts/<service>-inspect.sh`) and add it to `.claude/settings.json` `permissions.allow`. Don't try wildcard SSH allow rules.
- **Mutating commands on production** (creating users, restarting services, modifying config) need user `!`-prefix execution unless wrapped in a similarly-reviewable script.

### TTY-bound commands fail in `!`-prefix shell

- `sudo`, `ssh-copy-id`, and any command that prompts interactively for a password fails when invoked via Claude Code's `!`-prefix shell — there's no TTY. The user has to run those in a separate real terminal once. Once SSH key auth is in place, subsequent SSH calls work in `!`-prefix.

### `gh` CLI quirks

- **`gh pr edit --body` errors on Projects-classic deprecation.** Known bug. Workaround: use `gh api -X PATCH /repos/<owner>/<repo>/pulls/<N> -f body=...` directly (REST, bypasses the broken GraphQL query).
- **`gh pr merge --rebase` recomputes commit SHAs.** Original branch SHAs (e.g. `5920974`) become new SHAs on `main` (e.g. `20584ae`). Functional content is identical; SHA-based references in PR descriptions become slightly stale.

### Memory and settings carve-outs

- **Memory writes (`~/.claude/projects/.../memory/`) are allowed without `gogogo!`.** This is the carved-out exception — memory is local-only and can capture lessons learned even when no code edits are authorized.
- **`.claude/settings.local.json` is gitignored and per-machine** — also out of the gate. `.claude/settings.json` (the committed one) IS gated.

### Branch protection vs. local merge

- With "Require pull request before merging" + "Require linear history" branch protection enabled on `main`, **local `git merge --ff-only && git push origin main` is rejected**. The canonical merge becomes `gh pr merge --rebase --delete-branch` (server-side).
- **Squash-merge auto-appends `(#N)` to commit subjects; rebase-merge does not.** To trace rebase-merged commits to their PR: `gh pr list --search <sha>`, or include `Refs #N` in the commit body manually before merging.

### Auto mode and the gate

- **Auto mode does NOT override the `gogogo!` gate.** A `system-reminder` saying "execute autonomously" is not a license to skip the literal-substring check. The check is the FIRST step of every code-change response, every turn.

---

## Bootstrap.sh design principles

The interactive `.env` populator (`scripts/bootstrap.sh`) embodies several patterns worth understanding before modifying it. The reference implementation lives in `templates/scripts/bootstrap.sh`.

### Five modes, one entry point

- **`./scripts/bootstrap.sh`** (no args) → opens an interactive menu listing every variable with current value (sensitive masked), letting the user pick by number. The default mode means non-technical contributors don't need to remember flags.
- **`./scripts/bootstrap.sh VAR_NAME`** → edits one variable and exits. Fast for typo fixes.
- **`./scripts/bootstrap.sh --all`** → walks every variable in order. Best for fresh setup.
- **`./scripts/bootstrap.sh --export [path]`** → writes a portable snapshot of the current creds (same `KEY=VALUE` shape as `.env.example`, comments preserved) to `path`, or to `/tmp/<reponame>-creds-<YYYYMMDD-HHMMSS>.env` if no path is given. `chmod 600`. Prints the path on stdout so callers can capture it (`f=$(./scripts/bootstrap.sh --export)`). Status messages go to stderr — stdout is path-only.
- **`./scripts/bootstrap.sh --import <path>`** → reads `KEY=VALUE` pairs from `path` and writes them into `.env` for every var the importing repo recognizes (i.e., present in its `.env.example`). Vars in the file but absent from `.env.example` are skipped with a warning. Validators do not block import — the source file is trusted.

After every edit (any mode), the menu re-renders and saves to `.env` immediately.

### Migration via `--export` / `--import`

The export/import pair is the primary mechanism for moving credentials between machines (dev box → VPS, machine A → machine B) without typing each value twice. The flow:

1. On the source host: `f=$(./scripts/bootstrap.sh --export)` — yields a `chmod 600` file under `/tmp`.
2. Transfer it: `scp "$f" user@target:/tmp/` (or any other secure channel).
3. On the target host: `./scripts/bootstrap.sh --import /tmp/<file>` — populates `.env` and runs `check-env.sh`.
4. Delete the transferred file on both ends.

The export file has the same shape as `.env`, so it can also be hand-edited or diffed before import.

The interactive menu also has `e` (export, prints the path) and `i` (import, prompts for a path) so a contributor walking through `bootstrap.sh` for the first time can do the migration without leaving the TUI or remembering flag spelling.

On WSL hosts, the export additionally prints the Windows-style path (via `wslpath -w`) so Windows-side tooling (Explorer, scp.exe, WinSCP) can pick the file up directly without the user having to translate `\\wsl.localhost\<distro>\tmp\...` by hand. On macOS and native Linux the POSIX path is already the local path, so nothing extra is printed.

### Comment-block-per-variable

Every var in `.env.example` has a comment block above it explaining where to find or generate the value. The bootstrap script reads `.env.example` as the source of truth: it parses the comment block, the variable name, and the default value, and uses them in prompts.

To add a new var: edit `.env.example` only; the script picks it up automatically.

### Optional vs required (via `@directive` schema — B-020)

Each var's required/optional status is declared explicitly via `# @required` or `# @optional` directive lines preceding the var. Required vars demand a non-empty answer; optional vars accept empty input or `-` to clear an existing value. The legacy convention (prose containing the word "Optional") was replaced in v1.14.1 by the parser-friendly directive format — see B-020 in `docs/spec.md` for the full directive vocabulary (`@description`, `@required`, `@optional`, `@default`, `@validator`, `@sensitive`).

### Sensitive-value masking on redisplay

When showing a current value (during edit or in the menu list), variables matching `TOKEN | SECRET | KEY | DSN | PASSWORD` display as `(set, N chars, ends …xyz)` instead of cleartext. Protects against shoulder-surfing during paired sessions and screen sharing.

### Format validators with override (per-var via `@validator` directive — B-020)

Per-var regex validators are declared inline via `# @validator: <ERE>` directives in `.env.example`. Mismatches warn the user with "Use anyway? [y/N]" — they can override when they're sure but they're forced to look at it. Catches typos at input time without being rigid. Hardcoded vendor-specific regex tables in `bootstrap.sh` were removed in v1.12.0 (B-018) and the sidecar `validators.sh` they were moved to was killed in v1.15.0 once the `@directive` system covered the same use case inline.

### Input normalization

Pasted values get their leading/trailing whitespace stripped, surrounding quotes (single or double) removed, and control characters dropped. Most paste artifacts (terminal-border characters, leading spaces, accidental quotes) get cleaned silently; pathological cases get caught by the format validator.

### Atomic save per edit

Each edit commits to `.env` immediately on Enter (writes to a tempfile + rename, chmod 600). No batched "save at end" — if the user Ctrl-Cs halfway through, what they've entered so far is preserved.

### Why no GUI

A TUI-style menu in pure bash works in any terminal (SSH, WSL, mosh, tmux), survives interruptions cleanly, and has zero deps. A GUI would require platform-specific tools and break the "this works on the VPS too" promise.
