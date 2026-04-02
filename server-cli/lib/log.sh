# -----------------------------------------------------------------------------
# Include Guard
# -----------------------------------------------------------------------------
if [[ -n "${_LOG_SH_LOADED:-}" ]]; then
  return 0
fi
readonly _LOG_SH_LOADED=1

# -----------------------------------------------------------------------------
# ANSI Colors
# -----------------------------------------------------------------------------
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_RED='\033[0;31m'
readonly COLOR_NC='\033[0m'

# -----------------------------------------------------------------------------
# Config
# -----------------------------------------------------------------------------
: "${LOG_FILE:=/dev/null}"

# -----------------------------------------------------------------------------
# Internal
# -----------------------------------------------------------------------------
_write_to_file() {
  local level="$1"
  local message="$2"
  local timestamp

  timestamp=$(date +"%Y-%m-%d %H:%M:%S")

  if [[ "$LOG_FILE" != "/dev/null" ]]; then
    local log_dir
    log_dir=$(dirname "$LOG_FILE")

    if [[ -d "$log_dir" && -w "$log_dir" ]]; then
      printf "[%s] [%s] %s\n" "$timestamp" "$level" "$message" >> "$LOG_FILE" || true
    fi
  fi
}

# -----------------------------------------------------------------------------
# Public API
# -----------------------------------------------------------------------------

log() {
  local msg="$1"
  printf "\n${COLOR_BLUE}===> ${COLOR_GREEN}%s${COLOR_NC}\n\n" "$msg"
#  _write_to_file "INFO" "$msg"
}

warn() {
  local msg="$1"
  printf "${COLOR_YELLOW}⚠ %s${COLOR_NC}\n" "$msg"
#  _write_to_file "WARN" "$msg"
}

done_msg() {
  local msg="$1"
  printf "${COLOR_GREEN}✔ %s${COLOR_NC}\n" "$msg"
#  _write_to_file "SUCCESS" "$msg"
}

error() {
  local msg="$1"
  printf "${COLOR_RED}✖ %s${COLOR_NC}\n" "$msg" >&2
#  _write_to_file "ERROR" "$msg"
}

die() {
  error "$1"
  exit 1
}
