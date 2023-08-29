{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flakelight = {
      url = "github:accelbread/flakelight";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flakelight-elisp.url = "github:accelbread/flakelight-elisp";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = {
      url = "github:guibou/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { flakelight, flakelight-elisp, emacs-overlay, ... }@inputs:
    flakelight ./. {
      imports = [ flakelight-elisp.flakelightModules.default ];
      inherit inputs;
      withOverlays = [
        emacs-overlay.overlays.default
        (import ./nix/overlays/overrides.nix)
      ];
    };
  nixConfig.commit-lockfile-summary = "flake: Update inputs";
}
