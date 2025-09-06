.PHONY: install preflight test

install: ## create venv if missing + install runtime + dev deps
	uv venv
	uv pip install -e .[dev]
	pre-commit install

preflight:
	uv run ruff check .
	uv run black --check .
	uv run mypy .
	uv run pytest -q --cov=svc_1 --cov-report=term-missing

test:
	uv run pytest -q --cov=svc_1 --cov-report=term-missing