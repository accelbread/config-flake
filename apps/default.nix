pkgs:
let
  self = ../.;
  mkApp = drv: name: {
    type = "app";
    program = "${drv}/bin/${name}";
  };
  mkApps = drvs:
    builtins.listToAttrs (map
      (drv: rec {
        name = drv.pname or drv.name;
        value = mkApp drv name;
      })
      drvs);
in
mkApps [
  (pkgs.writeShellApplication {
    name = "provision-disks";
    runtimeInputs = with pkgs; [
      util-linux
      parted
      dosfstools
      cryptsetup
      lvm2
      btrfs-progs
      mkpasswd
    ];
    text = builtins.readFile (self + /scripts/provision-disks);
  })
] // {
  emacs = mkApp pkgs.emacsAccelbread "emacs";
}
