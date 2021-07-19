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
    extraModules = [ pkgs.pulseaudio-modules-bt ];

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
  console.font = "term-32n";
  console.keyMap = "sv-latin1";
  i18n.defaultLocale = "en_US.UTF-8";

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = import ./packages/system.nix { inherit pkgs; };

  powerManagement = {
    enable = true;
    powertop.enable = true;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.bash.enableCompletion = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  programs.light.enable = true;
  programs.ssh.forwardX11 = true;

  services.cron.enable = true;
  # Kill memory early
  services.earlyoom = {
    enable = true;
    freeSwapThreshold = 90; # Don't allow swapping almost at all
  };
  # Enable Flatpak
  services.flatpak.enable = true;
  # Enable Windows network shares
  services.gvfs.enable = true;
  # Restrict journald size
  services.journald.extraConfig = "SystemMaxUse=100M";
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.forwardX11 = true;
  # Enable CUPS to print documents.
  services.printing.enable = true;
  # Install emacs
  services.emacs = {
    install = true;
    defaultEditor = true;
    package = import ./packages/emacs.nix { inherit pkgs; };
  };
  services.upower.enable = true;
  systemd.services.upower.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    desktopManager.gnome3.enable = true;
    displayManager.lightdm.enable = true;
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
  };

  # Enable XDG Portal integration and use GTK portal
  xdg.portal.enable = true;

  # Define user accounts. This is the only way to add users to the
  # system since mutableUsers are false.
  users.mutableUsers = false;
  users.users.jassob = {
    description = "Jacob Jonsson";
    extraGroups = [ "wheel" "docker" "networkmanager" "video" ];
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
