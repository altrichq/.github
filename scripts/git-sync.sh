#!/usr/bin/env sh
set -eu

sync_all=${1:-false}

echo "Fetching remotes..."
git fetch --all --prune

attach_upstream_if_obvious() {
  branch="$1"
  upstream=$(git for-each-ref --format='%(upstream:short)' "refs/heads/$branch")

  if [ -n "$upstream" ] && git rev-parse --verify --quiet "$upstream^{commit}" >/dev/null; then
    printf '%s' "$upstream"
    return 0
  fi

  candidate="origin/$branch"
  if git rev-parse --verify --quiet "$candidate^{commit}" >/dev/null; then
    git branch --set-upstream-to="$candidate" "$branch" >/dev/null 2>&1 || true
    printf '%s' "$candidate"
    return 0
  fi

  printf '%s' ""
}

if [ "$sync_all" != "true" ]; then
  branch=$(git branch --show-current)
  if [ -z "$branch" ]; then
    echo "Detached HEAD; fetched remotes only."
    git status --short --branch
    exit 0
  fi

  upstream=$(attach_upstream_if_obvious "$branch")
  if [ -z "$upstream" ]; then
    echo "No usable upstream found for $branch; fetched remotes only."
    git status --short --branch
    exit 0
  fi

  git pull --rebase --autostash
  git status --short --branch
  exit 0
fi

current=$(git branch --show-current)
echo "Syncing all local branches (fast-forward only)..."

for branch in $(git for-each-ref --format='%(refname:short)' refs/heads/); do
  upstream=$(attach_upstream_if_obvious "$branch")

  if [ -z "$upstream" ]; then
    printf '%-24s %s\n' "$branch" "SKIP  no matching remote"
    continue
  fi

  if [ "$branch" = "$current" ] && [ -n "$(git status --porcelain)" ]; then
    printf '%-24s %s\n' "$branch" "SKIP  current branch has changes"
    continue
  fi

  local_sha=$(git rev-parse "$branch")
  remote_sha=$(git rev-parse "$upstream")

  if [ "$local_sha" = "$remote_sha" ]; then
    printf '%-24s %s\n' "$branch" "OK    up to date"
  elif git merge-base --is-ancestor "$branch" "$upstream"; then
    if [ "$branch" = "$current" ]; then
      git merge --ff-only --quiet "$upstream"
    else
      git branch -f "$branch" "$upstream" >/dev/null
    fi
    printf '%-24s %s\n' "$branch" "OK    updated"
  elif git merge-base --is-ancestor "$upstream" "$branch"; then
    printf '%-24s %s\n' "$branch" "KEEP  local commits ahead"
  else
    printf '%-24s %s\n' "$branch" "SKIP  diverged"
  fi
done

echo
git status --short --branch
