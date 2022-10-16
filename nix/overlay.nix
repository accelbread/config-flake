pkgs: _:
let inherit (pkgs) lib;
in {
  emacsAccelbread =
    (pkgs.emacsPackagesFor pkgs.emacsPgtkNativeComp).emacsWithPackages (epkgs:
      with builtins;
      lib.attrsets.attrVals (map head (filter isList (split "([-a-z]+)" (head
        (match ".*\\(setq package-selected-packages[[:space:]]+'\\(([^)]+).*"
          (readFile ../dotfiles/config/emacs/init.el)))))) epkgs
      ++ lib.singleton (epkgs.trivialBuild {
        pname = "emacs-default-init";
        src = pkgs.writeText "default.el" ''
          (setq ispell-program-name "${pkgs.aspell}/bin/aspell"
                clang-format-executable "${pkgs.clang-tools}/bin/clang-format"
                rust-rustfmt-bin "${pkgs.rustfmt}/bin/rustfmt"
                nix-nixfmt-bin "${pkgs.nixfmt}/bin/nixfmt"
                sh-shellcheck-program "${pkgs.shellcheck}/bin/shellcheck"
                fish-completion-command "${pkgs.fish}/bin/fish")
          (with-eval-after-load 'eglot
            (setq eglot-server-programs
                  '(((c++-mode c-mode) "${pkgs.clang-tools}/bin/clangd")
                    (rust-mode "${pkgs.rust-analyzer}/bin/rust-analyzer")
                    (zig-mode "${pkgs.zls}/bin/zls")
                    (nix-mode "${pkgs.rnix-lsp}/bin/rnix-lsp"))))
          (provide 'nix-paths)
        '';
      }));
}
