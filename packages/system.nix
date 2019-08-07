{ pkgs }:
with pkgs;

[
  acpi
  coreutils
  cryptsetup
  curl
  ghostscript
  gtk3
  openssh
  openssl
  pciutils
  unrar
  usbutils
  utillinux
  vim
  wget
  zip

  # For terminfo we need to install termite as system package
  alacritty
  termite
]
