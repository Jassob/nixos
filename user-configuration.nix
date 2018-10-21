{ config, lib, pkgs, ... }:

{
# Define user accounts. This is the only way to add users to the
# system since mutableUsers are false.
  users = {
    mutableUsers = false;

    users.jassob = {
      home = "/home/jassob";
      description = "Jacob Jonsson";
      extraGroups = [
        "wheel"
        "disk"
        "audio"
        "video"
        "systemd-journal"
        "sudo"
        "users"
        "networkmanager"
        "docker"
      ];
      createHome = true;
      uid = 1000;
      shell = pkgs.zsh;
      hashedPassword = "CREATE WITH mkpasswd -m sha-512";
      packages = with pkgs;
      [
        # Applications
        conkeror
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
        rofi-pass
        steam
        stow
        termite
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
        xorg.xbacklight
        xorg.xmessage
     ];
    };
  };
}
