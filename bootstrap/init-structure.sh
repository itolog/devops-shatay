#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="${BASE_DIR:-/srv}"

mkdir -p "$BASE_DIR"/{apps,infra,caddy,logs,backups}

echo "Server structure created:"
tree -d -L 2 "$BASE_DIR" || ls -1 "$BASE_DIR"
