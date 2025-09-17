#!/usr/bin/env bash
set -euo pipefail

# Move into project root (script location)
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT_DIR"

echo "==> Stopping all project services in: $ROOT_DIR"

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

# Stop and clean everything
$DC down --volumes --remove-orphans

echo "✅ All services stopped and cleaned up"

