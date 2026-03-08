#!/usr/bin/env bash

# Shared utility functions for dotfiles installation



# Function to check if a command exists
check_command() {
    local cmd="$1"
    command -v "$cmd" &>/dev/null
}



# Install Homebrew
install_brew() {
    if check_command brew; then
        echo "Homebrew is already installed."
    else
        echo "Installing Homebrew..."
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    echo "Setting up Homebrew environment..."

    # Source brew for current session
    if [[ "$(uname)" == "Darwin" ]]; then
        # macOS
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        # Linux
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi

    # Add to shell config
    if [[ "$SHELL" == *"zsh" ]]; then
        grep -q "brew shellenv" ~/.zshrc 2>/dev/null || echo 'eval "$(brew shellenv)"' >>~/.zshrc
    else
        grep -q "brew shellenv" ~/.bashrc 2>/dev/null || echo 'eval "$(brew shellenv)"' >>~/.bashrc
    fi
}

# Create symlinks for dotfiles
create_symlinks() {
    echo "Removing existing dotfiles..."
    #rm -rf ~/.vim ~/.vimrc ~/.zshrc ~/.config/nvim ~/.ideavimrc ~/.config/starship.toml ~/.config/ghostty 2>/dev/null
    rm -rf ~/.config/starship.toml ~/.config/ghostty 2>/dev/null

    echo "Creating symlinks..."
    mkdir -p ~/projects ~/.config 

   
    ln -s ~/dotfiles/ghostty ~/.config/ghostty
    ln -s ~/dotfiles/starship.toml ~/.config/starship.toml
  

}

# Install common brew packages
install_brew_packages() {
    brew update

    # Install lazydocker (requires both tap and package)
    brew install jesseduffield/lazydocker/lazydocker
    brew install lazydocker
    brew install neovim
    brew install zoxide
    brew install --cask claude-code
    brew install zsh-autosuggestions
    brew install zsh-syntax-highlighting
    brew install starship
    brew install devcontainer
    brew install scrcpy
    brew install tmux
    brew install gh
    brew install zig
    brew install lazygit
    brew install gemini-cli
 

    # Install fonts
    echo "Installing fonts via Homebrew..."
    brew install --cask font-cascadia-code

    if ! check_command fzf; then
        brew install fzf
        # Add FZF shortcuts non-interactively (enable all features)
        "$(brew --prefix)"/opt/fzf/install --all
    fi
}

# Setup ZSH as default shell
setup_zsh_shell() {
    # Check if the current shell is already zsh
    if [[ "$SHELL" == *"zsh" ]]; then
        echo "ZSH is the default shell."
    else
        # Get the path of zsh
        zsh_path=$(which zsh)

        # Change the default shell to zsh for future logins
        echo "Setting up zsh as your default shell..."
        if chsh -s "$zsh_path"; then
            echo "Setup complete. Log out and back in to start using zsh as your default shell."
        else
            echo "Error: Failed to change the default shell."
            echo "Please try running 'chsh -s $(which zsh)' manually."
        fi
    fi
}



# Install Node.js and AI CLI tools
install_node_and_tools() {
    brew install fnm
    echo "Installing Node.js using fnm..."
    eval "$(fnm env)"

    fnm install --latest
    fnm use latest
    fnm default latest

    echo "Node.js and AI CLI tools installed."
}

# Print completion message
print_completion() {
    echo -e "\n\n\n\nAll systems operational. 🤖"
    echo "Your development environment is ready! Blast off!"
}