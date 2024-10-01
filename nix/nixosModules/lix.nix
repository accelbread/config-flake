{ lib, pkgs, ... }: {
  nix.package = pkgs.lix;
  system.forbiddenDependenciesRegexes =
    lib.map lib.escapeRegex [ "${pkgs.nix}" ];
}
