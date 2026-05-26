# <PROJECT_NAME> — make targets
# Customize the command bodies for your stack (Python/uv shown).

.PHONY: dev test lint fix deploy bootstrap check-env install-hooks

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

## install-hooks: activate local git hooks (pre-push blocks direct pushes to main)
install-hooks:
	git config core.hooksPath .githooks
	@echo "✓ git hooks activated from .githooks/ (pre-push blocks direct pushes to main)"
