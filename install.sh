#!/usr/bin/env bash
set -eo pipefail

###################################################################################################
# HOW TO LEVERAGE THIS INSTALL SCRIPT
#
# This script is formatted with several sections that are skipped by default but can be uncommented
# in a personal fork of this repo if you'd like to leverage those configurations. By default, this
# script will only do a handful of things:
#
# 1. Ensure we're running in the most up-to-date version of the dotfiles repo
# 2. Install some system dependencies. By default, this script will use apt-get for that, although
#    there is a commented out section on using Nix if you so desire.
# 3. Symlinking any dotfiles in the ./dotfiles directory to the home directory
# 4. Installing some shell helpers (oh-my-zsh or oh-my-fish)
#
# Most of the behavior of this script can be customized out of the box using the variables below,
# although if you are forking this repo and want to make more wholistic changes, feel free! This is
# meant primarily to serve as a guide for others and to provide sensible default behavior out of the
# box.
###################################################################################################
full_path() {
    python3 -c "import pathlib; print(pathlib.Path('$1').expanduser().resolve().parent)"
}

SCRIPT_DIR=$(full_path ${BASH_SOURCE[0]})
SCRIPT_GIT_DIR="${SCRIPT_DIR}/.git"

RUN_APT_INSTALL=${RUN_APT_INSTALL:-true} # Install packages with apt-get
RUN_NIX_INSTALL=${RUN_NIX_INSTALL:-false} # Setup and install packages using Nix
RUN_KUBECOLOR_INSTALL=${RUN_KUBECOLOR_INSTALL:-true} # Install kubecolor
RUN_PGCLI_INSTALL=${RUN_PGCLI_INSTALL:-true}         # Install pgcli (Postgres CLI)
RUN_TERRAFORM_LANDSCAPE_INSTALL=${RUN_TERRAFORM_LANDSCAPE_INSTALL:-true} # Install Terraform Landscape

SETUP_OH_MY_ZSH=${SETUP_OH_MY_ZSH:-true} # Install oh-my-zsh
SETUP_OH_MY_FISH=${SETUP_OH_MY_FISH:-false} # Install oh-my-fish, fisher, and some useful plugins for the Fish shell

# Set the location of your neovim configs in this repo if you wish to use Neovim
DOTFILES_TO_SYMLINK=${DOTFILES_TO_SYMLINK:-dotfiles}
_DEFAULT_LOCAL_NEOVIM_CONFIG_LOCATION="${SCRIPT_DIR}/${DOTFILES_TO_SYMLINK}/config/nvim/init.vim"
LOCAL_NEOVIM_CONFIG_LOCATION=${LOCAL_NEOVIM_CONFIG_LOCATION:-_DEFAULT_LOCAL_NEOVIM_CONFIG_LOCATION}

# Monorepo management
MONOREPO_CLONE_LOCATION=${MONOREPO_CLONE_LOCATION:-"$HOME/discord"}
AUTOCLONE_MONOREPO=${AUTOCLONE_MONOREPO:-false}

# Autostart configurations
AUTO_CLYDE_SETUP=${AUTO_CLYDE_SETUP:-false} # Automatically run clyde setup
AUTOSTART_BACKEND=${AUTOSTART_BACKEND:-false} # Auto-run clyde start
AUTOSTART_WEB=${AUTOSTART_WEB:-false} # Auto-run clyde app watch prod

###################################################################################################
# Ensure we're running this in the dotfiles repo
###################################################################################################
# Ensure we're actually in a git repo
if [ ! -d $DOTFILES_GIT_DIR ]; then
    echo "Expected ${DOTFILES_DIR} to be dotfiles git repo, but found no git directory! Aborting..."
    exit 1
fi

###################################################################################################
# Installing system packages with apt-get. This is the more familiar mechanism for installing
# packages on ubuntu.
###################################################################################################
install_deb() {
    echo "Installing from $1$2"
    curl -LO "$1$2"
    sudo dpkg -i "$2"
    rm -f "$2"
}

