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
      hashedPassword = "$6$zS3RXJvKxx8XYg$p0ZJ6J7WxJBsGfqizWnLCzfLr3ljoEXvQPUy7y0KOnajgig5.1co06VvHFAOXn6UE44iswsWzxXIph.jPM5oD/";
      packages = import ./packages/jassob.nix { inherit pkgs; };
    };
  };
}
