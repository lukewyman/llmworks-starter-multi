# Derive Python package name: svc-1 -> svc_1, song-library -> song_library
PKG := $(shell basename $$(pwd) | sed 's/-/_/g')

# Default port; override with: make run PORT=8081
PORT ?= 8080

.PHONY: install preflight test run format lint typecheck

install: ## create venv if missing + install runtime + dev deps
	uv venv
	uv pip install -e .[dev]
	pre-commit install

lint:
	uv run ruff check .

format:
	uv run black --check .

typecheck:
	uv run mypy .

preflight: lint format typecheck test

test:
	uv run pytest -q --cov=$(PKG) --cov-report=term-missing

run: ## start FastAPI app with uvicorn on $(PORT)
	uv run uvicorn $(PKG).main:app --port $(PORT)
