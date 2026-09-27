# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
{
  config,
  lib,
  inputs,
  ...
}:
let
  inherit (lib)
    flip
    genAttrs
    mkForce
    ;
in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
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
