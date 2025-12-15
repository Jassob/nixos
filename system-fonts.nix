{ pkgs, ... }:

{
  nixpkgs.config.input-fonts.acceptLicense = true;
  fonts.packages = with pkgs; [
    corefonts # Microsoft free fonts
    dejavu_fonts
    hasklig
    inconsolata
    input-fonts
    iosevka
    ubuntu-classic
    xits-math
    nerd-fonts.iosevka
    nerd-fonts.fira-code
    nerd-fonts.inconsolata
  ];
}
