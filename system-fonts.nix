{ pkgs, ... }:

{
  nixpkgs.config.input-fonts.acceptLicense = true;
  environment.systemPackages = with pkgs; [
    corefonts # Microsoft free fonts
    dejavu_fonts
    hasklig
    inconsolata
    input-fonts
    iosevka
    ubuntu_font_family
    xits-math
    (nerdfonts.override { fonts = [ "Iosevka" "FiraCode" "Inconsolata" ]; })
  ];
}
