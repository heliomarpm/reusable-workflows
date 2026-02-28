#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/../../shared/shell-helpers.sh"
log "🚀 Node.js coverage plugin"

COVERAGE_COMMAND="${COVERAGE_COMMAND:-}"
RAW_FILE="coverage/coverage-summary.json"

output_result() {
  local LINE=${1:-0}
  local BRANCH=${2:-0}
  local FUNCTION=${3:-0}

  local TIMESTAMP=$(date +%s%3N)
  local PATH_DIR="$(dirname "0")/coverage"
  local FILE="$PATH_DIR/result_${TIMESTAMP}.json"

  mkdir -p "$PATH_DIR"
  
cat <<EOF > "$FILE"
{
  "line": $LINE,
  "branch": $BRANCH,
  "function": $FUNCTION
}
EOF

  log "✅ Coverage normalized: $FILE"
  log "  line: $LINE%"
  log "  branch: $BRANCH%"
  log "  function: $FUNCTION%"

  echo "line=$LINE" >> $GITHUB_OUTPUT
  echo "branch=$BRANCH" >> $GITHUB_OUTPUT
  echo "function=$FUNCTION" >> $GITHUB_OUTPUT
  
  echo "file=$FILE" >> $GITHUB_OUTPUT
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

  output_result
  exit 0
fi

# ------------------------------------------------------------
# 3️⃣ Execute custom command
# ------------------------------------------------------------
if [ ! -z "$COVERAGE_COMMAND" ]; then
  log "Executing custom coverage command: $COVERAGE_COMMAND"
  eval "$COVERAGE_COMMAND" 

 else  
  RUNNER=""

  if [ -x "node_modules/.bin/vitest" ]; then
    RUNNER="vitest"
  elif [ -x "node_modules/.bin/jest" ]; then
    RUNNER="jest"
  fi

  if [ -z "$RUNNER" ]; then
    output_result
    fail  "❌ No supported test runner detected (Vitest/Jest)"
  fi

  log "Running coverage for ${RUNNER}..."
  # npm test -- --no-watch --coverage --reporter=verbose

  if [ "$RUNNER" = "vitest" ]; then
    npx vitest run --coverage --reporter=verbose
  elif [ "$RUNNER" = "jest" ]; then
    npx jest --coverage --coverageReporters=json-summary
  fi
fi

# ------------------------------------------------------------
# 4️⃣ Validate coverage output
# ------------------------------------------------------------
if [ ! -f "$RAW_FILE" ]; then
  fail "❌ Coverage summary not generated at $RAW_FILE"
fi

LINE=$(jq '.total.lines.pct // 0' "$RAW_FILE")
BRANCH=$(jq '.total.branches.pct // 0' "$RAW_FILE")
FUNCTION=$(jq '.total.functions.pct // 0' "$RAW_FILE")

# ------------------------------------------------------------
# 5️⃣ Normalize contract
# ------------------------------------------------------------
output_result "$LINE" "$BRANCH" "$FUNCTION"
