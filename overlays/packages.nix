final: prev:
let
  inherit (builtins) readDir attrNames filter;
  inherit (prev.lib) pipe hasSuffix removeSuffix genAttrs;
  genPackages = path: callPackage:
    genAttrs
      (pipe (readDir path) [
        attrNames
        (filter (hasSuffix ".nix"))
        (map (removeSuffix ".nix"))
      ])
      (p: callPackage (path + "/${p}.nix") { });
in
genPackages ../packages final.callPackage
  // {
  emacsPackagesFor = emacs: (prev.emacsPackagesFor emacs).overrideScope'
    (final: prev:
      prev.melpaPackages //
      prev.melpaStablePackages //
      prev.nongnuPackages //
      prev.elpaPackages //
      prev.manualPackages //
      genPackages ../packages/elisp-packages final.callPackage);
  nut = prev.nut.overrideAttrs (old: {
    postPatch = ">conf/Makefile.am";
    configureFlags = old.configureFlags ++
    [
      "--with-drivers=usbhid-ups"
      "--without-dev"
      "--with-user=nut"
      "--with-group=nut"
      "--sysconfdir=/etc/nut"
      "--with-statepath=/var/lib/nut"
    ];
  });
}
