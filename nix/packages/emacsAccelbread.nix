{ lib
, writeText
, emacsPgtkNativeComp
, emacsPackagesFor
, aspell
, shellcheck
, fish
, clang-tools
, rust-analyzer
, rustfmt
, zls
, rnix-lsp
}:
let
  self = ../..;
  cfgPkgNames = with builtins; (map head (filter isList (split "([-a-z]+)" (head
    (match ".*\\(setq package-selected-packages[[:space:]]+'\\(([^)]+).*"
      (readFile (self + /dotfiles/emacs/init.el)))))));
  default-init = writeText "default.el" ''
    (setq ispell-program-name "${aspell}/bin/aspell"
          clang-format-executable "${clang-tools}/bin/clang-format"
          rust-rustfmt-bin "${rustfmt}/bin/rustfmt"
          sh-shellcheck-program "${shellcheck}/bin/shellcheck"
          fish-completion-command "${fish}/bin/fish")
    (with-eval-after-load 'eglot
      (setq eglot-server-programs
            '(((c++-mode c-mode) "${clang-tools}/bin/clangd")
              (rust-mode "${rust-analyzer}/bin/rust-analyzer")
              (zig-mode "${zls}/bin/zls")
              (nix-mode "${rnix-lsp}/bin/rnix-lsp"))))
  '';
  emacsWithPackages = (emacsPackagesFor emacsPgtkNativeComp).emacsWithPackages;
in
emacsWithPackages (epkgs:
  lib.attrsets.attrVals cfgPkgNames epkgs
  ++ lib.singleton (epkgs.trivialBuild {
    pname = "emacs-default-init";
    src = default-init;
  }))