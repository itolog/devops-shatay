#!/usr/bin/env bash
set -euo pipefail

trap 'echo -e "\n❌ Script failed at line $LINENO"' ERR

export DEBIAN_FRONTEND=noninteractive


# -----------------------------------------------------------------------------
# ANSI Colors
# -----------------------------------------------------------------------------
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_RED='\033[0;31m'
readonly COLOR_NC='\033[0m'

# -----------------------------------------------------------------------------
# LOG
# -----------------------------------------------------------------------------

log() {
  local msg="$1"
  printf "\n${COLOR_BLUE}===> ${COLOR_GREEN}%s${COLOR_NC}\n\n" "$msg"
}

warn() {
  local msg="$1"
  printf "${COLOR_YELLOW}⚠ %s${COLOR_NC}\n" "$msg"
}

done_msg() {
  local msg="$1"
  printf "${COLOR_GREEN}✔ %s${COLOR_NC}\n" "$msg"
}

error() {
  local msg="$1"
  printf "${COLOR_RED}✖ %s${COLOR_NC}\n" "$msg" >&2
}

die() {
  error "$1"
  exit 1
}

# --------------------------------------------------
# root check
# --------------------------------------------------

if [[ $EUID -ne 0 ]]; then
  error "Please run this script with sudo"
  exit 1
fi

REAL_USER=${SUDO_USER:-$USER}
USER_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)

log "Running setup for user: $REAL_USER"

# --------------------------------------------------
# system update
# --------------------------------------------------

log "Updating system"

apt-get update -y
apt-get upgrade -y

done_msg "System updated"

# --------------------------------------------------
# install base packages
# --------------------------------------------------

log "Installing base packages"

readonly BASE_PACKAGES=(
  git
  curl
  zsh
  ca-certificates
  gnupg
  tree
)

MISSING_PACKAGES=()

for pkg in "${BASE_PACKAGES[@]}"; do
  if ! dpkg -s "$pkg" >/dev/null 2>&1; then
    MISSING_PACKAGES+=("$pkg")
  else
    warn "$pkg already installed"
  fi
done

if [[ ${#MISSING_PACKAGES[@]} -gt 0 ]]; then
  apt-get install -y "${MISSING_PACKAGES[@]}"
  done_msg "Base packages installed"
else
  warn "All base packages already installed"
fi

# --------------------------------------------------
# Oh My Zsh
# --------------------------------------------------

log "Installing Oh My Zsh"

if [[ ! -d "$USER_HOME/.oh-my-zsh" ]]; then
  sudo -u "$REAL_USER" sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    "" --unattended
  done_msg "Oh My Zsh installed"
else
  warn "Oh My Zsh already installed"
fi

# --------------------------------------------------
# alias
# --------------------------------------------------

log "Configuring aliases"

readonly ZSHRC="$USER_HOME/.zshrc"
readonly ALIAS_LINE='alias ll="ls -la"'

if [[ -f "$ZSHRC" ]]; then
  if ! grep -qxF "$ALIAS_LINE" "$ZSHRC"; then
    printf '\n# Custom Aliases\n%s\n' "$ALIAS_LINE" >>"$ZSHRC"
    done_msg "Alias added"
  else
    warn "Alias already exists"
  fi
else
  warn ".zshrc not found"
fi

# --------------------------------------------------
# change shell
# --------------------------------------------------

log "Setting default shell"

CURRENT_SHELL=$(getent passwd "$REAL_USER" | cut -d: -f7)
ZSH_PATH=$(command -v zsh)

if [[ "$CURRENT_SHELL" != "$ZSH_PATH" ]]; then
  chsh -s "$ZSH_PATH" "$REAL_USER"
  done_msg "Default shell changed to zsh"
else
  warn "zsh already default shell"
fi

# --------------------------------------------------
# Docker installation (Official Convenience Script)
# --------------------------------------------------

log "Installing Docker"

if command -v docker >/dev/null 2>&1; then
  warn "Docker already installed"
else
  curl -fsSL https://get.docker.com | sh
  done_msg "Docker installed via official script"
fi

if id -nG "$REAL_USER" | grep -qw docker; then
  warn "User $REAL_USER already in docker group"
else
  usermod -aG docker "$REAL_USER"
  done_msg "User $REAL_USER added to docker group"
fi

# --------------------------------------------------
# verification
# --------------------------------------------------

log "Verifying installations"

done_msg "Docker:  $(docker --version 2>/dev/null || echo 'not installed')"
done_msg "Compose: $(docker compose version 2>/dev/null || echo 'not installed')"
done_msg "Zsh:     $(zsh --version)"
done_msg "Git:     $(git --version)"

# --------------------------------------------------

echo ""
done_msg "✔ Setup complete!"
echo ""
echo "Reconnect via SSH to apply docker group permissions."
echo ""
