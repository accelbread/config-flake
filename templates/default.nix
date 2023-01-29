rec {
  default = shell;
  shell = {
    path = ./shell;
    description = "Template Nix devShell.";
  };
  elisp-package = {
    path = ./elisp-package;
    description = "Template Emacs package.";
  };
  c-bin = {
    path = ./c-bin;
    description = "Template C application.";
  };
  rust-bin = {
    path = ./rust-bin;
    description = "Template Rust application.";
  };
  zig-bin = {
    path = ./zig-bin;
    description = "Template Zig application.";
  };
}
