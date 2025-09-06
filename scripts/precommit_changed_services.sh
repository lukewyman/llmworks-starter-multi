#!/usr/bin/env bash
set -euo pipefail

# Find top-level service dirs that have staged changes
changed_services=$(
  git diff --cached --name-only \
    | awk -F/ '/^services\/[^/]+\// { print $2 }' \
    | sort -u
)

if [ -z "$changed_services" ]; then
  echo "[precommit] no service changes detected; skipping fan-out checks."
  exit 0
fi

echo "[precommit] running preflight for changed services: $changed_services"
for s in $changed_services; do
  if [ -f "services/$s/Makefile" ]; then
    echo "== $s =="
    make -C "services/$s" preflight
  fi
done
