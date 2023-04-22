{ config, pkgs, lib, inputs, ... }:
let
  inherit (builtins) mapAttrs readDir attrNames;
  inherit (lib) mkOption types;
  system = pkgs.stdenv.hostPlatform.system;
  pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages.${system};

  nixGLWrapDrv = drv: pkgs.symlinkJoin {
    name = (drv.name + "-nixGLWrapper");
    paths = (map
      (bin: pkgs.writeShellScriptBin bin ''
        exec ${lib.getExe config.nixGL.package} ${drv}/bin/${bin} "$@"
      '')
      (attrNames (readDir "${drv}/bin"))
    ) ++ [ drv ];
  };
in
{
  imports = [ ./common.nix ];

  options = {
    nixGL = {
      package = mkOption {
        type = types.package;
        default = pkgs.nixgl.nixGLMesa;
      };
      wrappedPackages = mkOption {
        type = types.listOf types.string;
        default = [ ];
        description = "Packages to wrap with nixGL.";
      };
    };
  };

  config = {
    nix = {
      package = pkgs.nix;
      registry = mapAttrs (_: v: { flake = v; }) inputs;
      settings = {
        experimental-features = "nix-command flakes";
        keep-outputs = true;
      };
    };

    nixpkgs.overlays = [
      inputs.nixgl.overlays.default
      (final: prev: lib.genAttrs config.nixGL.wrappedPackages
        (pkg: nixGLWrapDrv prev.${pkg}))
    ];

    home = {
      packages = with pkgs-unstable; [
        dejavu_fonts
        liberation_ttf
        noto-fonts
        noto-fonts-extra
        noto-fonts-cjk-sans
        noto-fonts-emoji
      ];
    };

    nixGL.wrappedPackages = [ "zeal" ];

    programs.home-manager.enable = true;
  };
}
