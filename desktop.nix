{ config, lib, pkgs, home-manager, ... }:

{
  imports = [ home-manager.nixosModules.default ];

  nixpkgs.config.permittedInsecurePackages = [ "electron-27.3.11" ];

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

  services.gnome.gnome-browser-connector.enable = true;
  services.gnome.gnome-online-accounts.enable = lib.mkForce false;

  # Enable GDM.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;

    # Configure keymap
    xkb = {
      layout = "se";
      model = "emacs";
      options = "ctrl:nocaps";
    };

    # Set default session to XMonad.
    displayManager.importedVariables = [
      "XDG_SESSION_TYPE"
      "XDG_CURRENT_DESKTOP"
      "XDG_SESSION_DESKTOP"
    ];
    windowManager.xmonad.enable = true;
  };

  home-manager.users.jassob = {
    home.packages = with pkgs; [
      bat
      entr
      google-chrome
      graphviz
      ispell
      logseq
      mu
      networkmanager
      pass
      pavucontrol
      playerctl
      ripgrep
      spotify
      sshfs
      steam
      stow
      telegram-desktop
      tmux
      vlc
      wally-cli
      xclip

      # Rust development
      rustup

      # Web development
      yarn
      nodejs
      nodePackages.typescript-language-server
      nodePackages.prettier

      gnomeExtensions.ddterm
      gnomeExtensions.caffeine
      gnomeExtensions.run-or-raise
    ];

    home.pointerCursor = {
      name = "Vanilla-DMZ";
      package = pkgs.vanilla-dmz;
      x11.enable = true;
      gtk.enable = true;
    };

    # Ensure fonts installed via Nix are picked up.
    fonts.fontconfig.enable = true;

    programs.alacritty.enable = true;
    programs.alacritty.settings.font.normal.family = "Iosevka Nerd Font";

    programs.rofi.enable = true;
    programs.rofi.package =
      pkgs.rofi.override { plugins = [ pkgs.rofi-emoji ]; };

    # Browsers and passwords
    programs.browserpass.enable = true;
    programs.browserpass.browsers = [ "chrome" "firefox" ];
    programs.firefox.enable = true;
    programs.firefox.package = pkgs.unstable.firefox;
    programs.firefox.profiles.jassob.isDefault = true;

    # Enable redshift
    services.redshift = {
      enable = true;
      temperature.day = 4000;
      temperature.night = 3500;
      longitude = "11.98";
      latitude = "57.68";
    };

    # Mail synchronization
    services.mbsync.enable = true;
    services.mbsync.postExec = "${pkgs.mu}/bin/mu index";

    # Enable disk monitor and mounter
    services.udiskie.enable = true;
  };
}
