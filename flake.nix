{
  description = "My NixOS configuration";

  inputs = {
    # NixOS official package source, here using the nixos-24.11 branch
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, emacs-overlay, ... }@inputs:
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
        system = system;
        modules = [
          # overlays
          ({ config, pkgs, ... }: {
            nixpkgs.overlays = [ overlay-unstable overlay-emacs ];
          })
          { networking.hostName = "jassob-XPS-13"; }
          {
            # Enable new nix commands and flakes
            nix.settings.experimental-features = "nix-command flakes";
            nixpkgs.config.allowUnfree = true;
            nixpkgs.config.permittedInsecurePackages = [ "electron-27.3.11" ];
          }
          ./configuration.nix
        ];
      };
    };
}
