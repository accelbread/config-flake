{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flakelight = {
      url = "github:nix-community/flakelight";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flakelight-elisp = {
      url = "github:accelbread/flakelight-elisp";
      inputs.flakelight.follows = "flakelight";
    };
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
  outputs = { self, flakelight, flakelight-elisp, emacs-overlay, ... }@inputs:
    flakelight ./. {
      imports = [ flakelight-elisp.flakelightModules.default ];
      inherit inputs;
      withOverlays = [
        emacs-overlay.overlays.package
        self.overlays.overrides
      ];
      devShell.packages = pkgs: with pkgs; [ esphome mqttui ];
      checks.statix = pkgs: "${pkgs.statix}/bin/statix check";
    };
  nixConfig.commit-lockfile-summary = "flake: Update inputs";
}
