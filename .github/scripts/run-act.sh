#!/usr/bin/env bash
# ==============================================================================
# Wrapper to run `gh act` locally on workflows using GitHub's `$/` action syntax.
#
# WHY THIS SCRIPT EXISTS:
#   1. `gh-actions-lock` requires same-repo actions to use `$/` (e.g., `$/my-action`)
#      instead of `./` so it can deterministically lock nested dependencies at the
#      workflow's commit rather than trusting mutable workspace paths.
#   2. `nektos/act` (via `gh act`) does not yet support the `$/` syntax and fails
#      with: "Expected format {org}/{repo}[/path]@ref". It only accepts `./` for
#      local actions.
#   3. `nektos/act` sends an empty webhook payload by default, leaving fields like
#      `github.event.head_commit.message` or `github.event.workflow_run` blank
#      unless supplied via `-e`, causing commit gates and origin checks to fail.
#   4. Editing `.github/workflows/` directly in the repo risks accidentally
#      committing `./` changes or dirtying `git status`.
#
# HOW IT WORKS:
#   Moves to the repository root, copies `.github/workflows/` into an isolated
#   temp directory, translates `$/` to `./` in the copies, generates a simulated
#   event JSON payload matching the requested GitHub event (`push` or
#   `workflow_run`), runs `gh act -W` against that temp folder, and deletes all
#   temp files on exit.
# ==============================================================================

# Exit immediately if any command fails (-e), treat unset variables as errors (-u),
# and fail a pipeline if any command inside it fails (-o pipefail).
# Why: Prevents `gh act` from running against partially copied or broken workflow files.
set -euo pipefail

# Always execute from the Git repository root.
# Why: Ensures `.github/workflows/` is found reliably even if you invoke this
# script from inside a subdirectory.
cd "$(git rev-parse --show-toplevel)"

# Create a secure, isolated temporary directory (e.g., /tmp/tmp.XXXXXXXXXX).
# Why: Keeps your actual `.github/workflows/` directory untouched so `git status`
# stays clean and you never accidentally commit local workarounds.
TMP_DIR=$(mktemp -d)

# Register a cleanup trap that deletes the temporary directory when the script exits.
# How: The EXIT signal fires regardless of whether `gh act` succeeds, fails, or is
# interrupted with Ctrl+C, ensuring no temporary files are left behind.
trap 'rm -rf "$TMP_DIR"' EXIT

# Copy all workflow files into the temporary directory.
# Why: `gh act` allows overriding the workflow location via `-W`, while still
# mounting your real repository root as the workspace inside the Docker container.
cp -r .github/workflows/* "$TMP_DIR/"

# Find all YAML workflow files in the temp folder and rewrite `uses: $/` to `uses: ./`.
# Why: Bridges the syntax gap between `gh-actions-lock` (`$/`) and `act` (`./`)
# without modifying your tracked source files.
# How: `find` locates `.yml`/`.yaml` files and passes them in batches (`+`) to `sed -i`,
# which performs an in-place regex substitution on the copied files.
find "$TMP_DIR" -type f \( -name '*.yml' -o -name '*.yaml' \) \
  -exec sed -i 's|uses: \$/|uses: ./|g' {} +

# Detect the requested GitHub event type from the first argument (defaults to `push`).
# Why: Allows the payload generator below to tailor the mock JSON structure to
# either a `push` event or a chained `workflow_run` event.
EVENT_TYPE="${1:-push}"

# Build a simulated GitHub event payload matching the requested event type.
# Why: `push` workflows need `head_commit.message` for commit validation, while
# `workflow_run` workflows require `action` and `workflow_run` metadata to pass
# strict origin and CI success guardrails.
# How: Python inspects `$EVENT_TYPE`; for `workflow_run` it extracts `owner/repo`
# from `origin` and builds a completed `CI` run payload, otherwise it reads
# `git log -1 --pretty=%B` to build a `push` payload.
python3 -c '
import json, re, subprocess, sys

event_type = sys.argv[1]
out_path = sys.argv[2]

if event_type == "workflow_run":
    remote = subprocess.check_output(["git", "remote", "get-url", "origin"], text=True).strip()
    match = re.search(r"github\.com[:/](.+?)(?:\.git)?$", remote)
    repo = match.group(1) if match else "owner/repo"
    branch = subprocess.check_output(["git", "rev-parse", "--abbrev-ref", "HEAD"], text=True).strip()
    payload = {
        "action": "completed",
        "workflow_run": {
            "name": "CI",
            "conclusion": "success",
            "event": "push",
            "head_branch": branch,
            "head_repository": {"full_name": repo}
        },
        "repository": {"full_name": repo}
    }
else:
    msg = subprocess.check_output(["git", "log", "-1", "--pretty=%B"], text=True).strip()
    payload = {
        "head_commit": {"message": msg},
        "commits": [{"message": msg}]
    }

with open(out_path, "w") as f:
    json.dump(payload, f)
' "$EVENT_TYPE" "$TMP_DIR/event.json"

# Attach the generated event payload unless the caller explicitly passed `-e` or `--eventpath`.
# Why: Allows you to override the event file for custom test cases while making
# default `.github/scripts/run-act.sh` runs work out of the box.
EVENT_ARGS=()
if [[ ! " $* " =~ " -e " && ! " $* " =~ " --eventpath " ]]; then
  EVENT_ARGS=(-e "$TMP_DIR/event.json")
fi

# Execute `gh act` pointing at the rewritten workflows in the temp directory.
# How: `-W "$TMP_DIR"` tells `act` to load workflows from our temp copy,
# `"${EVENT_ARGS[@]}"` passes the simulated payload if needed, and `"$@"`
# forwards every argument you passed to this script (such as `workflow_run` or `-j`).
gh act -W "$TMP_DIR" "${EVENT_ARGS[@]}" "$@"
