# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
{ writeShellApplication
, btrfs-progs
, gawk
, gnused
}:
writeShellApplication {
  name = "btrfs-subvol-rm-r";
  runtimeInputs = [ btrfs-progs gawk gnused ];
  text = builtins.readFile ./misc/btrfs-subvol-rm-r;
}
