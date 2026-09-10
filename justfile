# Altric organization metadata repository commands
# Run `just` to list available recipes.

set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

default:
    @just --list

# Refresh remote state. With -a/--all, safely fast-forward all tracked local branches.
sync *args:
    @set -- {{args}}; \
    mode="current"; \
    if [ "$#" -gt 1 ]; then \
      echo "Usage: just sync [-a|--all]" >&2; exit 2; \
    elif [ "$#" -eq 1 ]; then \
      case "$1" in \
        -a|--all) mode="all" ;; \
        *) echo "Usage: just sync [-a|--all]" >&2; exit 2 ;; \
      esac; \
    fi; \
    echo "Fetching remotes..."; \
    git fetch --all --prune; \
    if [ "$mode" = "current" ]; then \
      branch=$$(git branch --show-current); \
      if [ -z "$branch" ]; then \
        echo "Detached HEAD; fetched remotes only."; \
      elif git rev-parse --abbrev-ref '@{upstream}' >/dev/null 2>&1; then \
        git pull --rebase --autostash; \
      else \
        echo "No upstream configured for $$branch; fetched remotes only."; \
      fi; \
      git status --short --branch; \
      exit 0; \
    fi; \
    current=$$(git branch --show-current); \
    echo "Syncing all tracked local branches (fast-forward only)..."; \
    for branch in $$(git for-each-ref --format='%(refname:short)' refs/heads/); do \
      upstream=$$(git for-each-ref --format='%(upstream:short)' "refs/heads/$$branch"); \
      if [ -z "$$upstream" ]; then \
        printf '%-24s %s\n' "$$branch" "SKIP  no upstream"; \
        continue; \
      fi; \
      if ! git rev-parse --verify --quiet "$$upstream^{commit}" >/dev/null; then \
        printf '%-24s %s\n' "$$branch" "SKIP  upstream missing"; \
        continue; \
      fi; \
      if [ "$$branch" = "$$current" ]; then \
        if ! git diff --quiet || ! git diff --cached --quiet; then \
          printf '%-24s %s\n' "$$branch" "SKIP  current branch has changes"; \
        elif git merge-base --is-ancestor "$$branch" "$$upstream"; then \
          before=$$(git rev-parse "$$branch"); \
          git merge --ff-only --quiet "$$upstream"; \
          after=$$(git rev-parse "$$branch"); \
          if [ "$$before" = "$$after" ]; then \
            printf '%-24s %s\n' "$$branch" "OK    up to date"; \
          else \
            printf '%-24s %s\n' "$$branch" "OK    updated"; \
          fi; \
        else \
          printf '%-24s %s\n' "$$branch" "SKIP  diverged"; \
        fi; \
      elif git merge-base --is-ancestor "$$branch" "$$upstream"; then \
        before=$$(git rev-parse "$$branch"); \
        after=$$(git rev-parse "$$upstream"); \
        if [ "$$before" = "$$after" ]; then \
          printf '%-24s %s\n' "$$branch" "OK    up to date"; \
        else \
          git branch -f "$$branch" "$$upstream" >/dev/null; \
          printf '%-24s %s\n' "$$branch" "OK    updated"; \
        fi; \
      else \
        printf '%-24s %s\n' "$$branch" "SKIP  diverged"; \
      fi; \
    done; \
    echo; \
    git status --short --branch

status:
    git status --short --branch
