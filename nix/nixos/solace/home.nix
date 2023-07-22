{ lib, ... }: {
  dconf.settings = {
    "org/gnome/desktop/peripherals/touchpad" = { speed = 0.6; };
    "org/gnome/settings-daemon/plugins/power" = {
      power-button-action = "interactive";
      sleep-inactive-ac-type = "nothing";
    };
  };
  home.activation.wireplumberDefaults =
    let
      defaultNodes = builtins.toFile "wireplumber-default-nodes" ''
        [default-nodes]
        default.configured.audio.sink=bluez_output.88_C9_E8_1F_5A_99.1
        default.configured.audio.sink.0=bluez_output.88_C9_E8_1F_5A_99.1
        default.configured.audio.sink.1=alsa_output.pci-0000_0f_00.4.analog-stereo
        default.configured.audio.source=rnnoise_source
        default.configured.audio.source.0=rnnoise_source
        default.configured.audio.source.1=alsa_input.usb-Elgato_Systems_Elgato_Wave_XLR_DS16M2A00891-00.mono-fallback
      '';
      defaultRoutes = builtins.toFile "wireplumber-default-routes" ''
        [default-routes]
        alsa_card.usb-Elgato_Systems_Elgato_Wave_XLR_DS16M2A00891-00:input:analog-input-mic:channelMap=MONO;
        alsa_card.usb-Elgato_Systems_Elgato_Wave_XLR_DS16M2A00891-00:input:analog-input-mic:channelVolumes=0.01;
        alsa_card.usb-Elgato_Systems_Elgato_Wave_XLR_DS16M2A00891-00:input:analog-input-mic:latencyOffsetNsec=0
        alsa_card.usb-Elgato_Systems_Elgato_Wave_XLR_DS16M2A00891-00:profile:output:analog-stereo+input:mono-fallback=analog-input-mic;
      '';
    in
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD mkdir -p "$HOME/.local/state/wireplumber"
      $DRY_RUN_CMD cat ${defaultNodes} \
        > "$HOME/.local/state/wireplumber/default-nodes"
      $DRY_RUN_CMD cat ${defaultRoutes} \
        > "$HOME/.local/state/wireplumber/default-routes"
    '';
}
