{ config, lib, pkgs, ...}:

{
  # Define your hostname.
  networking.hostName = "nixbook";

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Register our boot device
  boot.initrd.luks.devices = {
    root = {
      device = "/dev/disk/by-uuid/c044de00-e58b-49e8-8a06-47fdf6ec439b";
      preLVM = true;
      allowDiscards = true;
    };
  };

  # Enable accelerated video playback
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  hardware = {
    bluetooth.enable = true;
    cpu.intel.updateMicrocode = true;

    opengl.extraPackages = [ pkgs.vaapiIntel pkgs.intel-media-driver ];
    opengl.driSupport32Bit = true;
   };

  services.xserver.libinput = {
    enable = true;
    naturalScrolling = true;
    tapping = false;
  };
}
