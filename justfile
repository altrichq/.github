# Altric organization metadata repository commands
# Run `just` to list available recipes.

set shell := ["bash", "-eu", "-o", "pipefail", "-c"]
set minimum-version := "1.46.0"

default:
    @just --list

# Refresh remote state. Use -a/--all to safely fast-forward all tracked local branches.
[arg("all", short="a", long="all", value="true")]
sync all="false":
    sh scripts/git-sync.sh '{{all}}'

status:
    git status --short --branch
