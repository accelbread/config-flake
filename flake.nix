{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager/release-22.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };
  outputs = { self, ... }:
    with self.inputs; {
      nixosConfigurations.shadowfang = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-hardware.nixosModules.framework
          impermanence.nixosModules.impermanence
          home-manager.nixosModules.home-manager
          (with builtins; {
            nix.registry = mapAttrs (_: v: { flake = v; }) self.inputs;
            nixpkgs.overlays = [
              (final: prev: {
                unstable = nixpkgs-unstable.legacyPackages.${prev.system};
                emacs-overlay = emacs-overlay.packages.${prev.system};
              })
            ];
          })
          ./configuration.nix
        ];
      };
    };
}

