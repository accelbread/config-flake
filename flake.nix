{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    flakelite = {
      url = "github:accelbread/flakelite";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flakelite-elisp.url = "github:accelbread/flakelite-elisp";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nixgl = {
      url = "github:guibou/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, flakelite, emacs-overlay, ... }@inputs:
    with flakelite.lib; mkFlake ./. inputs {
      withOverlays = [
        emacs-overlay.overlays.default
        (import ./overlays/overrides.nix)
      ];
      packages = loadNixDir ./packages;
      elispPackages = loadNixDir ./packages/elisp-packages;
      overlays = loadNixDir ./overlays;
      apps = pkgs: import ./apps self pkgs;
      nixosModules = import ./home;
      nixosConfigurations = import ./nixos inputs;
      templates = import ./templates;
    };
}
