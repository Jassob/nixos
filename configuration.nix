# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./cachix.nix
      <nixos-hardware/dell/xps/13-9300>
      <home-manager/nixos>
    ];

  nixpkgs = {
    config = {
      allowUnfree = true;
      input-fonts.acceptLicense = true;
      permittedInsecurePackages = [ "electron-27.3.11" ];
    };
    overlays = [
      (import (builtins.fetchTarball {
        # Fetched 2024-11-15
        url = "https://github.com/nix-community/emacs-overlay/archive/f6c94b95f529cfbd29848c12816111a2471a5293.tar.gz";
      }))
    ];
  };

  # Supposedly better for SSDs.
  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];

  boot = {
    tmp.cleanOnBoot = true;

    # Disable NixOS containers, conflicts with linux containers.
    enableContainers = false;

    # Use the systemd-boot EFI boot loader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  # Fonts
  environment.systemPackages = with pkgs; [
    corefonts # Microsoft free fonts
    dejavu_fonts
    fira-code
    fira-code-symbols
    hasklig
    inconsolata
    input-fonts
    iosevka
    ubuntu_font_family
    xits-math
    (nerdfonts.override {
      fonts = [
        "Iosevka"
        "FiraCode"
        "Inconsolata"
      ];
    })
  ];

  hardware = {
    keyboard.zsa.enable = true;
    pulseaudio.enable = false;

    bluetooth = {
      enable = true;
      settings.General.Enable = "Source,Sink,Media,Socket";
    };

    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver # LIBVA_DRIVER_NAME=iHD
        vaapiVdpau
        libvdpau-va-gl
      ];
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  networking = {
    # hostName = "nixos"; # Define your hostname.

    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    useDHCP = false;
    interfaces.wlp164s0.useDHCP = true;
  };

  # Enable new nix commands and flakes
  nix.settings.experimental-features = "nix-command flakes";

  # Select internationalisation properties.
  console = {
    font = "Lat2-Terminus16";
    keyMap = "sv-latin1";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs = {
    adb.enable = true;                # Add Android debugging support
    browserpass.enable = true;
    command-not-found.enable = true;
    evince.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    less.enable = true;
    light.enable = true;              # Let users control backlight
    mtr.enable = true;                # My traceroute
    nm-applet.enable = true;
    slock.enable = true;
    tmux.enable = true;
    wireshark.enable = true;
    zsh = {
      enable = true;
      autosuggestions.enable = true;
    };
  };

  security = {
    # Enable a lightweight `sudo` alternative
    doas.enable = true;

    # Enable Yubikey for login and sudo access
    pam.yubico = {
      enable = true;
      mode = "challenge-response";
      id = "30084239"; # personal yubikey
    };
  };

  # List services that you want to enable:
  services = {
    blueman.enable = true;

    displayManager.defaultSession = "none+xmonad";

    gnome.gnome-browser-connector.enable = true;

    # Enable touchpad support (enabled default in most desktopManager).
    libinput.enable = true;

    # Hibernate after closing lid
    logind.lidSwitch = "hibernate";

    # Enable smart card reader
    pcscd.enable = true;

    power-profiles-daemon.enable = false; # Conflicts with tlp
    tlp.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # Enable the X11 windowing system.
    xserver = {
      enable = true;

      # Configure keymap
      xkb = {
         layout = "se";
         options = "ctrl:nocaps";
      };

      # Enable GDM and set default session to XMonad.
      displayManager = {
        gdm.enable = true;
        importedVariables = [
          "XDG_SESSION_TYPE"
          "XDG_CURRENT_DESKTOP"
          "XDG_SESSION_DESKTOP"
        ];
      };
      desktopManager.gnome.enable = true;
      windowManager.xmonad.enable = true;
    };
  };

  # Allow users to update binary cache settings
  nix.settings = {
    trusted-users = [ "root" "jassob" ];
  };

  users.mutableUsers = false;
  users.users.jassob = {
    description = "Jacob Jonsson";
    isNormalUser = true;
    extraGroups = [
      "adbusers"
      "adm"
      "wheel"
      "docker"
      "networkmanager"
      "video"
      "wireshark"
    ];
    uid = 1000;
    shell = pkgs.zsh;
    hashedPassword = "$6$mAXxVn19aK5zrREl$X4n6J.9UtRzQy3RgbSE4O372x48NItjVJea0H2fiTviIpHQmbBU9SGFrGOpxHDMLhPANuVncZDSVUmryUcy4e.";
  };

  virtualisation.docker.enable = true;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.jassob = import ./users/jassob.nix { config = config; pkgs = pkgs; };
  };

  # Making sure to remove files generated by Nix before rebuilding home-manager generation
  systemd.services.home-manager-jassob.preStart = ''
    if [ -f /home/jassob/.xmonad/xmonad-x86_64-linux ]; then
       rm -f /home/jassob/.xmonad/xmonad-x86_64-linux
    fi
  '';

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}
