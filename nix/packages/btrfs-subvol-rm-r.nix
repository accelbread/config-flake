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
