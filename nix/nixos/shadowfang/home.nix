{ lib, pkgs, ... }: {
  nixGL.package = pkgs.nixgl.nixGLIntel;

  dconf.settings = {
    "org/gnome/desktop/peripherals/touchpad" = {
      speed = 0.4;
      tap-to-click = true;
    };
    "org/gnome/settings-daemon/plugins/power" = {
      power-button-action = "interactive";
      sleep-inactive-ac-timeout = 900;
      sleep-inactive-ac-type = "hibernate";
      sleep-inactive-battery-timeout = 900;
      sleep-inactive-battery-type = "hibernate";
    };
  };

  home.activation.wireplumberDefaults =
    let
      defaultNodes = builtins.toFile "wireplumber-default-nodes" ''
        [default-nodes]
        default.configured.audio.source=alsa_input.pci-0000_00_1f.3.analog-stereo
        default.configured.audio.source.0=alsa_input.pci-0000_00_1f.3.analog-stereo
      '';
    in
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD mkdir -p "$HOME/.local/state/wireplumber"
      $DRY_RUN_CMD cat ${defaultNodes} \
        > "$HOME/.local/state/wireplumber/default-nodes"
    '';
}
