#!/usr/bin/env bash

set -e

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

configure_macos() {

  echo "Configuring macOS defaults..."

  #defaults write -g ApplePressAndHoldEnabled -bool false
  defaults write NSGlobalDomain KeyRepeat -int 1
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
# Install Homebrew
########################################

install_homebrew() {

  if command -v brew &>/dev/null; then
    echo "Homebrew already installed"
  else
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  eval "$(/opt/homebrew/bin/brew shellenv)" || true

}

########################################
# CLI tools
########################################

install_cli_tools() {

  brew list git &>/dev/null || brew install git
  brew list tmux &>/dev/null || brew install tmux
  brew list reattach-to-user-namespace &>/dev/null || brew install reattach-to-user-namespace
  brew list node &>/dev/null || brew install node
  brew list starship &>/dev/null || brew install starship

}

########################################
# GUI apps
########################################

install_apps() {

  [[ -d "/Applications/Ghostty.app" ]] || brew install --cask ghostty
  [[ -d "/Applications/Visual Studio Code.app" ]] || brew install --cask visual-studio-code
  [[ -d "/Applications/Docker.app" ]] || brew install --cask docker-desktop
  [[ -d "/Applications/Raycast.app" ]] || brew install --cask raycast
  [[ -d "/Applications/Google Chrome.app" ]] || brew install --cask google-chrome

}

########################################
# Fonts
########################################

install_fonts() {

  brew tap homebrew/cask-fonts || true

  brew list --cask font-cascadia-code &>/dev/null || brew install --cask font-cascadia-code
  brew list --cask font-jetbrains-mono &>/dev/null || brew install --cask font-jetbrains-mono

}

########################################
# Setup ZSH + Starship
########################################

setup_zsh() {

  if [[ "$SHELL" != *zsh ]]; then
    chsh -s "$(which zsh)"
  fi

  if ! grep -q starship ~/.zshrc 2>/dev/null; then
    echo 'eval "$(starship init zsh)"' >>~/.zshrc
  fi

}

########################################
# Install tmux Catppuccin theme
########################################

install_catppuccin_themes() {

  mkdir -p ~/.tmux/plugins

  if [[ ! -d ~/.tmux/plugins/catppuccin ]]; then
    git clone https://github.com/catppuccin/tmux.git ~/.tmux/plugins/catppuccin
  fi

}

########################################
# Main setup
########################################

setup() {

  suppress_login_message
  install_xcode_tools
  set_hostname
  configure_macos
  install_homebrew

  brew update

  install_cli_tools
  install_apps
  install_fonts

  setup_zsh
  install_catppuccin_themes

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

trap "kill $KEEPALIVE_PID" EXIT INT TERM

setup
