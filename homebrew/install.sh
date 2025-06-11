# !/bin/zsh
#
# homebrew

echo "🍺 Setting up Homebrew"
# check for Homebrew
if ! command -v brew >/dev/null 2>&1; then
  echo "Installing Homebrew for you"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# install packages
echo "Installing packages..."
packages=(
  coreutils
  gnu-sed
  zsh
  fasd
  jq
  curl
  grc
  trash
  git
  git-delta
  fzf
  neovim
  getantibody/tap/antibody
  source-highlight
  switchaudio-osx
  jordanbaird-ice
  the_silver_searcher
  java
  fd
  php
  mas
  maven
)
for package in $packages; do
  brew install --no-quarantine $package
done

# install casks
echo "Installing casks..."
casks=(
  alfred
  karabiner-elements
  vlc
  vimr
  qlstephen
  syntax-highlight
  appcleaner
  rectangle
  iterm2
  1password
  notunes
  shottr
  qlmarkdown
  keka
  intellij-idea
)
for cask in $casks; do
  brew install --cask --no-quarantine $cask
done

# install apps from App Store
echo "Installing apps from App Store..."
apps=(
  497799835 # Xcode
  6471380298 # StopTheMadness Pro
  1480933944 # Vimari
  1365531024 # 1Blocker
  1458969831 # JSONPeep
  1606897889 # Consent-O-Matic
  1118136179 # AutoMute
  688211836  # EasyRes
  1586435171 # Actions
  1287239339 # ColorSlurp
  6443796196 # FreeScaler
  1510150275 # Lenscape
  1289583905 # Pixelmator Pro
  1550457805 # Soro
)
for app in $apps; do
  mas install $app
done

echo "Done"
exit 0
