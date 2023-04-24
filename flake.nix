{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flakelite = {
      url = "github:accelbread/flakelite";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flakelite-elisp.url = "github:accelbread/flakelite-elisp";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay/2afeb0596418d37aa3feb7203cc37a11c10c83fe";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = {
      url = "github:guibou/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { flakelite, emacs-overlay, ... }@inputs:
    flakelite ./. {
      inherit inputs;
      withOverlays = [
        emacs-overlay.overlays.default
        (import ./nix/overlays/overrides.nix)
      ];
    };
  nixConfig.commit-lockfile-summary = "flake: Update inputs";
}
