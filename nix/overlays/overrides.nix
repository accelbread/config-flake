# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
final: prev:
let
  inherit (builtins)
    filter
    mapAttrs
    path
    readDir
    ;
  inherit (prev.lib)
    concatMapStringsSep
    filesystem
    filterAttrs
    hasSuffix
    ;

  applyPatches' =
    overrideArgFor: overrideFn: dir:
    readDir dir
    |> filterAttrs (_: v: v == "directory")
    |> mapAttrs (
      k: _:
      filesystem.listFilesRecursive (dir + "/${k}")
      |> filter (p: hasSuffix ".patch" p || hasSuffix ".mbx" p)
      |> map (p: path { path = p; })
      |> overrideArgFor
      |> overrideFn k
    );

  applyPatches = applyPatches' (
    ps: old: { patches = old.patches or [ ] ++ ps; }
  );

  patchDir = prev.src + /patches;
in
prev.lib.composeManyExtensions [
  (_: _: applyPatches (n: prev.${n}.overrideAttrs) patchDir)
  (_: _: {
    gnomeExtensions =
      prev.gnomeExtensions
      // (applyPatches (n: prev.gnomeExtensions.${n}.overrideAttrs) (
        patchDir + /gnomeExtensions
      ));
    haskellPackages = prev.haskellPackages.override {
      overrides =
        _: hprev:
        applyPatches (n: final.haskell.lib.overrideCabal hprev.${n}) (
          patchDir + /haskellPackages
        );
    };
    emacsPackagesFor =
      emacs:
      (prev.emacsPackagesFor emacs).overrideScope (
        _: eprev:
        applyPatches' (
          patches: old:
          let
            sourceDir = "${old.pname}-${old.version}";
          in
          {
            src = final.runCommand "${sourceDir}-patched.tar" { } ''
              mkdir source
              if [ -d ${old.src} ]; then
                mkdir -p source/${sourceDir}
                cp -R ${old.src}/. source/${sourceDir}/
              else
                tar -xf ${old.src} -C source
              fi
              ${concatMapStringsSep "\n" (patchFile: ''
                patch -d source/${sourceDir} -p1 < ${patchFile}
              '') patches}
              tar --sort=name --mtime=@1 --owner=0 --group=0 --numeric-owner \
                -cf $out -C source ${sourceDir}
            '';
          }
        ) (n: eprev.${n}.overrideAttrs) (patchDir + /emacsPackages)
      );
    inherit (prev) emacsPackages;
  })
  (_: prev: {
    ccacheWrapper = prev.ccacheWrapper.override {
      extraConfig = ''
        export CCACHE_COMPRESS=1
        export CCACHE_SLOPPINESS=random_seed
        export CCACHE_DIR=/var/cache/ccache
        export CCACHE_UMASK=007
      '';
    };
    mutter = prev.mutter.overrideAttrs (old: {
      mesonFlags = old.mesonFlags ++ [ "-Dxwayland=false" ];
    });
    gnome-shell = prev.gnome-shell.overrideAttrs (old: {
      postPatch = (old.postPatch or "") + ''
        substituteInPlace src/main.c js/misc/util.js \
          --replace-fail '@appLauncher@' "$out/lib/gnome-shell/gnome-shell-app-launcher"
        substituteInPlace js/misc/util.js \
          --replace-fail '@env@' '${final.coreutils}/bin/env'
      '';
      postInstall = (old.postInstall or "") + ''
        mkdir -p "$out/lib/gnome-shell"
        $CC -Wall -Wextra -Werror \
          -DSYSTEMD_RUN='"${final.systemd}/bin/systemd-run"' \
          -DGIO_LAUNCH_DESKTOP='"${final.glib.out}/libexec/gio-launch-desktop"' \
          ${./misc/gnome-shell-app-launcher.c} \
          $(pkg-config --cflags --libs gio-unix-2.0) \
          -o "$out/lib/gnome-shell/gnome-shell-app-launcher"
      '';
    });
    gnome-settings-daemon = prev.gnome-settings-daemon.overrideAttrs (old: {
      mesonFlags = old.mesonFlags ++ [ "-Dxwayland=false" ];
    });
    gnome-online-accounts = prev.gnome-online-accounts.overrideAttrs (old: {
      mesonFlags = old.mesonFlags ++ [ "-Dsysconfdir=/etc" ];
    });
    nut = prev.nut.overrideAttrs (old: {
      postPatch = ">conf/Makefile.am";
      configureFlags = old.configureFlags ++ [
        "--with-drivers=usbhid-ups"
        "--without-dev"
        "--with-user=nut"
        "--with-group=nut"
        "--sysconfdir=/etc/nut"
        "--with-statepath=/var/lib/nut"
      ];
    });
    rnote = final.runCommand prev.rnote.name { } ''
      cp -Lr ${prev.rnote} $out
      chmod -R u+w $out
      rm -r $out/share/fonts
    '';
    nix-update = prev.nix-update.overrideAttrs (old: {
      patches = old.patches or [ ] ++ [
        (final.fetchpatch {
          url = "https://github.com/Mic92/nix-update/commit/d545c1fad667e573128cad0db55fdc77134a4d3c.patch";
          hash = "sha256-CVSihQevWIwKSnjKo9ilw1hdi4a1t0xr6DunAUKSBFA=";
        })
      ];
    });
  })
] final prev
