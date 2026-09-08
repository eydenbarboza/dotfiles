#!/usr/bin/env bash

set -e


# macOS-specific dotfiles installation script

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source the shared utilities
source "$SCRIPT_DIR/../install-utils.sh"


echo "Starting macOS development environment setup..."

########################################
# Suppress login message
########################################

suppress_login_message() {
  touch ~/.hushlogin
}

########################################
# Install Xcode CLI Tools
########################################

install_xcode_tools() {

  if xcode-select -p &>/dev/null; then
    echo "Xcode Command Line Tools already installed."
  else
    echo "Installing Xcode Command Line Tools..."
    xcode-select --install
    echo "Install the tools from the popup then press ENTER."
    read
  fi

}

########################################
# Set hostname
########################################

set_hostname() {

  echo "Current ComputerName: $(scutil --get ComputerName 2>/dev/null || echo 'Not set')"
  read -p "Enter new computer name (optional): " name

  if [[ -n "$name" ]]; then
    sudo scutil --set ComputerName "$name"
    sudo scutil --set HostName "$name"
    sudo scutil --set LocalHostName "$name"
    sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$name"
  fi

}

########################################
# macOS defaults
########################################

configure_macos_defaults() {

  echo "Configuring macOS defaults..."

  #defaults write -g ApplePressAndHoldEnabled -bool false
  defaults write NSGlobalDomain KeyRepeat -int 2
  defaults write NSGlobalDomain InitialKeyRepeat -int 10

  defaults write com.apple.dock autohide -bool true
  defaults write com.apple.dock autohide-delay -float 0
  defaults write com.apple.dock autohide-time-modifier -float 0.15

  defaults write com.apple.dock mru-spaces -bool false
  defaults write com.apple.dock expose-group-apps -bool true

  for corner in bl br tl tr; do
    defaults write com.apple.dock "wvous-$corner-corner" -int 0
    defaults write com.apple.dock "wvous-$corner-modifier" -int 0
  done

  killall Dock || true

}





########################################
# GUI apps
########################################

install_brew_cask_packages() {

  [[ -d "/Applications/Ghostty.app" ]] || brew install --cask ghostty
  [[ -d "/Applications/Visual Studio Code.app" ]] || brew install --cask visual-studio-code
  [[ -d "/Applications/Docker.app" ]] || brew install --cask docker-desktop
  [[ -d "/Applications/Raycast.app" ]] || brew install --cask raycast
  [[ -d "/Applications/Google Chrome.app" ]] || brew install --cask google-chrome
  [[ -d "/Applications/Claude.app" ]] || brew install --cask claude
  [[ -d "/Applications/Logi Options+.app" ]] || brew install --cask logi-options+

}

########################################
# Fonts
########################################

install_macos_fonts() {

  brew list --cask font-cascadia-code &>/dev/null || brew install --cask font-cascadia-code
  brew list --cask font-jetbrains-mono &>/dev/null || brew install --cask font-jetbrains-mono

}



########################################
# Main setup
########################################

setup() {

  suppress_login_message
  install_xcode_tools
  set_hostname
  #prompt_for_git_config
  configure_macos_defaults
  install_brew
  install_macos_fonts
  install_brew_packages
  install_brew_cask_packages
  #apply_git_config
  install_node_and_tools
  install_rust
  create_symlinks
  setup_zsh_shell
  print_completion

  echo "Setup complete!"

}

########################################
# Check OS
########################################

if [[ "$(uname)" != "Darwin" ]]; then
  echo "This script only works on macOS"
  exit 1
fi

########################################
# sudo keepalive
########################################

sudo -v

while true; do
  sudo -n true
  sleep 60
done 2>/dev/null &

KEEPALIVE_PID=$!

trap "kill $KEEPALIVE_PID 2>/dev/null || true" EXIT INT TERM

setup