if [ "$RUN_APT_INSTALL" = true ]; then
    echo "Installing debian packages with dpkg/apt"

    #----------------------------
    # Extra apt repositories
    #----------------------------
    apt_repositories=(
        'ppa:o2sh/onefetch'
    )
    echo "Adding extra APT repositories..."
    for repository in "${apt_repositories[@]}"; do
        sudo DEBIAN_FRONTEND=noninteractive add-apt-repository -y "$repository"
    done

    #----------------------------
    # Update and upgrade apt
    #----------------------------
    echo "Running apt update and upgrade..."
    sudo apt update -y
    echo -e 'n\n' | sudo apt upgrade -y

    #----------------------------
    # Install extra packages:
    # neofetch (TODO: switch off neofetch eventually) and onefetch.
    #----------------------------
    packages=(
        'neofetch'  # TODO: switch off neofetch
        'onefetch'
    )
    echo "Installing extra apt packages..."
    for package in "${packages[@]}"; do
        sudo apt install -y "$package"
    done

    # Install some useful tools (bat/fzf/ripgrep/fd)
    install_deb "https://github.com/BurntSushi/ripgrep/releases/download/12.1.1/" "ripgrep_12.1.1_amd64.deb"
    install_deb "https://github.com/sharkdp/fd/releases/download/v8.2.1/" "fd_8.2.1_amd64.deb"
    install_deb "https://github.com/sharkdp/bat/releases/download/v0.18.1/" "bat_0.18.1_amd64.deb"
    install_deb "https://github.com/dandavison/delta/releases/download/0.8.0/" "git-delta-musl_0.8.0_amd64.deb"
    install_deb "https://github.com/cli/cli/releases/download/v2.14.7/" "gh_2.14.7_linux_amd64.deb"
    install_deb "http://mirrors.kernel.org/ubuntu/pool/universe/f/fzf/" "fzf_0.20.0-1_amd64.deb"

    # Install Neovim (> 0.5)
    sudo add-apt-repository -y ppa:neovim-ppa/unstable
    sudo apt-get update
    sudo apt-get install -y neovim
fi

###################################################################################################
### Symlinking and setting up the necessary configs
###################################################################################################
if [ "$SYMLINK_DOTFILES" = true ]; then
    echo "Symlinking ${DOTFILES_DIR}/dotfiles/.[!.]* into ${HOME}"
    ln -sf ${DOTFILES_DIR}/dotfiles/.[!.]* $HOME

    # Symlink nixpkgs configurations
    echo "Symlinking nix configs"
    mkdir -p $HOME/.nixpkgs
    ln -sf $DOTFILES_DIR/dotfiles/nix/darwin-configuration.nix $HOME/.nixpkgs/darwin-configuration.nix
    ln -sf $DOTFILES_DIR/dotfiles/nix/dev-env.nix $HOME/.nixpkgs/dev-env.nix

    # Symlink the dotfile management scripts
    ln -sf ${DOTFILES_DIR}/update.sh $HOME/.update_dotfiles.sh
    ln -sf ${DOTFILES_DIR}/install.sh $HOME/.install_dotfiles.sh

    ###################################################################################################
    # For users who prefer neovim configs, this sets up the Neovim configs
    ###################################################################################################

    if [[ -f "$LOCAL_NEOVIM_CONFIG_LOCATION" ]]; then
        echo "Symlinking Neovim configs"
        mkdir -p $HOME/.config/nvim
        ln -sf $LOCAL_NEOVIM_CONFIG_LOCATION $HOME/.config/nvim/init.vim
    fi
fi

###################################################################################################
# Instaling system packages with Nix. This is more bespoke and requires some familiarity with how
# Nix works, so isn't recommended for most users, but the option is here for folks who want to
# utilize it.
#
# The process is: Install Nix, source the nix environments, and then install packages
#
# By default, we comment this out, but it can be uncommented if you wish to use Nix to install
# system dependencies. For more information on Nix:
#   - Learn X in Y Minutes Nix Language Reference: https://learnxinyminutes.com/docs/nix/
#   - Nix Manual: https://nixos.org/manual/nixpkgs/stable/
###################################################################################################
if [ "$RUN_NIX_INSTALL" = true ]; then
    NIX_BIN=$HOME/.nix-profile/bin
    if [[ ! -d "$HOME/.nix-profile" ]]; then
        curl -L https://nixos.org/nix/install | sh
    fi

    . $HOME/.nix-profile/etc/profile.d/nix.sh

    $NIX_BIN/nix-channel --update
    $NIX_BIN/nix-env -iA nixpkgs.bat nixpkgs.fzf nixpkgs.fd nixpkgs.ripgrep nixpkgs.neovim
