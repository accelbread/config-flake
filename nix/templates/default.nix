# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
{ lib, ... }:
let
  genTemplate = n: v: {
    path = ./${n};
    description = v;
  };
in
lib.fix (
  self:
  {
    default = self.shell;
  }
  // lib.mapAttrs genTemplate {
    shell = "Template Nix devShell.";
    quickshell = "Envrc pointing to self flake.";
    elisp-package = "Template Emacs package.";
    c-bin = "Template C application.";
    rust-bin = "Template Rust application.";
    zig-bin = "Template Zig application.";
  }
)
