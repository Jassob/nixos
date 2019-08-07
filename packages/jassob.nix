{ pkgs }:
with pkgs;

[
  # Applications
  ag
  alacritty
  bat
  browserpass
  coreutils
  drive
  dropbox-cli
  fasd
  file
  firefox
  fzf
  gitAndTools.gitFull
  gnupg
  keybase
  light
  mosh
  networkmanager
  openssh
  pass
  pavucontrol
  playerctl
  pciutils
  ripgrep
  rofi-pass
  spotify
  sshfs
  stow
  surf
  tdesktop
  tmux
  unzip
  usbutils
  virtmanager
  vlc
  xclip

  # Haskell development
  haskellPackages.ghc
  haskellPackages.hlint
  haskellPackages.cabal-install
  haskellPackages.cabal2nix

  # For my XMonad setup
  blueman
  compton
  dunst
  feh
  i3lock
  imagemagick
  libnotify
  ncmpcpp
  pavucontrol
  pulsemixer
  rofi
  scrot
  sxhkd
  trayer
  haskellPackages.xmobar
  xorg.xmessage
]
