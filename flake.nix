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
    flake-utils.url = "github:numtide/flake-utils";
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        flake-utils.follows = "flake-utils";
      };
    };
  };
  outputs = { self, ... }@inputs:
    with self.inputs; rec {
      legacyPackages.x86_64-linux = import nixpkgs {
        system = "x86_64-linux";
        overlays = nixpkgs.lib.singleton (final: prev: {
          unstable = nixpkgs-unstable.legacyPackages.${prev.system};
          emacs-overlay = emacs-overlay.packages.${prev.system};
        });
      };
      nixosConfigurations.shadowfang = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        pkgs = legacyPackages.x86_64-linux;
        modules = [
          nixos-hardware.nixosModules.framework
          impermanence.nixosModules.impermanence
          home-manager.nixosModules.home-manager
          (import ./set-flakes.nix inputs)
          ./configuration.nix
        ];
      };
    };
}

