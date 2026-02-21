#!/usr/bin/env bash
set -Eeuo pipefail

# SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# source "$SCRIPT_DIR/ci-summary.sh"
# source "$SCRIPT_DIR/ci-guards.sh"
# source "$SCRIPT_DIR/ci-github.sh"


# # Evita execução dupla
# [[ -n "${SHELL_HELPERS_LOADED:-}" ]] && return 0
# export SHELL_HELPERS_LOADED=true

# ------------------------------------------------------------
# → Shell helpers for GitHub Actions
# ------------------------------------------------------------
log() { echo "→ $*" >&2; }
notice() { echo "::notice::$*"; }
warn() { echo "::warning::$*"; }

has_file() { [[ -f "$1" ]]; }

fail() {
  echo "::error::$*" >&2
  exit 1
}

ls_files() {
  echo "📂 Current directory:"
  pwd
  echo "📄 Files in root:"
  ls -la
}

ensure_label () {
  gh label list --json name --jq '.[].name' | grep -qx "$1" || \
  gh label create "$1" --description "$2" --color "$3"
}

resolve_project_path() {
  local raw="$1"
  local workspace="${GITHUB_WORKSPACE:?GITHUB_WORKSPACE not set}"

  raw="${raw:-.}"
  raw="${raw#./}"
  raw="${raw#/}"
  raw="${raw%/}"

  local resolved
  if [[ -z "$raw" || "$raw" == "." ]]; then
    resolved="$workspace"
    raw=""
  else
    resolved="$workspace/$raw"
    raw+="/"
  fi

  if [[ ! -d "$resolved" ]]; then
    fail "❌ Project path does not exist: $resolved" 
    # echo "❌ Project path does not exist: $resolved" >&2
    # return 1
  fi

  echo "$resolved"
}


require_env() {
  local VAR="$1"
  if [[ -z "${!VAR:-}" ]]; then
    fail "Required environment variable not set: $VAR"
  fi
}

# ------------------------------------------------------------
# Error trap (observability by default)
# ------------------------------------------------------------
on_error() {
  local EXIT_CODE=$?
  local CMD="${BASH_COMMAND:-unknown}"

  echo "::error title=Shell script failed::Command failed with exit code ${EXIT_CODE}"

  {
    echo "## ❌ Shell Script Failure"
    echo ""
    echo "**Command:** \`$CMD\`"
    echo "**Exit code:** \`$EXIT_CODE\`"
    echo "**Script:** \`${0##*/}\`"
    echo ""
    echo "_This error was captured by shell-helpers.sh_"
  } >> "${GITHUB_STEP_SUMMARY:-/dev/null}"

  exit "$EXIT_CODE"
}

trap on_error ERR
