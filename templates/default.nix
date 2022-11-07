rec {
  default = shell;
  shell = {
    path = ./shell;
    description = "Template for `nix develop` and direnv.";
  };
  elisp-package = {
    path = ./elisp-package;
    description = "Template for new emacs packages.";
  };
}
