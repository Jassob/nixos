{ pkgs }:
with pkgs;

[
  # Applications
  ag
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
  networkmanager
  openssh
  pass
  pavucontrol
  pciutils
  rofi-pass
  sshfs
  steam
  stow
  termite
  unzip
  usbutils
  virtmanager
  vlc

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
