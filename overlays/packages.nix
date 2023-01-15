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
    (final: prev: genPackages ../packages/elisp-packages final.callPackage);
}
