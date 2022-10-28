final: prev:
let
  inherit (builtins) readDir attrNames filter listToAttrs;
  inherit (prev.lib.strings) hasSuffix removeSuffix;
  inherit (prev.lib.attrsets) nameValuePair;
  packages = map (removeSuffix ".nix") (filter (hasSuffix ".nix")
    (attrNames (readDir ../packages)));
in
listToAttrs (map
  (p: nameValuePair p
    (final.callPackage (../. + "/packages/${p}.nix") { }))
  packages)
