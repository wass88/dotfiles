#!/bin/bash

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'export PATH="$PATH:/opt/homebrew/bin"' >> ~/.zshrc
source ~/.zshrc

softwareupdate --install-rosetta --agree-to-license

# Key Repeat
defaults write -g InitialKeyRepeat -int 11
defaults write -g KeyRepeat -int 1
# Remove Dock Apps
defaults write "com.apple.dock" "persistent-apps" -array; killall Dock
# Dock Position
defaults write com.apple.dock magnification -bool false
defaults write com.apple.dock orientation -string "right"
defaults write com.apple.dock mineffect -string "scale"
defaults write com.apple.dock launchanim -bool false
defaults write com.apple.dock autohide -bool true
# TrackPad
defaults write -g com.apple.mouse.scaling 3.6

brew install gh
brew install --cask google-chrome
brew install --cask google-japanese-ime
brew install --cask zoom
brew install --cask 1password
brew install --cask bettertouchtool
brew install --cask appcleaner
brew install --cask raycast
brew install --cask slack
brew install mas

brew install mise
eval "$(mise activate zsh)"
mise use -g ruby@latest
mise use -g node@latest
mise use -g rust@latest


brew install --cask docker
brew install --cask warp
brew install --cask ngrok
brew install git
brew install awscli
brew install --cask xcodes
brew install --cask iterm2
