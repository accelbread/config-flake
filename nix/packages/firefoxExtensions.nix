# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
{
  lib,
  fetchurl,
  linkFarm,
  writers,
  guile-json,
  guile-gnutls,
}:
let
  extensions = lib.mapAttrs (
    _: v:
    fetchurl {
      inherit (v) url hash;
      passthru = { inherit (v) addonId version; };
    }
  ) (lib.importJSON ./misc/firefox-extensions.json);
in
(linkFarm "firefox-extensions" extensions).overrideAttrs {
  passthru = extensions // {
    updateScript = [
      (writers.writeGuile "update-firefox-extensions" {
        libraries = [
          guile-json
          guile-gnutls
        ];
      } (lib.readFile ./misc/update-firefox-extensions.scm))
      "nix/packages/misc/firefox-extensions.json"
    ];
  };
}
