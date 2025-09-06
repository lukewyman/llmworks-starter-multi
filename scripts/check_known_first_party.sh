# scripts/check_known_first_party.sh
set -euo pipefail
EXPECTED=$(ls -1 services | sed 's/^/"/;s/$/"/' | paste -sd, -)
grep -q "known-first-party = \\[${EXPECTED}\\]" pyproject.toml || {
  echo "Update [tool.ruff.lint.isort].known-first-party to: [${EXPECTED}]"
  exit 1
}
