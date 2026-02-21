#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Node.js test plugin"

# ------------------------------------------------------------
# 1️⃣ Detect package manager
# ------------------------------------------------------------
PKG_MANAGER="npm"

if [ -f pnpm-lock.yaml ]; then
  PKG_MANAGER="pnpm"
elif [ -f yarn.lock ]; then
  PKG_MANAGER="yarn"
elif [ -f package-lock.json ]; then
  PKG_MANAGER="npm"
fi

echo "📦 Using package manager: $PKG_MANAGER"

# ------------------------------------------------------------
# 2️⃣ Install dependencies
# ------------------------------------------------------------
case "$PKG_MANAGER" in
  pnpm)
    corepack enable
    pnpm install --frozen-lockfile
    ;;
  yarn)
    yarn install --frozen-lockfile
    ;;
  npm)
    if [ -f package-lock.json ]; then
      npm ci
    else
      npm install
    fi
    ;;
esac

# ------------------------------------------------------------
# 3️⃣ Run tests
# ------------------------------------------------------------
echo "🧪 Running tests..."

case "$PKG_MANAGER" in
  pnpm)
    pnpm test
    ;;
  yarn)
    yarn test
    ;;
  npm)
    npm test
    ;;
esac

echo "✅ Node.js tests passed"
