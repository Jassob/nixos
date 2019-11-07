# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./machine-configuration.nix
  ];

  # Supposedly better for SSDs.
  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];

  boot.cleanTmpDir = true;

  hardware.pulseaudio = {
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

  # Enables wireless support via network-manager.
  networking.networkmanager.enable = true;
  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
  ];

  # Enable VLC to communicate with Chromecast
  networking.firewall.allowedTCPPorts = [ 8010 ];

  # Generate an immutable /etc/resolv.conf from the nameserver settings above
  environment.etc."resolv.conf" = with lib; with pkgs; {
    source = writeText "resolv.conf" ''
      ${concatStringsSep "\n" (map (ns: "nameserver ${ns}") config.networking.nameservers)}
      options edns0
    '';
  };

  # Source $HOME/.profile upon login (this is not done automatically by graphical sessions)
  environment.etc."profile.local".text =
    ''
    # /etc/profile.local: DO NOT EDIT - this file has been generated automatically.

    if test -f "$HOME/.profile"; then
       . "$HOME/.profile"
    fi
    '';

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
  environment.systemPackages = import ./packages/system.nix { inherit pkgs; };

  powerManagement = {
    enable = true;
    powertop.enable = true;
  };

  services.upower.enable = true;
  systemd.services.upower.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.bash.enableCompletion = true;
  programs.light.enable = true;

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
  services.cron.enable = true;

  # Enable Flatpak
  services.flatpak.enable = false;

  # Restrict journald size
  services.journald.extraConfig = "MaxFileSec=1week";

  # Install emacs
  services.emacs = {
    install = true;
    defaultEditor = true;
    package = import ./packages/emacs.nix { inherit pkgs; };
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;

    displayManager.lightdm.enable = true;
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

  nix.trustedUsers = [ "root" "jassob" ];
  nixpkgs.config.allowUnfree = true;

  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = true;
  virtualisation.libvirtd.qemuPackage = pkgs.qemu_kvm;

  # Fonts
  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    enableDefaultFonts = true;
    fonts = with pkgs; [
      corefonts # Microsoft free fonts
      input-fonts
      iosevka
      inconsolata
      ubuntu_font_family
      dejavu_fonts
      fira-code
      fira-code-symbols
      hasklig
    ];
  };

  # Define user accounts. This is the only way to add users to the
  # system since mutableUsers are false.
  users.mutableUsers = false;
  users.users.jassob = {
    description = "Jacob Jonsson";
    extraGroups = [ "wheel" "docker" "networkmanager" ];
    uid = 1000;
    isNormalUser = true;
    shell = pkgs.zsh;
    hashedPassword = "CREATE WITH mkpasswd -m sha-512";
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?
}
