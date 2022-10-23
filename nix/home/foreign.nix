{ config, pkgs, lib, flakes, ... }:
let
  inherit (builtins) mapAttrs;
  self = ../..;
in
{
  imports = [ ./. ];

  nix = {
    package = pkgs.nix;
    settings.experimental-features = "nix-command flakes";
  };

  home = {
    packages = (with pkgs; [
      zile
      git
      ripgrep
      fd
      tree
      jq
    ]) ++
    (with flakes.nixpkgs-unstable.legacyPackages.x86_64-linux; [
      dejavu_fonts
      liberation_ttf
      noto-fonts
      noto-fonts-extra
      noto-fonts-cjk-sans
      noto-fonts-emoji
    ]) ++ lib.singleton (pkgs.stdenv.mkDerivation {
      name = "noto-fonts-bw-emoji";
      src = pkgs.fetchzip {
        name = "noto-emoji";
        url = "https://fonts.google.com/download?family=Noto%20Emoji";
        extension = "zip";
        stripRoot = false;
        sha256 = "sha256-q7WpqAhmio2ecNGOI7eX7zFBicrsvX8bURF02Pru2rM=";
      };
      installPhase = ''
        mkdir -p $out/share/fonts/noto
        cp NotoEmoji-*.ttf $out/share/fonts/noto
      '';
    });
  };

  programs.home-manager.enable = true;
}
