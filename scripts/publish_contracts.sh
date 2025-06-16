#!/usr/bin/env bash
# Публикация контрактов в Pact Broker через Docker

set -euo pipefail  # Strict режим

# ---- Конфигурация ----
# Переменные берутся из окружения или используют значения по умолчанию
BROKER_URL="${PACT_BROKER_URL:-http://localhost:9292/}"
BROKER_USERNAME="${PACT_BROKER_USERNAME:-username}"
BROKER_PASSWORD="${PACT_BROKER_PASSWORD:-password}"
PACT_DIR="${PACT_DIR:-pacts}"  # Локальная папка с контрактами
DOCKER_IMAGE="pactfoundation/pact-cli:latest"

# ---- Валидация ----
if [ ! -d "$PACT_DIR" ]; then
  echo "❌ Contracts directory '$PACT_DIR' not found"
  exit 1
fi

# ---- Публикация ----
echo "🚀 Publishing contracts  from $PACT_DIR to $BROKER_URL"
echo "🔖 Version:  ${GITHUB_SHA}"
echo "🌿 Branch: ${GITHUB_REF_NAME}"

docker run --rm \
  -v "$(pwd)/$PACT_DIR:/pacts" \
  -e PACT_BROKER_BASE_URL="$BROKER_URL" \
  -e PACT_BROKER_USERNAME="$BROKER_USERNAME" \
  -e PACT_BROKER_PASSWORD="$BROKER_PASSWORD" \
  "$DOCKER_IMAGE" \
  publish /pacts \
    --consumer-app-version="$GITHUB_SHA" \
    --branch="$GITHUB_REF_NAME" \

echo "✅ Contracts published successfully"