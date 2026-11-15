# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
{
  config,
  lib,
  pkgs,
  ...
}:
let
  prefs =
    pkgs.runCommand "librewolf_config.json" { }
      ''${pkgs.yq-go}/bin/yq -o=json ${./librewolf/config.yaml} > "$out"'';
  pinnedExts = lib.importJSON ./librewolf/extensions.json;
in
{
  options.ab.librewolf.nativeMessagingHosts = lib.mkOption {
    type = lib.types.listOf lib.types.package;
    default = [ ];
    description = "Native messaging hosts available to LibreWolf.";
  };

  config.users.users.archit.packages = [
    (pkgs.librewolf.override (old: {
      inherit (config.ab.librewolf) nativeMessagingHosts;
      hasMozSystemDirPatch = true;
      # Enable privileged autoconfig before mozilla.cfg is evaluated.
      extraAutoConfig = old.extraAutoConfig or "" + ''
        pref("general.config.sandbox_enabled", false);
      '';
      extraPrefsFiles = old.extraPrefsFiles or [ ] ++ [
        (pkgs.runCommand "librewolf_config.js" { } ''
          substitute ${./librewolf/config.js} "$out" \
            --subst-var-by config "$(cat ${prefs})"
        '')
      ];
      # The wrapper gives earlier policy files precedence over later ones.
      extraPoliciesFiles = [
        (pkgs.runCommand "librewolf_policies.json" { } ''
          ${pkgs.jq}/bin/jq '.extensions | {
            policies: {
              ExtensionSettings: map_values(
                (.policy // {}) + {installation_mode: "force_installed"}
              ),
              "3rdparty": {
                Extensions: map_values(select(has("managed")) | .managed)
              }
            }
          }' ${prefs} > "$out"
        '')
      ]
      ++ old.extraPoliciesFiles or [ ];
      extraPolicies = old.extraPolicies or { } // {
        ExtensionSettings = lib.mapAttrs (_: v: {
          install_url = "file://${pkgs.fetchurl v}";
          updates_disabled = true;
        }) pinnedExts;
        SearchEngines = {
          Default = "Kagi";
          Remove = [
            "Wikipedia (en)"
            "Startpage"
            "Mojeek"
          ];
          Add = [
            {
              Name = "Kagi";
              IconURL = "https://kagi.com/favicon.ico";
              URLTemplate = "https://kagi.com/search?q={searchTerms}";
              Method = "GET";
              Alias = "@kagi";
            }
            {
              Name = "Nix Packages";
              IconURL = "https://search.nixos.org/images/nixos-logomark-default-gradient-none.svg";
              URLTemplate = "https://search.nixos.org/packages?channel=unstable&query={searchTerms}";
              Method = "GET";
              Alias = "@nix";
            }
            {
              Name = "NixOS Options";
              IconURL = "https://search.nixos.org/images/nixos-logomark-default-gradient-none.svg";
              URLTemplate = "https://search.nixos.org/options?channel=unstable&query={searchTerms}";
              Method = "GET";
              Alias = "@nixos";
            }
          ];
        };
      };
    }))
  ];
}
