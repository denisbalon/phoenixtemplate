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

## request-codex-review: run a local Codex CLI review of the current branch against main
##   Synchronous; output streams to stdout. Requires `codex` CLI installed and logged in.
##   The final review block (priority-tagged findings) is at the end of a verbose exec trace.
request-codex-review:
	@command -v codex >/dev/null 2>&1 || { echo "✗ codex CLI not in PATH. Install per https://github.com/openai/codex."; exit 1; }
	@BR=$$(git branch --show-current) ; \
	if [ "$$BR" = "main" ]; then echo "✗ On main; nothing to review."; exit 1; fi ; \
	if [ -z "$$(git log main..HEAD --oneline 2>/dev/null)" ]; then echo "✗ No commits ahead of main on $$BR."; exit 1; fi ; \
	echo "→ codex review --base main  (branch: $$BR)" ; \
	codex review --base main
