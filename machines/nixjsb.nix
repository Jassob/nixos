{ config, lib, pkgs, ... }:

{
  # Define your hostname.
  networking.hostName = "nixjsb";

  # Use the GRUB 2 boot loader.
  boot.loader.grub = {
    boot.loader.grub.enable = true;
    boot.loader.grub.version = 2;
    boot.loader.grub.device = "nodev";
    boot.loader.grub.efiSupport = true;
  }

  boot.loader.efi.canTouchEfiVariables = true;

  # hid_apple is loaded in initrd
  boot.kernelParams =
    [ "hid_apple.fnmode=2" ];

  boot.extraModprobeConfig =
  ''
    options libata.force=noncq
    options snd_hda_intel index=0 model=intel-mac-auto id=PCH
    options snd_hda_intel index=1 model=intel-mac-auto id=HDMI
    options snd_hda_intel model=mbp101
  '';

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
    enableAllFirmware = true;

    opengl.extraPackages = [ pkgs.vaapiIntel ];
    opengl.driSupport32Bit = true;
  };

  services.xserver.libinput.enable = false;
  services.xserver.synaptics = {
    enable = true;
    twoFingerScroll = true;
    buttonsMap = [ 1 3 2 ];
    tapButtons = false;
    accelFactor = "0.0055";
    minSpeed = "0.95";
    maxSpeed = "1.15";
    palmDetect = true;
    palmMinWidth = 10;
    # seems to default to 70 and 75
    additionalOptions =
    ''
      Option "FingerLow" "80"
      Option "FingerHigh" "85"
    '';
  };
}