fi

###################################################################################################
# Install oh-my-zsh which provides a solid getting-started experience for ZSH.
###################################################################################################
if [ "$SETUP_OH_MY_ZSH" = true ]; then
    OH_MY_ZSH_INSTALL_URL="https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        echo "Installing oh-my-zsh"
        sh -c "$(curl -fsSL $OH_MY_ZSH_INSTALL_URL)" "" --unattended --keep-zshrc
    fi
fi

###################################################################################################
# For folks who wish to use Fish instead of ZSH for their shell, this block will:
# 1. Copy over the Fish shell configurations
# 2. Install oh-my-fish, which is similar to oh-my-zsh
# 3. Install fisher, which is a plugin manager for the Fish shell
# 4. Install a few useful plugins using Fisher, such as fzf integration and nix-env helpers.
# 5. Install and setup some themes using oh-my-fish
###################################################################################################
if [ "$SETUP_OH_MY_FISH" = true ]; then
    # Install oh-my-fish if it does not exist
    OMF_INSTALL_LOCATION=$HOME/.local/share/omf
    if [[ ! -d $OMF_INSTALL_LOCATION ]]; then
        OMF_INSTALL_URL="https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install"
        echo "Installing oh-my-fish"
        curl -L $OMF_INSTALL_URL > omf_install
        fish omf_install --path=$OMF_INSTALL_LOCATION --noninteractive
        rm omf_install
    fi

    # Install the fisher plugin manager if it hasn't been installed.
    if [[ ! -f "$HOME/.fisher" ]]; then
        echo "Installing fisher (Fish plugin manager"
        curl -sL https://git.io/fisher > $HOME/.fisher
        fish -c "source $HOME/.fisher && fisher install jorgebucaran/fisher"
    fi

    # Install plugins for fish
    fish -c "source $HOME/.fisher && fisher install PatrickF1/fzf.fish"
    fish "$HOME/.config/fish/functions/fzf_configure_bindings.fish"
    fish -c "source $HOME/.fisher && fisher install lilyball/nix-env.fish"

    # Install OMF themes
    fish -c "omf install coffeeandcode 2> /dev/null"

    # Symlink the fish config
    mkdir -p $HOME/.config/fish
    ln -sf ${DOTFILES_DIR}/dotfiles/config/fish/config.fish $HOME/.config/fish/config.fish
fi

###################################################################################################
# Automatically cloning the monorepo if it doesn't exist
###################################################################################################
if [[ ! -d "$MONOREPO_CLONE_LOCATION" ]]; then
    if [[ "$AUTOCLONE_MONOREPO" = true ]]; then
        mkdir -p $(dirname "$MONOREPO_CLONE_LOCATION")
        git clone git@github.com:discord/discord.git $MONOREPO_CLONE_LOCATION
    fi
fi

###################################################################################################
# Autostarting services if desired
###################################################################################################
run_with_shell_in_dir() {
    directory=$1
    shell_command=$2
    zsh -i -c "cd '$directory' && $shell_command"
}

if [ "$AUTO_CLYDE_SETUP" = true ]; then
    echo "Automatically doing basic clyde setup (deps/base services/migrations)"
    run_with_shell_in_dir $MONOREPO_CLONE_LOCATION "./clyde setup 0<&-"
    run_with_shell_in_dir $MONOREPO_CLONE_LOCATION "./clyde migrate apply"
    zsh -i -c "cd $MONOREPO_CLONE_LOCATION && ./clyde migrate apply"
fi

if [ "$AUTOSTART_WEB" = true ]; then
    echo "Automatically starting discord_web"
    run_with_shell_in_dir $MONOREPO_CLONE_LOCATION "./clyde start --exit-when-done app"
elif [ "$AUTOSTART_BACKEND" = true ]; then
    echo "Automatically starting full Discord backend"
    run_with_shell_in_dir $MONOREPO_CLONE_LOCATION "./clyde start --exit-when-done"
