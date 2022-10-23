final: prev:
let
  inherit (final) lib;
  self = ../..;
in
{
  emacsAccelbread =
    (final.emacsPackagesFor final.emacsPgtkNativeComp).emacsWithPackages (epkgs:
      with builtins;
      lib.attrsets.attrVals
        (map head (filter isList (split "([-a-z]+)" (head
          (match ".*\\(setq package-selected-packages[[:space:]]+'\\(([^)]+).*"
            (readFile (self + /dotfiles/config/emacs/init.el)))))))
        epkgs
      ++ lib.singleton (epkgs.trivialBuild {
        pname = "emacs-default-init";
        src = with final; writeText "default.el" ''
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
      }));
}
