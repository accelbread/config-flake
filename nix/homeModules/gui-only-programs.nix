{ config, pkgs, lib, ... }:
let
  inherit (lib) mkOption types;

  fixedDesktopDrv = drv: pkgs.runCommand (drv.name + "-desktop") { } ''
    mkdir -p $out/share
    cp -Lr ${drv}/share/applications $out/share
    chmod -R +w $out/share
    sed -i 's|Exec=|Exec=${drv}/bin/|' $out/share/applications/*
  '';

  guiOnlyWrapDrv = drv: pkgs.symlinkJoin {
    name = drv.name + "-guiOnly";
    paths = [ (fixedDesktopDrv drv) drv ];
    postBuild = "rm -rf $out/bin $out/sbin";
  };
in
{
  options.home.gui-packages = mkOption {
    type = types.listOf types.package;
    default = [ ];
    description = "Packages to use without adding to PATH.";
  };

  config.home.packages = map guiOnlyWrapDrv config.home.gui-packages;
}
