{ lib, pkgs, ... }: {
  nixgl.package = pkgs.nixgl.nixGLIntel;

  home.activation.wireplumberDefaults =
    let
      defaultNodes = builtins.toFile "wireplumber-default-nodes" ''
        [default-nodes]
        default.configured.audio.source=bluez_input.58_18_62_1E_D8_3B.0
        default.configured.audio.source.0=bluez_input.58_18_62_1E_D8_3B.0
        default.configured.audio.source.1=alsa_input.pci-0000_00_1f.3.analog-stereo
        default.configured.audio.sink=bluez_output.58_18_62_1E_D8_3B.1
        default.configured.audio.sink.0=bluez_output.58_18_62_1E_D8_3B.1
        default.configured.audio.sink.1=alsa_output.pci-0000_00_1f.3.analog-stereo
      '';
    in
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD mkdir -p "$HOME/.local/state/wireplumber"
      $DRY_RUN_CMD cat ${defaultNodes} \
        > "$HOME/.local/state/wireplumber/default-nodes"
    '';
}
