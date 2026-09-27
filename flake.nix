# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
{
  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable-small/nixexprs.tar.zst";
    flakelight = {
      url = "github:nix-community/flakelight";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flakelight-elisp = {
      url = "github:accelbread/flakelight-elisp";
      inputs.flakelight.follows = "flakelight";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    preservation.url = "github:nix-community/preservation";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.1.0";
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
  outputs =
    { flakelight, ... }@inputs:
    flakelight ./. {
      imports = [ inputs.flakelight-elisp.flakelightModules.default ];
      inherit inputs;
      withOverlays = [
        inputs.nixgl.overlays.default
        inputs.emacs-overlay.overlays.package
        inputs.self.overlays.overrides
      ];
      checks = pkgs: {
        statix = "${pkgs.statix}/bin/statix check";
        reuse = "${pkgs.reuse}/bin/reuse lint";
      };
      legacyPackages = pkgs: pkgs;
      formatters = { pkgs, lib, ... }: {
        "*.nix" = "${lib.getExe pkgs.nixfmt} -w78";
        "*.md" = "${lib.getExe pkgs.mdformat} --wrap 80 --number";
        "*.json" = "${pkgs.writeShellScript "jq-fmt" ''
          ${pkgs.jq}/bin/jq . $1 | ${pkgs.moreutils}/bin/sponge $1
        ''}";
        "*.yaml" = lib.getExe pkgs.yamlfmt;
        "*.js" = "${lib.getExe pkgs.prettier} --write";
      };
    };
  nixConfig.commit-lockfile-summary = "flake: Update inputs";
}
