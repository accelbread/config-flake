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
  outputs = { self, nixpkgs, flake-utils, emacs-overlay, ... }@inputs:
    let
      inherit (flake-utils.lib) eachSystem;
      pkgsFor = system:
        import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default emacs-overlay.overlays.default ];
        };
    in eachSystem [ "x86_64-linux" ] (system:
      let pkgs = pkgsFor system;
      in {
        packages = self.overlays.default pkgs pkgs;
        apps = import ./nix/apps pkgs;
      }) // {
        overlays.default = import ./nix/overlay.nix;
        nixosConfigurations = import ./nix/nixos inputs pkgsFor;
      };
}
