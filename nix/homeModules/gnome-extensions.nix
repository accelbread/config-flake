{ config, lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.gnome.extensions = mkOption {
    type = types.listOf types.package;
    default = [ ];
    description = "Gnome extension packages to enable.";
  };

  config = {
    home.packages = config.gnome.extensions;

    dconf.settings."org/gnome/shell".enabled-extensions =
      map (p: p.extensionUuid) config.gnome.extensions;
  };
}
