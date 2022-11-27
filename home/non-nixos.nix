{ config, pkgs, lib, flakes, ... }:
let
  inherit (builtins) mapAttrs readDir;

  nixGLWrapDrv = drv: pkgs.symlinkJoin {
    name = (drv.name + "-nixGLWrapper");
    paths = (map
      (bin: pkgs.writeShellScriptBin bin ''
        exec ${pkgs.nixgl.nixGLIntel}/bin/nixGLIntel ${drv}/bin/${bin} "$@"
      '')
      (attrNames (readDir "${drv}/bin"))
    ) ++ [ drv ];
  };
in
{
  imports = [ ./common.nix ];

  options = {
    nixGLPackages = mkOption {
      type = types.listOf types.string;
      default = [ ];
      description = "Packages to wrap with nixGL.";
    };
  };

  config = {
    nix = {
      package = pkgs.nix;
      registry = mapAttrs (_: v: { flake = v; }) flakes;
      settings.experimental-features = "nix-command flakes";
    };

    nixpkgs.overlays = [
      flakes.nixgl.overlays.default
      (final: prev: lib.genAttrs config.nixGLPackages
        (pkg: nixGLWrapDrv prev.${pkg}))
    ];

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

    nixGLPackages = [ "zeal" ];

    programs.home-manager.enable = true;
  };
}
