{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
    impermanence.url =
      "github:nix-community/impermanence/23c1f06316b67cb5dabdfe2973da3785cfe9c34a";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { flakelight, ... }@inputs:
    flakelight ./. {
      imports = [ inputs.flakelight-elisp.flakelightModules.default ];
      inherit inputs;
      withOverlays = [
        inputs.nixgl.overlays.default
        inputs.emacs-overlay.overlays.package
        inputs.self.overlays.overrides
      ];
      checks.statix = pkgs: "${pkgs.statix}/bin/statix check";
      legacyPackages = pkgs: pkgs;
      formatters = pkgs: {
        "*.js" = "${pkgs.nodePackages.prettier}/bin/prettier --write";
      };
    };
  nixConfig.commit-lockfile-summary = "flake: Update inputs";
}
