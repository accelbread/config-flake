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
    flip
    genAttrs
    genAttrs'
    hasPrefix
    mapAttrs
    mkForce
    nameValuePair
    removePrefix
    ;
  inherit (lib.filesystem) listFilesRecursive;

  pass = pkgs.pass-wayland.withExtensions (exts: [ exts.pass-otp ]);
in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.hjem.nixosModules.default
  ];

  users.users.archit.extraGroups = [
    "dialout"
    "wireshark"
    "video"
    "render"
    "audio"
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.archit = inputs.self.homeModules.nixos;
    extraSpecialArgs = { inherit inputs; };
  };

  hjem = {
    clobberByDefault = true;
    users.archit.files =
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
        ".local/state/codex/model_catalog.json" =
          pkgs.runCommand "codex-openrouter-model-catalog.json"
            { nativeBuildInputs = [ pkgs.jq ]; }
            ''
              jq '
                def openrouter_models: [
                  "gpt-5.6-luna",
                  "gpt-5.6-sol",
                  "gpt-6-luna",
                  "gpt-6-sol",
                  "gpt-6-astra"
                ];
                .models = [
                  .models[]
                  | .slug as $slug
                  | select(openrouter_models | index($slug))
                  | .slug = "openai/\($slug):floor"
                  | .supported_reasoning_levels |= map(select(.effort != "ultra"))
                  | .use_responses_lite = false
                  | .prefer_websockets = false
                  | .supports_search_tool = false
                  | .service_tiers = []
                  | del(.available_in_plans, .multi_agent_version, .tool_mode)
                ]
              ' ${pkgs.codex.src}/codex-rs/models-manager/models.json > "$out"
            '';
      }
      // {
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
            ".ssh/config.d"
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
