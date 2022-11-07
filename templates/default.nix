rec {
  default = shell;
  shell = {
    path = ./shell;
    description = "Template for `nix develop` and direnv.";
  };
}
