# Altric Engineering

This document defines lightweight engineering conventions shared across active Altric repositories.

## `just` is the repo command interface

Altric repositories use [`just`](https://just.systems/) as the human-facing command runner for repeatable developer and operational tasks.

The goal is simple: engineers and coding agents should not have to memorize long, repo-specific command sequences or depend on machine-local aliases.

The repository's `justfile` travels with Git, so the same command names work from any correctly configured machine.

### Install `just`

Arch Linux:

```bash
sudo pacman -S just
```

macOS with Homebrew:

```bash
brew install just
```

Other platforms: use the installation instructions at https://just.systems/.

Verify installation:

```bash
just --version
```

## First command after cloning

From the repository root, run:

```bash
just
```

or:

```bash
just --list
```

This lists the recipes supported by that repository.

To inspect a recipe before running it:

```bash
just --show <recipe>
```

Example:

```bash
just --show sync
```

## Common recipes

Active Altric repositories should expose these common recipes where applicable:

```text
just sync      refresh remote Git state and update the current tracked branch
just status    show concise repository state
```

Application repositories may additionally expose commands such as:

```text
just install
just dev
just build
just test
just lint
just typecheck
```

Infrastructure repositories may expose operational commands such as:

```text
just flux-status
just reconcile
just pods
just watch
just logs
just validate
```

The local `justfile` is authoritative for the commands actually supported by a repository.

## Git sync convention

Do not depend on global Git aliases or assume a developer remembers to update every local branch manually.

Use:

```bash
just sync
```

The shared sync recipe should:

1. Fetch all remotes.
2. Prune stale remote refs.
3. Pull the current branch with rebase/autostash when it has a configured upstream.
4. Show the resulting branch/status state.

Local branches may be stale. Remote Git is authoritative.

## Why this lives in Git

Machine-local shell aliases, handwritten notes, and one developer's memory are not reliable engineering infrastructure.

Altric's repeatable workflows should be represented in Git whenever practical so a new laptop or new engineer can recover the same operating model from the repository.

Think of it as:

```text
Git       = source of truth for code and shared workflow
justfile  = repo command interface
CI/CD     = validation and build
Flux      = desired deployment state reconciliation
server    = runtime, not the source of truth
```

## Rules for `justfile` changes

- Keep recipes short and predictable.
- Prefer wrapping existing canonical commands over creating duplicate implementations.
- Do not hide destructive behavior behind innocent recipe names.
- Destructive or production-affecting recipes must be obvious from their name and output.
- Do not add recipes purely for symmetry; only expose commands the repository actually needs.
- Keep secrets out of `justfile`.
- Coding agents should inspect `just --list` or the `justfile` before inventing new command conventions.

## KGL

Branching and Git lifecycle follow **KGL — Keep Git Clean** in the main Altric repository documentation.

Core principle:

> Long-lived branches need a job. Temporary branches die when the work is done.

The `just` convention complements KGL by keeping repeatable workflow in Git instead of on individual laptops.
