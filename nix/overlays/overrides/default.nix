# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
final: prev:
let
  inherit (builtins) any filter mapAttrs path;
  inherit (final.lib) filesystem hasSuffix;
in
prev.lib.composeManyExtensions [
  (final: prev: mapAttrs
    (pkg: _: prev.${pkg}.overrideAttrs (old: {
      patches = old.patches or [ ] ++
        (map (p: path { path = p; })
          (filter (p: any (e: hasSuffix e p) [ ".patch" ".mbx" ])
            (filesystem.listFilesRecursive (./patches + "/${pkg}"))));
    }))
    (builtins.readDir ./patches))
  (final: prev: {
    ccacheWrapper = prev.ccacheWrapper.override {
      extraConfig = ''
        export CCACHE_COMPRESS=1
        export CCACHE_SLOPPINESS=random_seed
        export CCACHE_DIR=/var/cache/ccache
        export CCACHE_UMASK=007
      '';
    };
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
    bees = prev.bees.overrideAttrs {
      utillinux = final.runCommand final.util-linux.name
        {
          inherit (final.util-linux) meta pname version;
          nativeBuildInputs = [ final.makeBinaryWrapper ];
        } ''
        cp -r ${final.util-linux} $out
        chmod -R u+w $out
        wrapProgram $out/bin/mount --add-flags "-o noatime"
      '';
    };
    rnote = final.runCommand prev.rnote.name { } ''
      cp -Lr ${prev.rnote} $out
      chmod -R u+w $out
      rm -r $out/share/fonts
    '';
    haskellPackages = prev.haskellPackages.override {
      overrides = _: hprev: {
        nix-derivation = final.haskell.lib.overrideCabal hprev.nix-derivation
          (old: {
            patches = (old.patches or [ ]) ++ [
              ./haskellPatches/nix-derivation/support-ca-derivations.patch
            ];
          });
      };
    };
    lean4 = prev.lean4.overrideAttrs (old: {
      cmakeFlags = old.cmakeFlags ++ [
        "-DSTAGE1_CMAKE_INSTALL_PREFIX=${placeholder "out"}"
      ];
    });
    codex = prev.codex.overrideAttrs (old: rec {
      version = "0.156.1";
      src = final.fetchFromGitHub {
        owner = "openai";
        repo = "codex";
        tag = "rust-v${version}";
        hash = "sha256-H53f57hmnyCtn5yPxtBe/A92qyQyzQBeU/vK2qSBrvI=";
      };
      cargoDeps = final.rustPlatform.fetchCargoVendor {
        inherit src;
        sourceRoot = "${src.name}/codex-rs";
        hash = "sha256-W87rX/W2J1pwqNrihX+Rj6DfagoZYuB6C+l/S4BhyJM=";
      };
      postPatch = (old.postPatch or "") + ''
        sed -i '1i#![recursion_limit = "256"]' chatgpt/src/lib.rs
      '';
    });
  })
]
  final
  prev
