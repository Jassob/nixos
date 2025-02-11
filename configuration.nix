# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports = [
    ./cachix.nix
    ./user.nix
    ./system-fonts.nix
    ./system-packages.nix
  ];

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

  nix.settings.trusted-users = [ "root" ];

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  networking = {
    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    useDHCP = false;
    interfaces.wlp164s0.useDHCP = true;
  };

  # Select internationalisation properties.
  console = {
    font = "Lat2-Terminus16";
    keyMap = "sv-latin1";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs = {
    adb.enable = true; # Add Android debugging support
    browserpass.enable = true;
    command-not-found.enable = true;
    evince.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    less.enable = true;
    light.enable = true; # Let users control backlight
    mtr.enable = true; # My traceroute
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

  users.mutableUsers = false;
  virtualisation.docker.enable = true;
}
