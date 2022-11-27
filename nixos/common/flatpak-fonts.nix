{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.flatpak;
  flatpakFonts = pkgs.runCommand "flatpak-fonts-dir"
    { preferLocalBuild = true; }
    ''
      mkdir -p "$out"
      font_regexp='.*\.\(ttf\|ttc\|otf\|pcf\|pfa\|pfb\|bdf\)\(\.gz\)?'
      find ${toString config.fonts.fonts} -regex "$font_regexp" \
        -exec cp '{}' "$out" \;
      cd "$out"
      ${optionalString cfg.fonts-dir.decompressFonts ''
        ${pkgs.gzip}/bin/gunzip -f *.gz
      ''}
      ${pkgs.xorg.mkfontscale}/bin/mkfontscale
      ${pkgs.xorg.mkfontdir}/bin/mkfontdir
      cat $(find ${pkgs.xorg.fontalias}/ -name fonts.alias) >fonts.alias
    '';
in
{
  options.services.flatpak.fonts-dir = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to create a directory with a copy of each system font for use
        as the Flatpak system font dir.
      '';
    };
    decompressFonts = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to decompress fonts in the Flatpak system font dir.
      '';
    };
  };

  config = mkIf (cfg.enable && cfg.fonts-dir.enable) {
    nixpkgs.overlays = [
      (final: prev: {
        flatpak = prev.flatpak.overrideAttrs (finalAttrs: prevAttrs: {
          configureFlags = prevAttrs.configureFlags ++ [
            "--with-system-fonts-dir=${flatpakFonts}"
          ];
        });
      })
    ];
  };
}
