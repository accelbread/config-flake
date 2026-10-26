# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
{ lib, pkgs, ... }:
let
  config =
    pkgs.runCommand "librewolf-config.json" {
      nativeBuildInputs = [ pkgs.yq-go ];
    } "yq -o=json ${./misc/librewolf_config.yaml} > $out"
    |> lib.importJSON;
in
{
  users.users.archit.packages = [
    (pkgs.librewolf.override (old: {
      # Enable privileged autoconfig before mozilla.cfg is evaluated.
      extraAutoConfig = old.extraAutoConfig or "" + ''
        pref("general.config.sandbox_enabled", false);
      '';
      extraPrefsFiles = old.extraPrefsFiles or [ ] ++ [
        (pkgs.replaceVars ./misc/librewolf_config.js {
          config = builtins.toJSON config;
        })
      ];
      extraPolicies = old.extraPolicies or { } // {
        ExtensionSettings = lib.mapAttrs (
          _: v: (v.policy or { }) // { installation_mode = "force_installed"; }
        ) config.extensions;
        "3rdparty".Extensions = lib.mapAttrs (_: v: v.managed) (
          lib.filterAttrs (_: v: v ? managed) config.extensions
        );
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
