{ config, lib, pkgs, ... }: {
  environment.systemPackages = [ pkgs.bindfs ];
  fileSystems = lib.mapAttrs
    (_: v: v // {
      fsType = "fuse.bindfs";
      options = [ "ro" "resolve-symlinks" "x-gvfs-hide" ];
      noCheck = true;
    })
    {
      "/usr/share/icons".device = "/run/current-system/sw/share/icons";
      "/usr/share/fonts".device = pkgs.buildEnv
        {
          name = "system-fonts";
          paths = config.fonts.fonts;
          pathsToLink = [ "/share/fonts" ];
        } + "/share/fonts";
    };
}
