#!/usr/bin/env bash
set -euo pipefail

# Move into project root (script location)
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT_DIR"

echo "==> Running pipeline inside: $ROOT_DIR"

# Load .env if present
if [ -f .env ]; then
  set -o allexport
  source .env
  set +o allexport
fi

# Detect docker compose command
if command -v docker-compose &> /dev/null; then
  DC="docker-compose"
elif docker compose version &> /dev/null; then
  DC="docker compose"
else
  echo "❌ Neither docker-compose nor docker compose found"
  exit 1
fi

echo "==> 1. Formatting & linting"
if command -v npx >/dev/null 2>&1; then
  if [ -f .prettierrc ] || grep -q "\"prettier\"" package.json 2>/dev/null; then
    npx prettier --check . || { echo "❌ Prettier failed"; exit 1; }
  fi
  if [ -f .eslintrc* ] || grep -q "\"eslint\"" package.json 2>/dev/null; then
    npx eslint . --ext .js,.ts || { echo "❌ ESLint failed"; exit 1; }
  fi
fi

echo "==> 2. Run tests"
if npm run | grep -q 'test'; then
  npm test
else
  echo "ℹ️ No test script found in package.json"
fi

echo "==> 3. Build Docker image"
docker build -t myapp:local .

echo "==> 4. Start services with docker-compose"
$DC down --volumes --remove-orphans || true
$DC up -d --build

echo "==> 5. Wait for app health"
APP_PORT="${PORT:-3000}"
APP_URL="http://localhost:${APP_PORT}/health"
for i in {1..24}; do
  if curl -sSf "$APP_URL" >/dev/null 2>&1; then
    echo "✅ App is healthy at $APP_URL"
    exit 0
  fi
  echo "Waiting for app... ($i/24)"
  sleep 5
done

echo "❌ App did not become healthy"
$DC logs --tail=100
exit 1
