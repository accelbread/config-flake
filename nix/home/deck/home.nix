{ pkgs, lib, ... }: {
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg)
    [ "steam-run" "steam-original" ];

  home = {
    sessionVariables = {
      BROWSER = "librewolf";
      MOZ_ENABLE_WAYLAND = "1";
      MOZ_USE_XINPUT2 = "1";
    };
    gui-packages = with pkgs; [
      librewolf
      ungoogled-chromium
      protontricks
    ];
    activation.kdeRebuild = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      /usr/bin/kbuildsycoca5 --noincremental
    '';
  };
}
