# Altric organization metadata repository commands
# Run `just` to list available recipes.

set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

default:
    @just --list

sync:
    git fetch --all --prune
    @if git rev-parse --abbrev-ref '@{upstream}' >/dev/null 2>&1; then \
      git pull --rebase --autostash; \
    else \
      echo "No upstream configured for $(git branch --show-current); fetched remotes only."; \
    fi
    git status --short --branch

status:
    git status --short --branch
