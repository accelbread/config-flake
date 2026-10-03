# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
{
  config,
  lib,
  pkgs,
  inputs,
  flake,
  ...
}:
let
  inherit (builtins)
    unsafeDiscardStringContext
    ;
  inherit (lib)
    concatStringsSep
    flip
    genAttrs
    genAttrs'
    hasPrefix
    mapAttrs
    mapAttrsToList
    mkForce
    nameValuePair
    removePrefix
    toUpper
    ;
  inherit (lib.filesystem) listFilesRecursive;

  manualPages =
    pkgs.runCommandLocal "man-pages" { __contentAddressed = true; }
      "cp -rL ${
        pkgs.buildEnv {
          name = "man-paths";
          paths = config.users.users.archit.packages;
          pathsToLink = [ "/share/man" ];
          extraOutputsToInstall = [ "man" ];
          ignoreCollisions = true;
          derivationArgs.__contentAddressed = true;
        }
      } $out";

  passSettings = {
    dir = "/home/archit/.local/share/pass/";
    clip_time = 10;
    generated_length = 16;
    signing_key = "C4F4D63E4C22651B053D0848DE26C77562110E92";
  };
  pass =
    (pkgs.pass-wayland.withExtensions (exts: [ exts.pass-otp ])).overrideAttrs
      (old: {
        postBuild = old.postBuild + ''
          wrapProgram $out/bin/pass \
            ${concatStringsSep " \\\n" (
              mapAttrsToList (
                k: v: "--set-default PASSWORD_STORE_${toUpper k} ${toString v}"
              ) passSettings
            )}
        '';
      });
in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.hjem.nixosModules.default
  ];

  users.users.archit = {
    extraGroups = [
      "dialout"
      "wireshark"
      "video"
      "render"
      "audio"
    ];
    packages = [
      pass
    ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.archit = inputs.self.homeModules.nixos;
    extraSpecialArgs = { inherit inputs; };
  };

  hjem.users.archit = {
    clobberFiles = true;
    files =
      let
        dotDir = flake.src + /dotfiles;
        pathToTarget =
          p:
          toString p
          |> removePrefix "${toString dotDir}/"
          |> unsafeDiscardStringContext
          |> (p: if hasPrefix "_" p then ".${removePrefix "_" p}" else p);
      in
      (genAttrs' (listFilesRecursive dotDir) (
        p: nameValuePair (pathToTarget p) { source = p; }
      ))
      // mapAttrs (_: v: { source = v; }) {
        ".face" = flake.src + /misc/icon.png;
        ".librewolf/native-messaging-hosts/passff.json" =
          (pkgs.passff-host.override { inherit pass; })
          + /lib/librewolf/native-messaging-hosts/passff.json;
        ".librewolf/profile/chrome/firefox-gnome-theme" = pkgs.firefox-gnome-theme;
        ".thunderbird/profile/chrome/thunderbird-gnome-theme" =
          pkgs.thunderbird-gnome-theme;
        ".config/pipewire/pipewire.conf.d/99-input-denoising.conf" =
          pkgs.replaceVars ./homeFiles/99-input-denoising.conf
            { rnnoisePath = pkgs.rnnoise-plugin.ladspa; };
        ".config/celluloid/scripts" =
          pkgs.buildEnv {
            name = "mpv-scripts";
            pathsToLink = [ "/share/mpv/scripts" ];
            paths = with pkgs.mpvScripts; [
              autoload
              mpris
              sponsorblock-minimal
            ];
          }
          + /share/mpv/scripts;
      }
      // {
        ".manpath".text = ''
          MANDB_MAP /etc/profiles/per-user/archit/share/man ${
            pkgs.runCommand "man-cache" { nativeBuildInputs = [ pkgs.man-db ]; } ''
              echo "MANDB_MAP ${manualPages}/share/man $out" > man.conf
              mandb -C man.conf --no-straycats --create ${manualPages}/share/man
            ''
          }
        '';
        ".config/gtk-3.0/gtk.css".text = ''
          @define-color accent_bg_color #9141ac;
        '';
        ".config/gtk-4.0/gtk.css".text = ''
          :root { --accent-bg-color: var(--accent-purple); }
        '';
        ".config/GIMP/3.0/gimprc" = {
          type = "copy";
          text = ''
            (theme "System")
          '';
        };
      };
    systemd.services = {
      pass-initialize = {
        description = "Configure pass";
        wantedBy = [ "default.target" ];
        path = [ pass ];
        script = ''
          if [[ ! -e ${passSettings.dir}/.git ]]; then
            mkdir -p ${passSettings.dir}
            pass git init
            pass git remote add \
              aws ssh://git-codecommit.us-west-2.amazonaws.com/v1/repos/pass
          fi
          pass git remote set-url \
            aws ssh://git-codecommit.us-west-2.amazonaws.com/v1/repos/pass
          pass git config remote.pushDefault aws
          pass git config pass.signcommits true
          pass git config user.signingkey ${passSettings.signing_key}
        '';
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
      };
      set-album-arts = {
        description = "Set album arts";
        wantedBy = [ "graphical-session.target" ];
        path = [
          pkgs.bash
          pkgs.glib
          pkgs.ffmpeg-headless
        ];
        serviceConfig = {
          ExecStart = "${./homeFiles/set-album-arts}";
          Type = "oneshot";
        };
      };
      local-api-proxy = {
        description = "Local proxy for authenticated APIs";
        wantedBy = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        after = [
          "graphical-session.target"
          "dbus.socket"
        ];
        path = [
          pkgs.bash
          pkgs.caddy
          pkgs.libsecret
        ];
        serviceConfig = {
          ExecStart = "${./homeFiles/local-api-proxy}";
          Type = "exec";
          Restart = "on-failure";
          RestartSec = 5;
        };
      };
    };
  };

  systemd.tmpfiles.settings = {
    preservation = flip genAttrs (_: { d.mode = mkForce "0700"; }) [
      "/home/archit/.ssh"
      "/home/archit/.librewolf"
      "/home/archit/.thunderbird"
    ];
    playground."/home/archit/Projects/Playground".v = {
      mode = "0700";
      user = "archit";
      group = config.users.users.archit.group;
    };
  };

  preservation.preserveAt =
    let
      dir = mode: d: {
        directory = d;
        inherit mode;
      };
      file = mode: f: {
        file = f;
        inherit mode;
      };
    in
    {
      data.users.archit.directories = map (dir "0700") [
        "Documents"
        "Music"
        "Pictures"
        "Videos"
        "Library"
      ];
      state.users.archit = {
        directories =
          map (dir "0700") [
            "Projects"
            ".config/emacs"
            ".librewolf/profile"
            ".thunderbird/profile"
            ".local/share/keyrings"
            ".local/share/vault"
            ".local/share/gnupg"
            ".local/share/pass"
            ".local/share/fractal"
            ".var/app/com.valvesoftware.Steam"
          ]
          ++ map (dir "0755") [
            ".local/share/icc"
          ];
        files = map (file "0600") [
          ".ssh/id_ed25519_sk"
          ".ssh/id_ed25519_sk-cert.pub"
        ];
      };
      cache.users.archit.directories = map (dir "0700") [
        "Downloads"
        ".cache/fractal"
        ".local/share/flatpak"
      ];
    };
}
