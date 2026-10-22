# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
{
  config,
  pkgs,
  lib,
  hostname,
  flake,
  inputs,
  ...
}:
let
  inherit (builtins) match;

  diskCfg = config.ab.disks;
  partHasP = disk: match "/dev/sd." disk == null;
  getPartPrefix = disk: disk + lib.optionalString (partHasP disk) "p";
in
{
  options.ab = {
    systemActions = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.package;
      default = { };
      description = "Scripts for system administration actions.";
    };
    installerImage = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      description = "Installer ISO with pre-loaded artifacts for this system.";
    };
  };

  config.ab = {
    systemActions = rec {
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

      # Avoid flake evaluation in the initially empty target store.
      install =
        with pkgs;
        writeShellScript "nixos-install" ''
          exec ${nixos-install-tools}/bin/nixos-install \
            --system ${config.system.build.toplevel} \
            --no-root-passwd --substituters ""
        '';

      full-install = pkgs.writeShellScript "nixos-install" ''
        set -eu
        ${disk-provision}
        ${disk-mount}
        exec ${install}
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

    installerImage =
      (inputs.nixpkgs.lib.nixosSystem {
        specialArgs = { inherit (pkgs.stdenv.hostPlatform) system; };
        modules = lib.singleton (
          { pkgs, system, ... }:
          {
            imports = [
              "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix"
            ];

            isoImage.edition = "ab-installer";
            nixpkgs.hostPlatform.system = system;
            boot.kernelPackages = pkgs.linuxPackages_latest;

            nix = {
              package = pkgs.nixVersions.latest;
              registry = {
                self.flake = inputs.self;
                nixpkgs.flake = inputs.nixpkgs;
              };
              settings = {
                flake-registry = "";
                experimental-features = [
                  "nix-command"
                  "flakes"
                  "ca-derivations"
                  "pipe-operators"
                ];
              };
            };

            environment.systemPackages = lib.singleton (
              pkgs.writeShellScriptBin "sysinstall" ''
                set -euo pipefail
                case "$1" in
                  ${
                    config.ab.systemActions
                    |> lib.mapAttrsToList (
                      n: v: ''
                        ${lib.escapeShellArg n}) exec ${v};;
                      ''
                    )
                    |> lib.concatStringsSep "\n"
                  }
                esac
                exit 1
              ''
            );
          }
        );
      }).config.system.build.isoImage.overrideAttrs
        {
          # closureInfo records local hashes; package the same store contents.
          preferLocalBuild = true;
        };
  };
}
