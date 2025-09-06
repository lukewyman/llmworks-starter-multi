# llmworks-starter-multi

A minimal, **real-work** Python monorepo with per-service isolation and repo-wide guardrails.

- Each service is a standalone Python package under `services/<name>/src/<pkg_name>/`
- Contracts → services → adapters → **thin** FastAPI routers
- Per-service venvs + dev deps; repo-wide style rules (Ruff, Black, Mypy) via root config
- Fan-out Make/CI: run checks for one service or all services

---

## Repo layout

```
services/
svc-1/
src/svc_1/ # package
contracts/ # Pydantic models (I/O contracts)
services/ # business logic (pure)
adapters/ # I/O boundaries (DB, HTTP, etc.)
main.py # FastAPI entrypoint
tests/ # unit + light API tests
pyproject.toml # runtime + dev deps, pytest/coverage
Makefile # install/preflight/test for this service
.github/workflows/
monorepo-ci.yml # matrix over services/*
Makefile # fan-out install/preflight/test across services
pyproject.toml # repo-wide style/type config (ruff/black/mypy)
.pre-commit-config.yaml # repo-wide hooks (auto-fix on commit)
```

---

## One-time setup

```bash
# install pre-commit once on this machine
pre-commit install
pre-commit run -a  # optional: format existing files

# (optional) VS Code: open the workspace at repo root; for squiggles-free imports per service,
# select each service’s interpreter: services/<svc>/.venv/bin/python

## Branching model
```

**Default branch:** main (protected: PRs + green CI required)

**Branch types & names**
* Feature: `feature/<ticket-or-topic>-short-desc` e.g. `feature/KAR-102-add-queue-api`
* Fix/Hotfix: `fix/<ticket>-short-desc` or `hotfix/<ticket>-short-desc`
* Chore/Docs: `chore/<topic> / docs/<topic>`

**Commit message style**

* Conventional-ish: `feat: …, fix: …, chore: …, docs: …, test: …, refactor: …`

## Creating branches (CLI)

```bash
# start from up-to-date main
git checkout main
git pull --ff-only

# create & switch to a feature branch
git checkout -b feature/<ticket>-<short-desc>

# work... then commit
git add -A
git commit -m "feat: <clear summary>"

# publish the branch on GitHub
git push -u origin HEAD

```

Prefer CLI for speed + reproducibility. The GitHub UI is fine for quick edits or creating a draft PR, but the CLI flow above ensures your local branch tracks the remote correctly.

## Pull request (PR) flow

1. Open PR from your branch → main
2. CI runs (matrix per service); fix reds locally and push
3. Keep branch up to date
```bash
git fetch origin
git rebase origin/main
# resolve conflicts if any
git push --force-with-lease

```
4. Reviews → address comments → push updates
5. Merge strategy: prefer squash & merge (one clean commit on main)
6. Delete branch after merge (GitHub UI prompt)

**Branch protection (recommended)**

* Require pull request before merging
* Require status checks to pass (select monorepo-ci)
* Require branches up to date before merging
* (Optional) Dismiss stale reviews

## Make commands

**From repo root (fan-out over all services)**

```bash
make install     # runs each service's install (creates venv, installs deps)
make preflight   # ruff + black --check + mypy + pytest (per service)
make test        # pytest (per service)
```

**Within a service (e.g., `services/svc-1/`)**

```bash
make install     # uv venv && uv pip install -e .[dev] && pre-commit install (for this svc)
make preflight   # ruff + black --check + mypy + pytest with coverage (this svc)
make test        # pytest (this svc)
```

Hooks auto-fix style on commit; CI only verifies (`ruff check .`, `black --check .`) so keep your local commits clean.

## Running the service locally

```bash
cd services/svc-1
make install
uv run uvicorn svc_1.main:app --host 0.0.0.0 --port 8080
# GET http://localhost:8080/healthz  -> {"ok": true}
# GET http://localhost:8080/hello    -> {"message": "hello world"}
```

## Adding a new service (quick checklist)
```bash
# scaffold
cp -r services/svc-1 services/svc-2
# rename package folder and imports
git mv services/svc-2/src/svc_1 services/svc-2/src/svc_2
# edit services/svc-2/pyproject.toml:
#   [project] name = "svc-2"
#   [tool.setuptools.packages.find] include = ["svc_2*"]
# update imports in code/tests from svc_1.* -> svc_2.*
# optional: add "svc_2" to root pyproject's ruff known-first-party (if configured)

# verify
make -C services/svc-2 install
make -C services/svc-2 preflight

# run all
make preflight
```
Open a PR; matrix CI will show jobs for services/svc-1 and services/svc-2.


## CI Overview
* Workflow: .github/workflows/monorepo-ci.yml
* discover job builds a JSON array of services with a pyproject.toml
* test job matrix:
    * uv venv && uv pip install -e .[dev] (per service)
    * uv run ruff check .
    * uv run black --check .
    * uv run mypy .
    * uv run pytest (coverage configured per service)


## Release & tags
After a meaningful milestone (e.g., svc-1 baseline green, svc-2 added, infra online):
```bash
git checkout main
git pull --ff-only
git tag -a v0.1.0 -m "Baseline multi-service starter (svc-1 + CI fan-out)"
git push origin v0.1.0
```

Troubleshooting

* **Ruff import sorting flips blank lines**
Ensure root pyproject.toml has:

```toml
[tool.ruff.lint.isort]
known-first-party = ["svc_1","svc_2"]  # add new services here
```

* **Coverage says “module not imported / no data collected”**
You probably didn’t run make install in the service before tests, so the package wasn’t editable-installed.
* **VS Code can’t resolve `svc_1.*`**
Select interpreter: services/svc-1/.venv/bin/python.
For multiple services, use a multi-root workspace and set per-folder interpreters.
* **CI pip/uv slow/hanging**
Prefer uv resolver; pin actions/setup-python@v5 and use uv venv + uv pip install -e .[dev].

## Philosophy
* Per-service independence: any service can be cloned and worked on alone.
* Repo-wide standards: style/type enforced centrally; CI verifies per service.
* Small increments: contract → tests → service logic → router; commit early, commit clean.