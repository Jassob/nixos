{
  description = "My NixOS configuration";

  inputs = {
    # NixOS official package source, here using the nixos-24.11 branch
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, emacs-overlay, nixos-hardware, ... }@inputs:
    let
      pkgs = (import nixpkgs { inherit system; }).pkgs;
      system = "x86_64-linux";
      # Create an overlay containing the latest available packages.
      # Accessible in configuration as "pkgs.unstable.$PKGS".
      overlay-unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      };
      overlay-emacs = emacs-overlay.overlays.default;
    in
    {
      formatter.${system} = pkgs.nixpkgs-fmt;

      nixosConfigurations.jassob-XPS-13 = nixpkgs.lib.nixosSystem {
        specialArgs = inputs;
        modules = [
          # overlays
          ({ config, pkgs, ... }: {
            nixpkgs.overlays = [ overlay-unstable overlay-emacs ];
          })
          {
            services.displayManager.defaultSession = "none+xmonad";

            # Enable touchpad support (enabled default in most desktopManager).
            services.libinput.enable = true;
            services.libinput.touchpad.disableWhileTyping = true;

            # Hibernate after closing lid
            services.logind.settings.Login.HandleLidSwitch = "hibernate";

            networking.hostName = "jassob-XPS-13";
            networking.interfaces.wlp164s0.useDHCP = true;

            # This value determines the NixOS release from which the default
            # settings for stateful data, like file locations and database versions
            # on your system were taken. It‘s perfectly fine and recommended to leave
            # this value at the release version of the first install of this system.
            # Before changing this value read the documentation for this option
            # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
            system.stateVersion = "21.11"; # Did you read the comment?
            home-manager.users.jassob.home.stateVersion = "21.11"; # See comment for system.stateVersion
          }
          ./configuration.nix
          ./desktop.nix
          ./hardware-configurations/xps-13.nix
          ./xmonad.nix
          nixos-hardware.nixosModules.dell-xps-13-9300
        ];
      };

      nixosConfigurations.nuc = nixpkgs.lib.nixosSystem {
        specialArgs = inputs;
        modules = [
          # overlays
          ({ config, pkgs, ... }: {
            nixpkgs.overlays = [ overlay-unstable overlay-emacs ];
          })
          {
            boot.kernelPackages = pkgs.linuxPackages_latest;
            networking.hostName = "nuc";
          }

          {
            # This value determines the NixOS release from which the default
            # settings for stateful data, like file locations and database versions
            # on your system were taken. It‘s perfectly fine and recommended to leave
            # this value at the release version of the first install of this system.
            # Before changing this value read the documentation for this option
            # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
            system.stateVersion = "25.11"; # Did you read the comment?
            home-manager.users.jassob.home.stateVersion = "25.11"; # See comment for system.stateVersion
          }
          ./configuration.nix
          ./server.nix
          ./hardware-configurations/nuc.nix
        ];
      };
    };
}
