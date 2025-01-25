{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    coreutils
    diffutils
    file
    gnupg
    htop
    nixpkgs-fmt
    openssh
    pciutils
    unzip
    usbutils
  ];
}
