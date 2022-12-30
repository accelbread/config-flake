{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        utils.follows = "flake-utils";
      };
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
    nixgl = {
      url = "github:guibou/nixGL";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };
  outputs = { self, nixpkgs, flake-utils, emacs-overlay, ... }@inputs:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ]
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ emacs-overlay.overlays.default self.overlays.default ];
          };
        in
        {
          packages = with pkgs.lib; pipe (self.overlays.default pkgs pkgs) [
            attrNames
            (flip genAttrs (p: pkgs.${p}))
            (filterAttrs (_: isDerivation))
          ];
          apps = import ./apps self pkgs;
          formatter = pkgs.nixpkgs-fmt;
        })
    // {
      overlays = import ./overlays;
      nixosConfigurations = import ./nixos inputs;
      nixosModules = import ./home;
      templates = import ./templates;
    };
}
