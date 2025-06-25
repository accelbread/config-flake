{ lib, pkgs, ... }: {
  nixGL.package = pkgs.nixgl.nixGLIntel;

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
