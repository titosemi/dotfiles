#!/bin/bash

# Stop in case of errors
set -e

# Create a bin directory
if [[ ! -d "${HOME}/bin" ]]; then
    mkdir -p "${HOME}/bin"
fi

# Install homeshick
if [[ ! -d "${HOME}/.homesick/repos/homeshick" ]]; then
    echo "Installing homeshick"
    git clone git://github.com/andsens/homeshick.git "${HOME}/.homesick/repos/homeshick"
fi

# Make symlink of homeshick to ~/bin
if [[ ! -L "${HOME}/bin/homeshick" ]]; then
    ln -s ${HOME}/.homesick/repos/homeshick/bin/homeshick ${HOME}/bin
fi

# Install my dotfiles (via homeshick)
dotfiles="$(homeshick list | grep dotfiles)"
if [[ $? -ne 0 ]]; then
    homeshick clone git@github.com:titosemi/dotfiles.git
fi

# Install oh-my-zsh
if [[ ! -d "${HOME}/.oh-my-zsh" ]]; then
    echo "Installing oh-my-zsh"
    # sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

    git clone https://github.com/robbyrussell/oh-my-zsh "${HOME}/.oh-my-zsh"
    /bin/bash "${HOME}/.oh-my-zsh/tools/install.sh"
fi
