pkgs:
builtins.mapAttrs (k: v: {
  type = "app";
  program = "${pkgs.writeShellApplication {
    name = k;
    runtimeInputs = v.runtimeInputs or [ ];
    inherit (v) text;
  } + "/bin/" + k}";
}) {
  provision_disks = {
    runtimeInputs = with pkgs; [
      util-linux
      parted
      dosfstools
      cryptsetup
      lvm2
      btrfs-progs
      mkpasswd
    ];
    text = builtins.readFile ./scripts/provision_disks;
  };
}

