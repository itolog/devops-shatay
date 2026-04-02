#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$ROOT_DIR/lib/config.sh"
source "$ROOT_DIR/lib/log.sh"

APP="${1:-}"

DIR="$APPS_DIR/$APP"

if [[ -z "$APP" ]]; then
  error "No app specified"
  exit 1
fi

if [[ ! -d "$DIR" ]]; then
  error "App not found: $APP"
  exit 1
fi

cd "$DIR"

log "Updating $APP..."

git pull

docker compose build
docker compose up -d

done_msg "Deploy complete"
