#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Node.js coverage plugin"

REPO_ROOT="${REPO_ROOT:-$PWD}"
COVERAGE_STRATEGY="${COVERAGE_STRATEGY:-auto}"
COVERAGE_COMMAND="${COVERAGE_COMMAND:-}"

RAW_FILE="coverage/coverage-summary.json"
QUALITY_FILE="${QUALITY_FILE:-$REPO_ROOT/quality-result.json}"

log() { echo "→ $1"; }

create_quality_file() {
  local LINE=${1:-0}
  local BRANCH=${2:-0}
  local FUNCTION=${3:-0}

  mkdir -p "$REPO_ROOT/coverage"

cat <<EOF > "$QUALITY_FILE"
{
  "line": $LINE,
  "branch": $BRANCH,
  "function": $FUNCTION
}
EOF

  log "✅ Coverage normalized:"
  log "  line: $LINE%"
  log "  branch: $BRANCH%"
  log "  function: $FUNCTION%"
}

# ------------------------------------------------------------
# 1️⃣ Detect test existence
# ------------------------------------------------------------
HAS_TESTS=false

if \
  [ -d "tests" ] || \
  [ -d "__tests__" ] || \
  [ -d "test" ] || \
  find . -type f \( -name "*.test.*" -o -name "*.spec.*" \) | grep -q .
then
  HAS_TESTS=true
fi

# ------------------------------------------------------------
# 2️⃣ If no tests → deterministic zero coverage
# ------------------------------------------------------------
if [ "$HAS_TESTS" = "false" ]; then
  echo "⚠️ No tests detected. Generating zero coverage."

  create_quality_file
  exit 0
fi

# ------------------------------------------------------------
# 3️⃣ Execute coverage strategy
# ------------------------------------------------------------
log "Coverage strategy: $COVERAGE_STRATEGY"

if [ "$COVERAGE_STRATEGY" = "custom" ]; then

  if [ -z "$COVERAGE_COMMAND" ]; then
    echo "❌ coverage_strategy=custom requires coverage_command"
    exit 1
  fi

  log "Executing custom coverage command"
  eval "$COVERAGE_COMMAND"

elif [ "$COVERAGE_STRATEGY" = "auto" ]; then

  RUNNER=""

  if [ -x "node_modules/.bin/vitest" ]; then
    RUNNER="vitest"
  elif [ -x "node_modules/.bin/jest" ]; then
    RUNNER="jest"
  fi

  if [ -z "$RUNNER" ]; then
    create_quality_file
    echo "❌ No supported test runner detected (Vitest/Jest)"
    exit 1
  fi

  log "Detected runner: $RUNNER"
  # npm test -- --no-watch --coverage --reporter=verbose

  if [ "$RUNNER" = "vitest" ]; then
    npx vitest run --coverage --reporter=verbose
  elif [ "$RUNNER" = "jest" ]; then
    npx jest --coverage --coverageReporters=json-summary
  fi

else
  echo "❌ Invalid coverage_strategy: $COVERAGE_STRATEGY"
  exit 1
fi

# ------------------------------------------------------------
# 4️⃣ Validate coverage output
# ------------------------------------------------------------
if [ ! -f "$RAW_FILE" ]; then
  echo "❌ Coverage summary not generated at $RAW_FILE"
  exit 1
fi

LINE=$(jq '.total.lines.pct // 0' "$RAW_FILE")
BRANCH=$(jq '.total.branches.pct // 0' "$RAW_FILE")
FUNCTION=$(jq '.total.functions.pct // 0' "$RAW_FILE")

# ------------------------------------------------------------
# 5️⃣ Normalize contract
# ------------------------------------------------------------
create_quality_file "$LINE" "$BRANCH" "$FUNCTION"
