final: prev:
let
  inherit (builtins) readDir attrNames filter;
  inherit (prev.lib) pipe hasSuffix removeSuffix nameValuePair genAttrs;
  packages = pipe (readDir ../packages) [
    attrNames
    (filter (hasSuffix ".nix"))
    (map (removeSuffix ".nix"))
  ];
in
genAttrs packages (p: (final.callPackage (../packages + "/${p}.nix") { }))
