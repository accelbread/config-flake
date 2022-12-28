rec {
  default = shell;
  shell = {
    path = ./shell;
    description = "Template for Nix devShells.";
  };
  elisp-package = {
    path = ./elisp-package;
    description = "Template for new Emacs packages.";
  };
  c-bin = {
    path = ./c-bin;
    description = "Template for C applications.";
  };
}
