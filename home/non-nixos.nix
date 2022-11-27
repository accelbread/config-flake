{ pkgs, flakes, ... }:
let
  inherit (builtins) mapAttrs;
in
{
  imports = [ ./common.nix ];

  nix = {
    package = pkgs.nix;
    registry = mapAttrs (_: v: { flake = v; }) flakes;
    settings.experimental-features = "nix-command flakes";
  };

  home = {
    packages = with flakes.nixpkgs-unstable.legacyPackages.x86_64-linux; [
      dejavu_fonts
      liberation_ttf
      noto-fonts
      noto-fonts-extra
      noto-fonts-cjk-sans
      noto-fonts-emoji
    ];
  };

  programs.home-manager.enable = true;
}
