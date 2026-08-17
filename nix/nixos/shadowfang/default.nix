# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
{
  modules = [
    ./configuration.nix
    {
      ab.disks = {
        devices = [ "/dev/nvme0n1" ];
        size = "3500GiB";
        swap = "64g";
      };
      networking.hostId = "fefcc72a";
      system.stateVersion = "25.11";
    }
  ];
}
