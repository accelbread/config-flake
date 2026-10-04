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
  inherit (lib)
    catAttrs
    concat
    concatLists
    concatStrings
    concatStringsSep
    elemAt
    escapeShellArg
    flip
    fromHexString
    genAttrs
    genAttrs'
    hasPrefix
    hashString
    mapAttrsToList
    mkForce
    mkMerge
    removePrefix
    replaceStrings
    replicate
    stringToCharacters
    substring
    takeEnd
    toBaseDigits
    toUpper
    unsafeDiscardStringContext
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

  guiOnlyWrapper =
    pkg:
    pkgs.symlinkJoin {
      name = pkg.name + "-guiOnly";
      paths = [
        (pkgs.runCommand (pkg.name + "-desktop") { } ''
          mkdir -p $out/share
          cp -Lr ${pkg}/share/applications $out/share
          chmod -R +w $out/share
          sed -i 's|Exec=|Exec=${pkg}/bin/|' $out/share/applications/*
        '')
        pkg
      ];
      postBuild = "rm -rf $out/bin $out/sbin";
    };

  gnomeExtensions = with pkgs.gnomeExtensions; [
    caffeine
    hide-universal-access
    tiling-assistant
  ];

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

  sessionVariables = {
    BROWSER = "librewolf";
    DICTDIR = "${pkgs.hunspellDicts.en_US}/share/hunspell";
    GNUPGHOME = "/home/archit/.local/share/gnupg";
    CODEX_HOME = "/home/archit/.local/state/codex";
  };
in
{
  imports = [
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
    packages =
      (with pkgs; [
        emacsAccelbread
        librewolf
        wl-clipboard
        hunspellDicts.en_US
        man-pages
        man-pages-posix
        glibcInfo
        gnumake.info
        gcc_latest.info
        binutils.info
        guile.info
        file
        bind.dnsutils
        gnutar
        moreutils
        ripgrep
        fd
        tree
        jq
        gdb
        podman
        bubblewrap
        strace
        parted
        gnupg
        git-lfs
        awscli2
        gocryptfs
        libsecret
        rsgain
        flac
        yubikey-manager
        yubico-piv-tool
        android-tools
      ])
      ++ map guiOnlyWrapper (
        with pkgs;
        [
          dconf-editor
          crosspipe
          thunderbird
          fractal
          gimp3
          libreoffice
          celluloid
          amberol
          fragments
          gnome-decoder
          eyedropper
          d-spy
          firefox
          ungoogled-chromium
          rnote
          inkscape
          foliate
          warp
        ]
      )
      ++ [
        pass
      ]
      ++ gnomeExtensions;
  };

  hjem.users.archit = {
    clobberFiles = true;
    files = mkMerge [
      (
        let
          dotDir = flake.src + /dotfiles;
          replacements = {
            ".bashrc" = { inherit (pkgs) coreutils; };
            ".config/git/config".templateDir = ./homeFiles/git-template;
            ".config/pipewire/pipewire.conf.d/99-input-denoising.conf".rnnoisePath =
              pkgs.rnnoise-plugin.ladspa;
            ".local/share/gnupg/gpg-agent.conf".pinentry =
              lib.getExe pkgs.pinentry-gnome3;
            ".config/direnv/direnvrc".nix-direnv = pkgs.nix-direnv.override {
              nix = config.nix.package;
            };
          };
        in
        genAttrs' (listFilesRecursive dotDir) (p: rec {
          name =
            toString p
            |> removePrefix "${toString dotDir}/"
            |> unsafeDiscardStringContext
            |> (p: if hasPrefix "_" p then ".${removePrefix "_" p}" else p);
          value.source = pkgs.replaceVarsWith {
            src = p;
            replacements = replacements.${name} or { };
            postBuild = ''
              if [ -x "$src" ]; then chmod +x "$out"; fi
            '';
          };
        })
      )
      {
        ".face".source = flake.src + /assets/icon.png;
        ".librewolf/native-messaging-hosts/passff.json".source =
          (pkgs.passff-host.override { inherit pass; })
          + /lib/librewolf/native-messaging-hosts/passff.json;
        ".librewolf/profile/chrome/firefox-gnome-theme".source =
          pkgs.firefox-gnome-theme;
        ".thunderbird/profile/chrome/thunderbird-gnome-theme".source =
          pkgs.thunderbird-gnome-theme;
        ".config/celluloid/scripts".source =
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
        ".config/GIMP/3.0/gimprc".type = "copy";
        ".config/environment.d/10-user.conf".text =
          sessionVariables
          |> mapAttrsToList (
            k: v: ''
              ${k}="${replaceStrings [ "\"" "\\" "$" ] [ "\\\"" "\\\\" "$$" ] v}"
            ''
          )
          |> concatStrings;
        ".profile".text =
          sessionVariables
          |> mapAttrsToList (k: v: "export ${k}=${escapeShellArg v}\n")
          |> concatStrings;
        ".manpath".text = ''
          MANDB_MAP /etc/profiles/per-user/archit/share/man ${
            pkgs.runCommand "man-cache" { nativeBuildInputs = [ pkgs.man-db ]; } ''
              echo "MANDB_MAP ${manualPages}/share/man $out" > man.conf
              mandb -C man.conf --no-straycats --create ${manualPages}/share/man
            ''
          }
        '';
      }
    ];
    systemd = {
      services = {
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
        gpg-agent = {
          description = "GnuPG cryptographic agent and passphrase cache";
          documentation = [ "man:gpg-agent(1)" ];
          requires = [ "gpg-agent.socket" ];
          after = [ "gpg-agent.socket" ];
          unitConfig.RefuseManualStart = true;
          environment.GNUPGHOME = sessionVariables.GNUPGHOME;
          serviceConfig = {
            ExecStart = "${pkgs.gnupg}/bin/gpg-agent --supervised";
            ExecReload = "${pkgs.gnupg}/bin/gpgconf --reload gpg-agent";
          };
        };
      };
      sockets.gpg-agent = {
        description = "GnuPG cryptographic agent and passphrase cache";
        documentation = [ "man:gpg-agent(1)" ];
        wantedBy = [ "sockets.target" ];
        socketConfig = {
          ListenStream =
            let
              alphabet = stringToCharacters "ybndrfg8ejkmcpqxot1uwisza345h769";
            in
            hashString "sha1" sessionVariables.GNUPGHOME
            |> (h: [
              (substring 0 15 h)
              (substring 15 15 h)
            ])
            |> map fromHexString
            |> map (toBaseDigits 32)
            |> map (concat (replicate 11 0))
            |> map (takeEnd 12)
            |> concatLists
            |> map (elemAt alphabet)
            |> concatStrings
            |> (h: "%t/gnupg/d.${h}/S.gpg-agent");
          FileDescriptorName = "std";
          Service = "gpg-agent.service";
          SocketMode = "0600";
          DirectoryMode = "0700";
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

  ab.dconf.user =
    with lib.gvariant;
    let
      utc = mkVariant (mkTuple [
        (mkUint32 2)
        (mkVariant (mkTuple [
          "Coordinated Universal Time (UTC)"
          "@UTC"
          false
          (mkEmptyArray "(dd)")
          (mkEmptyArray "(dd)")
        ]))
      ]);
    in
    {
      "ca/desrt/dconf-editor" = {
        show-warning = false;
      };
      "io/bassi/Amberol" = {
        background-play = false;
        replay-gain = "track";
      };
      "io/github/celluloid-player/celluloid" = {
        mpv-config-enable = true;
        mpv-config-file = "file:///home/archit/.config/mpv/mpv.conf";
        mpris-enable = false;
        draggable-video-area-enable = true;
      };
      "org/gnome/Console" = {
        visual-bell = false;
      };
      "org/gnome/clocks" = {
        world-clocks = [ [ (mkDictionaryEntry "location" utc) ] ];
      };
      "org/gnome/desktop/background" = {
        color-shading-type = "solid";
        picture-options = "scaled";
        picture-uri = "file://${flake.src + /assets/desktop.svg}";
        picture-uri-dark = "file://${flake.src + /assets/desktop.svg}";
        primary-color = "#7767B2";
      };
      "org/gnome/desktop/input-sources" = {
        xkb-options = [
          "terminate:ctrl_alt_bksp"
          "compose:caps"
        ];
      };
      "org/gnome/desktop/interface" = {
        gtk-enable-primary-paste = true;
      };
      "org/gnome/desktop/privacy" = {
        old-files-age = mkUint32 30;
        recent-files-max-age = mkInt32 (-1);
        remember-recent-files = false;
        remove-old-temp-files = true;
        remove-old-trash-files = true;
      };
      "org/gnome/desktop/search-providers" = {
        disabled = [
          "org.gnome.Software.desktop"
          "org.gnome.Epiphany.desktop"
        ];
      };
      "org/gnome/desktop/screensaver" = {
        lock-delay = mkUint32 30;
      };
      "org/gnome/desktop/wm/preferences" = {
        resize-with-right-button = true;
        visual-bell = true;
        visual-bell-type = "frame-flash";
      };
      "org/gnome/Fractal/Stable" = {
        is-maximized = true;
      };
      "org/gnome/mutter" = {
        dynamic-workspaces = true;
        edge-tiling = true;
        workspaces-only-on-primary = true;
        attach-modal-dialogs = false;
      };
      "org/gnome/nautilus/preferences" = {
        show-delete-permanently = true;
      };
      "org/gnome/nautilus/list-view" = {
        use-tree-view = true;
      };
      "org/gnome/settings-daemon/plugins/housekeeping" = {
        donation-reminder-enabled = false;
      };
      "org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = catAttrs "extensionUuid" gnomeExtensions;
        favorite-apps = [
          "emacs.desktop"
          "librewolf.desktop"
          "thunderbird.desktop"
          "org.gnome.Fractal.desktop"
          "org.gnome.Nautilus.desktop"
          "io.bassi.Amberol.desktop"
        ];
      };
      "org/gnome/shell/extensions/caffeine" = {
        show-timer = false;
      };
      "org/gnome/shell/extensions/tiling-assistant" = {
        enable-tiling-popup = false;
        enable-raise-tile-group = false;
      };
      "org/gnome/shell/world-clocks" = {
        locations = [ utc ];
      };
      "org/gnome/system/location" = {
        enabled = true;
      };
      "org/gtk/settings/file-chooser" = {
        clock-format = "12h";
      };
      "org/gtk/gtk4/settings/file-chooser" = {
        sort-directories-first = false;
      };
    };
}
