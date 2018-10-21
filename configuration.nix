# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./user-configuration.nix
    ];

  # Supposedly better for SSDs.
  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.efi.canTouchEfiVariables = true;
  boot.cleanTmpDir = true;

  # Register our boot device
  boot.initrd.luks.devices = [
    {
      name = "root";
      device = "/dev/disk/by-uuid/e888a938-2281-491a-8978-580bb0948a1a";
      preLVM = true;
      allowDiscards = true;
    }
  ];

  hardware = {
    bluetooth.enable = true;
    cpu.intel.updateMicrocode = true;

    opengl.extraPackages = [ pkgs.vaapiIntel ];
    opengl.driSupport32Bit = true;

    pulseaudio = {
      enable = true;
      support32Bit = true;

      # NixOS allows either a lightweight build (default) or full build
      # of PulseAudio to be installed. Only the full build has
      # Bluetooth support, so it must be selected here.
      package = pkgs.pulseaudioFull;

      # Enable TCP streaming
      tcp.enable = true;
      tcp.anonymousClients.allowedIpRanges =
        [ "127.0.0.1" "192.168.1.0/24" ];
    };
  };

  # Define your hostname.
  networking.hostName = "nixjsb";

  # Enables wireless support via network-manager.
  networking.networkmanager.enable = true;

  # Select internationalisation properties.
  i18n = {
    consoleFont = "term-32n";
    consoleKeyMap = "sv-latin1";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    acpi
    coreutils
    cryptsetup
    curl
    ghostscript
    gtk3
    openssh
    openssl
    unrar
    utillinux
    vim
    wget
    zip
    zsh
  ];

  powerManagement = {
    enable = true;
    powertop.enable = true;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.bash = {
    enableCompletion = true;

    # fix problem with emacs tramp (https://github.com/NixOS/nixpkgs/issues/3368)
    promptInit = "PS1=\"# \"";

  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.ssh.forwardX11 = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.forwardX11 = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable redshift
  services.redshift = {
    enable = true;
    temperature.day = 4000;
    temperature.night = 3500;
    longitude = "11.98";
    latitude = "57.68";
  };

  services.cron.enable = true;

  services.emacs.install = true;
  services.emacs.defaultEditor = true;

  # Enable Mopidy music daemon if ./services/mopidy.nix exists
  services.mopidy = if builtins.pathExists ./services/mopidy.nix
    then import ./services/mopidy.nix { pkg = pkgs.mopidy-spotify; }
    else { enable = false; };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;

    displayManager.lightdm.enable = true;
    desktopManager.gnome3.enable = true;
    windowManager.exwm.enable = true;
    displayManager.gdm.enable = false;
    desktopManager.default = "none";
    windowManager.default = "xmonad";
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      extraPackages = haskellPackages: [
        haskellPackages.xmonad-contrib
        haskellPackages.xmonad-extras
        haskellPackages.xmonad
        haskellPackages.xmobar
      ];
    };

    # Keyboard
    layout = "se";
    xkbOptions = "ctrl:nocaps";

    libinput.enable = true;
  };

  # TiMidity++ Daemon
  systemd.user.services.timidity = {
    description = "TiMidity++ Daemon";
    after = [ "sound.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.timidity}/bin/timidity -iA -Os";
      ExecStop = "/run/current-system/sw/bin/pkill timidity";
    };
    wantedBy = [ "default.target" ];
  };

  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = true;
  virtualisation.libvirtd.qemuPackage = pkgs.qemu_kvm;

  nixpkgs.config = {
    # Enable support for broadcom_sta
    allowUnfree = true;

    # Overriding packages
    # TODO: Add my emacs packages
    packageOverrides = pkgs: {
      # Define my own Emacs
      emacs = pkgs.lib.overrideDerivation (pkgs.emacs.override {
        # Use gtk3 instead of the default gtk2
        withGTK3 = true;

        # Make sure imagemagick is a dependency because I want to look
        # at pictures in Emacs
        imagemagick = pkgs.imagemagickBig;
      }) (attrs: {});
    };
  };

  # Fonts
  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      corefonts # Microsoft free fonts
      inconsolata
      ubuntu_font_family
      dejavu_fonts
      fira-code
      fira-code-symbols
      hasklig
    ];
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.03"; # Did you read the comment?
}
