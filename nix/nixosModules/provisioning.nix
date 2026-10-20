# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
{
  config,
  pkgs,
  lib,
  hostname,
  flake,
  ...
}:
let
  inherit (builtins) match;

  diskCfg = config.ab.disks;
  partHasP = disk: match "/dev/sd." disk == null;
  getPartPrefix = disk: disk + lib.optionalString (partHasP disk) "p";
in
{
  options.ab.systemActions = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.package;
    default = { };
    description = "Scripts for system administration actions.";
  };

  config.ab.systemActions = rec {
    disk-provision = pkgs.replaceVarsWith {
      src = ./scripts/provision-disks;
      isExecutable = true;
      replacements = {
        inherit hostname;
        inherit (diskCfg) devices size swap;
        devicesPart = map getPartPrefix diskCfg.devices;
        path = lib.makeBinPath (
          with pkgs;
          [
            coreutils
            util-linux
            nvme-cli
            jq
            parted
            dosfstools
            cryptsetup
            lvm2
            btrfs-progs
            mkpasswd
          ]
        );
      };
    };

    disk-mount = pkgs.replaceVarsWith {
      src = ./scripts/mount-disks;
      isExecutable = true;
      replacements = {
        inherit hostname;
        devicesPart = map getPartPrefix diskCfg.devices;
        path = lib.makeBinPath (
          with pkgs;
          [
            coreutils
            util-linux
            cryptsetup
          ]
        );
      };
    };

    disk-unmount = pkgs.replaceVarsWith {
      src = ./scripts/unmount-disks;
      isExecutable = true;
      replacements = {
        inherit hostname;
        devicesPart = map getPartPrefix diskCfg.devices;
        path = lib.makeBinPath (
          with pkgs;
          [
            coreutils
            util-linux
            lvm2
            cryptsetup
          ]
        );
      };
    };

    install =
      with pkgs;
      writeShellScript "nixos-install" ''
        exec ${nixos-install-tools}/bin/nixos-install --flake ${src}#$1 \
          --no-root-passwd
      '';

    full-install = pkgs.writeShellScript "nixos-install" ''
      ${disk-provision} $1
      ${disk-mount} $1
      ${install} $1
    '';

    provision-yubikey = pkgs.replaceVarsWith {
      src = ./scripts/provision-yubikey;
      isExecutable = true;
      replacements = {
        path = lib.makeBinPath [
          pkgs.yubikey-manager
        ];
      };
    };

    provision-ssh = pkgs.replaceVarsWith {
      src = ./scripts/provision-ssh;
      isExecutable = true;
      replacements = {
        path = lib.makeBinPath [
          pkgs.coreutils
          pkgs.openssh
        ];
        flake = flake.src;
        inherit (pkgs) yubico-piv-tool;
      };
    };
  };
}
