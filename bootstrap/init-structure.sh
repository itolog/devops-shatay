#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="${BASE_DIR:-/srv}"

mkdir -p "$BASE_DIR"/{apps,infra,caddy,logs,backups}

echo "Server structure created:"
tree "$BASE_DIR" || ls "$BASE_DIR"