fi

###################################################################################################
# kubecolor Installation
###################################################################################################
# kubecolor requires kubectl to be installed.
if ! command -v kubectl &>/dev/null; then
    echo "Warning: kubectl is not installed. kubecolor requires kubectl to work correctly."
fi

if [ "$RUN_KUBECOLOR_INSTALL" = true ]; then
    echo "Installing kubecolor..."

    # Fetch the latest release version from GitHub
    KUBECOLOR_VERSION=$(curl -s https://api.github.com/repos/kubecolor/kubecolor/releases/latest | grep -Po '"tag_name": "v\K[^"]*')

    if [ -z "$KUBECOLOR_VERSION" ]; then
        echo "Error: Unable to fetch kubecolor version."
        exit 1
    fi

    echo "Latest kubecolor version: v${KUBECOLOR_VERSION}"

    # Define the download URL based on the operating system and architecture
    OS=$(uname | tr '[:upper:]' '[:lower:]')
    ARCH=$(uname -m)

    case "$ARCH" in
        x86_64)
            ARCH="amd64"
            ;;
        aarch64 | arm64)
            ARCH="arm64"
            ;;
        *)
            echo "Unsupported architecture: $ARCH"
            exit 1
            ;;
    esac

    DOWNLOAD_URL="https://github.com/kubecolor/kubecolor/releases/download/v${KUBECOLOR_VERSION}/kubecolor_${KUBECOLOR_VERSION}_${OS}_${ARCH}.tar.gz"

    echo "Downloading kubecolor from $DOWNLOAD_URL"
    curl -Lo kubecolor.tar.gz "$DOWNLOAD_URL"

    if [ $? -ne 0 ]; then
        echo "Error: Failed to download kubecolor."
        exit 1
    fi

    # Extract the downloaded tarball
    tar -xzf kubecolor.tar.gz

    if [ $? -ne 0 ]; then
        echo "Error: Failed to extract kubecolor.tar.gz."
        rm -f kubecolor.tar.gz
        exit 1
    fi

    # Remove LICENSE and README.md files after extraction
    rm -f LICENSE README.md

    # Ensure the kubecolor binary is executable
    chmod +x kubecolor

    # Move the binary to /usr/local/bin
    sudo mv kubecolor /usr/local/bin/

    if [ $? -ne 0 ]; then
        echo "Error: Failed to move kubecolor to /usr/local/bin."
        rm -f kubecolor.tar.gz kubecolor
        exit 1
    fi

    # Clean up the tarball
    rm -f kubecolor.tar.gz

    echo "kubecolor installation complete!"
fi

###################################################################################################
# pgcli Installation
###################################################################################################
if [ "$RUN_PGCLI_INSTALL" = true ]; then
    if ! command -v pgcli &>/dev/null; then
        echo "Installing pgcli..."
        # Attempt to install pgcli via APT; if you prefer a pip-based install, replace the next line with:
        # sudo pip install -U pgcli
        sudo apt-get install -y pgcli || {
            echo "Error: Failed to install pgcli."
            exit 1
        }
    else
        echo "pgcli is already installed, skipping."
    fi
fi

###################################################################################################
# Terraform Landscape Installation
###################################################################################################
if [ "$RUN_TERRAFORM_LANDSCAPE_INSTALL" = true ]; then
    if ! command -v landscape &>/dev/null; then
        echo "Installing Terraform Landscape..."
        
        # Ensure Ruby is installed
        if ! command -v ruby &>/dev/null; then
            echo "Ruby is not installed. Installing Ruby..."
            sudo apt update -y
            sudo apt install -y ruby-full build-essential
        fi

        # Install Terraform Landscape using RubyGems
        sudo gem install terraform_landscape || {
            echo "Error: Failed to install Terraform Landscape via RubyGems."
            exit 1
        }

        echo "Terraform Landscape installation complete!"
    else
        echo "Terraform Landscape is already installed, skipping."
    fi
fi

###################################################################################################
# End of installation cleanup or notes for the log.
###################################################################################################
echo Finished installing dotfiles. Please source the relevant files for your shell.
