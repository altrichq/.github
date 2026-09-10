#!/usr/bin/env sh
set -eu

sync_all=${1:-false}

echo "Fetching remotes..."
git fetch --all --prune

if [ "$sync_all" != "true" ]; then
  branch=$(git branch --show-current)
  if [ -z "$branch" ]; then
    echo "Detached HEAD; fetched remotes only."
  elif git rev-parse --abbrev-ref '@{upstream}' >/dev/null 2>&1; then
    git pull --rebase --autostash
  else
    echo "No upstream configured for $branch; fetched remotes only."
  fi
  git status --short --branch
  exit 0
fi

current=$(git branch --show-current)
echo "Syncing all tracked local branches (fast-forward only)..."

for branch in $(git for-each-ref --format='%(refname:short)' refs/heads/); do
  upstream=$(git for-each-ref --format='%(upstream:short)' "refs/heads/$branch")
  if [ -z "$upstream" ]; then
    printf '%-24s %s\n' "$branch" "SKIP  no upstream"
    continue
  fi
  if ! git rev-parse --verify --quiet "$upstream^{commit}" >/dev/null; then
    printf '%-24s %s\n' "$branch" "SKIP  upstream missing"
    continue
  fi
  if [ "$branch" = "$current" ]; then
    if [ -n "$(git status --porcelain)" ]; then
      printf '%-24s %s\n' "$branch" "SKIP  current branch has changes"
      continue
    fi
    if git merge-base --is-ancestor "$branch" "$upstream"; then
      before=$(git rev-parse "$branch")
      git merge --ff-only --quiet "$upstream"
      after=$(git rev-parse "$branch")
      [ "$before" = "$after" ] && state="OK    up to date" || state="OK    updated"
      printf '%-24s %s\n' "$branch" "$state"
    else
      printf '%-24s %s\n' "$branch" "SKIP  diverged"
    fi
  elif git merge-base --is-ancestor "$branch" "$upstream"; then
    before=$(git rev-parse "$branch")
    after=$(git rev-parse "$upstream")
    if [ "$before" = "$after" ]; then
      printf '%-24s %s\n' "$branch" "OK    up to date"
    else
      git branch -f "$branch" "$upstream" >/dev/null
      printf '%-24s %s\n' "$branch" "OK    updated"
    fi
  else
    printf '%-24s %s\n' "$branch" "SKIP  diverged"
  fi
done

echo
git status --short --branch
