# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
{
  config,
  lib,
  hostname,
  ...
}:
let
  inherit (builtins)
    match
    mapAttrs
    listToAttrs
    head
    ;
  inherit (lib) nameValuePair mergeAttrs;

  cfg = config.ab.disks;
  partHasP = disk: match "/dev/sd." disk == null;
  getPartPrefix = disk: disk + lib.optionalString (partHasP disk) "p";
  getPart = part: disk: getPartPrefix disk + toString part;
  eachDevice = f: lib.zipListsWith f (lib.range 1 100) cfg.devices;
in
{
  options.ab.disks = with lib; {
    devices = mkOption {
      type = types.listOf types.str;
      description = "List of devices to use for standard disk layout.";
      default = [ ];
    };
    size = mkOption {
      type = types.str;
      description = "Amount of each device to use, in parted format.";
      default = "100%";
    };
    swap = mkOption {
      type = types.str;
      description = "Size for swap lvs, in lvcreate format.";
      default = "16g";
    };
  };

  config = lib.mkIf (cfg.devices != [ ]) {
    boot = {
      initrd = {
        kernelModules = [ "dm_mod" ];
        luks = {
          devices = listToAttrs (
            eachDevice (
              n: d:
              nameValuePair "${hostname}_disk${toString n}" {
                device = getPart 2 d;
                allowDiscards = true;
                bypassWorkqueues = true;
              }
            )
          );
          cryptoModules = [
            "aes"
            "xts"
            "sha256"
            "input_leds"
          ];
        };
        systemd.settings.Manager.DefaultDeviceTimeoutSec = "infinity";
      };
      swraid.enable = false;
      bcache.enable = false;
      specialFileSystems = {
        "/dev".options = [ "noexec" ];
        "/dev/shm".options = [ "noexec" ];
        "/run".options = [ "noexec" ];
      };
    };

    swapDevices = eachDevice (
      n: _: { device = "/dev/${hostname}_vg${toString n}/swap"; }
    );

    fileSystems =
      let
        setSharedOpts =
          v:
          mergeAttrs v {
            options = v.options or [ ] ++ [
              "noatime"
              "nosuid"
              "nodev"
            ];
          };
        mkBtrfs =
          v:
          mergeAttrs v {
            device = "/dev/${hostname}_vg1/pool";
            fsType = "btrfs";
            options = v.options or [ ] ++ [
              "subvol=${v.device}"
              "compress=zstd"
              "user_subvol_rm_allowed"
            ];
          };
      in
      mapAttrs (_: setSharedOpts) (
        {
          "/boot" = {
            device = getPart 1 (head cfg.devices);
            fsType = "vfat";
            options = [
              "noexec"
              "umask=0077"
            ];
          };
          "/var/pool_root" = {
            device = "/dev/${hostname}_vg1/pool";
            fsType = "btrfs";
            options = [
              "noauto"
              "compress=zstd"
              "user_subvol_rm_allowed"
            ];
          };
        }
        // mapAttrs (_: mkBtrfs) {
          "/".device = "root";
          "/nix".device = "nix";
          "/persist" = {
            device = "persist";
            neededForBoot = true;
          };
        }
      );
  };
}
