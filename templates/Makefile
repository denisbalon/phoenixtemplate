# <PROJECT_NAME> — make targets
# Customize the command bodies for your stack (Python/uv shown).

.PHONY: dev test lint fix deploy bootstrap check-env request-codex-review

## dev: run the service in development mode (with auto-reload)
dev:
	uv run uvicorn <package_name>.app:app --host 127.0.0.1 --port 8080 --reload

## test: run the test suite
test:
	uv run pytest

## lint: run lint + typecheck (same gates as CI)
lint:
	uv run ruff check .
	uv run mypy src

## fix: auto-fix lint issues
fix:
	uv run ruff check --fix .
	uv run ruff format .

## deploy: deploy to the production target (see scripts/deploy.sh)
deploy:
	./scripts/deploy.sh

## bootstrap: walk through .env interactively
bootstrap:
	./scripts/bootstrap.sh

## check-env: verify .env is complete
check-env:
	./scripts/check-env.sh

## request-codex-review: post a PR comment triggering Codex review of the current branch's PR
##   (one-shot wrapper around the request-codex-review skill — same canonical comment body)
request-codex-review:
	@PR=$$(gh pr view --json number -q .number 2>/dev/null) || { echo "✗ No open PR for current branch. Open one first."; exit 1; } ; \
	gh pr comment $$PR --body "$$(printf '@codex review\n\nPlease follow the PR review rubric in `docs/pr_review_instructions.md`:\n- Severity: Block / Strong / Nit\n- Per-commit comments — walk every commit `main..HEAD` in order\n- On clean commits, post an explicit \"no findings on <sha> — <subject>\" comment\n- One overall summary review at the end, rolled up by severity\n\nLook around the repo (spec, architecture, recent changes) before diving into the diff if useful.\n')" && \
	echo "✓ Codex notified on PR #$$PR"
