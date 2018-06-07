{ pkgs }:
with pkgs;

[
  # Applications
  drive
  dropbox-cli
  firefox
  gitAndTools.gitFull
  gnupg
  keybase
  light
  openssh
  pass
  pavucontrol
  pciutils
  rofi-pass
  sshfs
  steam
  stow
  termite
  usbutils
  virtmanager

  # Haskell development
  haskellPackages.ghc
  haskellPackages.hlint
  haskellPackages.cabal-install
  haskellPackages.cabal2nix

  # For my XMonad setup
  compton
  dunst
  imagemagick
  libnotify
  ncmpcpp
  pamixer
  pavucontrol
  rofi
  scrot
  sxhkd
  xorg.xmessage
]
