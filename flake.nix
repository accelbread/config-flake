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
    with self.inputs;
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = nixpkgs.lib.singleton emacs-overlay.overlays.default;
      };
    in {
      legacyPackages.x86_64-linux = pkgs;
      nixosConfigurations.shadowfang = nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        modules = [
          nixos-hardware.nixosModules.framework
          impermanence.nixosModules.impermanence
          home-manager.nixosModules.home-manager
          (import ./set-flakes.nix inputs)
          ./configuration.nix
        ];
      };
      apps.x86_64-linux = import ./provisioning-scripts.nix pkgs;
    };
}

