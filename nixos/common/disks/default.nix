{ config, pkgs, lib, hostname, ... }:
let
  inherit (builtins) match mapAttrs listToAttrs head;
  cfg = config.sysconfig.disks;
  partHasP = disk: match "/dev/sd." disk == null;
  getPartPrefix = disk: disk + lib.optionalString (partHasP disk) "p";
  getPart = part: disk: getPartPrefix disk + toString part;
  eachDevice = f: lib.zipListsWith f (lib.range 1 100) cfg.devices;
in
{
  options.sysconfig.disks = with lib; {
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
    boot.initrd.luks.devices = listToAttrs (eachDevice
      (n: d: {
        name = "${hostname}_disk${toString n}";
        value = {
          device = getPart 2 d;
          bypassWorkqueues = true;
        };
      }));

    swapDevices = eachDevice
      (n: _: { device = "/dev/${hostname}_vg${toString n}/swap"; });

    fileSystems =
      let
        setSharedOpts = v: v // {
          options = v.options or [ ] ++ [ "noatime" "nosuid" "nodev" ];
        };
        mkBtrfs = v: v // {
          device = "/dev/${hostname}_vg1/pool";
          fsType = "btrfs";
          options = v.options or [ ] ++ [
            "subvol=${v.device}"
            "compress=zstd"
            "autodefrag"
            "user_subvol_rm_allowed"
          ];
        };
      in
      mapAttrs (_: setSharedOpts) ({
        "/boot" = {
          device = getPart 1 (head cfg.devices);
          fsType = "vfat";
          options = [ "noexec" ];
        };
      } // mapAttrs (_: mkBtrfs) {
        "/".device = "root";
        "/nix".device = "nix";
        "/persist" = {
          device = "persist";
          neededForBoot = true;
        };
      });

    services = {
      btrfs.autoScrub = {
        enable = true;
        interval = "weekly";
        fileSystems = [ "/" ];
      };
      btrbk.instances.btrbk = {
        onCalendar = "*:0/10";
        settings = {
          timestamp_format = "long";
          volume."/persist" = {
            subvolume = "home";
            snapshot_dir = ".snapshots";
            snapshot_preserve_min = "4h";
            snapshot_preserve = "48h 14d 4w";
          };
        };
      };
    };

    system.build.provisionScript = pkgs.substituteAll {
      src = ./provision-disks;
      isExecutable = true;
      inherit hostname;
      inherit (cfg) devices size swap;
      devicesPart = map getPartPrefix cfg.devices;
      path = lib.makeBinPath (with pkgs; [
        coreutils
        util-linux
        parted
        dosfstools
        cryptsetup
        lvm2
        btrfs-progs
        mkpasswd
      ]);
    };

    system.build.mountScript = pkgs.substituteAll {
      src = ./mount-disks;
      isExecutable = true;
      inherit hostname;
      devicesPart = map getPartPrefix cfg.devices;
      path = lib.makeBinPath (with pkgs; [
        coreutils
        util-linux
        cryptsetup
      ]);
    };
  };
}
