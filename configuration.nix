# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports = [
    ./cachix.nix
    ./user.nix
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

  # Make sure these packages are installed to the system.
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

  hardware = {
    keyboard.zsa.enable = true;

    bluetooth = {
      enable = true;
      settings.General.Enable = "Source,Sink,Media,Socket";
    };

    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver # LIBVA_DRIVER_NAME=iHD
        libva-vdpau-driver
        libvdpau-va-gl
      ];
    };
  };

  # Enable new nix commands and flakes
  nix.settings.experimental-features = "nix-command flakes";
  nix.settings.trusted-users = [ "root" ];
  nixpkgs.config.allowUnfree = true;

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  # Select internationalisation properties.
  console = {
    font = "Lat2-Terminus16";
    keyMap = "sv-latin1";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    less.enable = true;
    mtr.enable = true; # My traceroute
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

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "sv_SE.UTF-8";
    LC_IDENTIFICATION = "sv_SE.UTF-8";
    LC_MEASUREMENT = "sv_SE.UTF-8";
    LC_MONETARY = "sv_SE.UTF-8";
    LC_NAME = "sv_SE.UTF-8";
    LC_NUMERIC = "sv_SE.UTF-8";
    LC_PAPER = "sv_SE.UTF-8";
    LC_TELEPHONE = "sv_SE.UTF-8";
    LC_TIME = "sv_SE.UTF-8";
  };

  # Enable bluetooth
  services.blueman.enable = true;

  # Enable smart card reader
  services.pcscd.enable = true;

  # Enable sound with pipewire.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  virtualisation.podman.enable = true;
  virtualisation.podman.autoPrune.enable = true;
}
