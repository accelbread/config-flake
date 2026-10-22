# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
{
  modules = [
    ./configuration.nix
    {
      ab.disks = {
        devices = [ "/dev/nvme0n1" ];
        size = "-32GiB";
        swap = "128g";
      };
    }
  ];
}
