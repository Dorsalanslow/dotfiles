#!/bin/sh
[[ ! "$PWD" == ~/Source/.dotfiles ]] && echo "The .dotfiles repo must be cloned into and run @ ~/Source/.dotfiles" && exit 1
[[ ! -e "$AUTHOR_NAME" ]] && echo "You must set your AUTHOR_EMAIL!" && exit 1

echo "Setting up new Mac. Yay!"

# Run ssh script if .ssh-file doesn't exist
if [ ! -f ~/.ssh/id_ed25519 ]; then
  ./ssh.sh "$AUTHOR_NAME"
fi

# Install oh my zsh
if test ! $(which omz); then
  /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/HEAD/tools/install.sh)"
fi

# Symlink dotfile .zshrc to home dir
rm -rf ~/.zshrc
ln -fsw "$HOME/Source/.dotfiles/zsh/.zshrc" "$HOME/.zshrc"
ln -fsw "$HOME/Source/.dotfiles/zsh/.p10k.zsh" "$HOME/.p10k.zsh"

# Load new zsh source
touch ~/.hushlogin # Remove last login prompt
omz reload

# Install Homebrew and add to path
if test ! $(which brew); then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Update Homebrew
brew update

# Install homebrew bundle from ./Brewfile
brew tap homebrew/bundle
brew bundle --file ./Brewfile

# Load new zsh source after homebrew installs
omz reload

# Download and setup node versions
nvm upgrade
nvm install node
nvm install rc
nvm install --lts
nvm use --lts

# Setup npm config
npm --version
npm set init-author-name "$AUTHOR_NAME"
npm set init-author-url "https://github.com/$AUTHOR_GITHUB"
npm set init-author-email "$AUTHOR_NAME"
npm set init-license "MIT"
npm set save-prefix ""

# Install default npm packages
npm i -g release create-react-app create-next-app standard yarn eslint jwt-cli

# Install python versions
pyenv install 3.13.0
pyenv install 3.12.6
pyenv install 2.7.18
pyenv global 3.12.6

# Git config
git config --global user.name "$AUTHOR_NAME"
git config --global github.user "$AUTHOR_GITHUB"
git config --global user.email "$AUTHOR_NAME"
git config --global color.ui true
git config --global init.defaultBranch main

git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
git config --global commit.gpgsign true

# Create kitty config symlinks
kitty_dir="$HOME/.config/kitty"
if [ ! -d "$kitty_dir" ]; then
  mkdir $kitty_dir
fi

for conf in kitty/*.conf; do
  conf_name="${conf##*/}"
  conf_path="$kitty_dir/$conf_name"

  if [ -f "$conf_path" ]; then
    echo "$conf_name already exists - removing"
    rm -f $conf_path
  fi

  ln -fsw "$HOME/Source/.dotfiles/kitty/$conf_name" $conf_path
done

# Set macOS preferences - this will reload the shell
source ./.macos
