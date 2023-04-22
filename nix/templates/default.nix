{ lib }: lib.mapAttrs (n: v: { path = ./${n}; } // v)
rec {
  default = shell // { path = ./shell; };
  shell.description = "Template Nix devShell.";
  quickshell.description = "Envrc pointing to self flake.";
  elisp-package.description = "Template Emacs package.";
  c-bin.description = "Template C application.";
  rust-bin.description = "Template Rust application.";
  zig-bin.description = "Template Zig application.";
}
