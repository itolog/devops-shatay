# Include guard
if [[ -n "${_CONFIG_SH_LOADED:-}" ]]; then
  return 0
fi
readonly _CONFIG_SH_LOADED=1

BASE_DIR="${BASE_DIR:-/srv}"
readonly BASE_DIR

readonly APPS_DIR="$BASE_DIR/apps"
readonly INFRA_DIR="$BASE_DIR/infra"
readonly LOGS_DIR="$BASE_DIR/logs"
readonly CADDY_DIR="$BASE_DIR/caddy"
readonly BACKUPS_DIR="$BASE_DIR/backups"