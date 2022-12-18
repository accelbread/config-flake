{ lib
, writeText
, writeShellScript
, emacsPgtk
, emacsPackagesFor
, aspell
, git
, vale
, shellcheck
, direnv
, fish
, clang-tools
, rust-analyzer
, rustfmt
, zls
, nil
, haskell-language-server
, ghc
, stylish-haskell
, openscad
, symlinkJoin
, vale-proselint
, vale-write-good
}:
let
  inherit (lib) pipe singleton attrVals;
  self = ../.;
  configPackages = pipe (self + /dotfiles/emacs/init.el) (with builtins; [
    readFile
    (match ".*\\(setq package-selected-packages[[:space:]]+'\\(([^)]+).*")
    head
    (split "([-a-z]+)")
    (filter isList)
    (map head)
  ]);
  valeStyles = symlinkJoin {
    name = "vale-styles";
    paths = [ vale-proselint vale-write-good ];
  };
  valeConfig = writeText "vale-config" ''
    StylesPath = ${valeStyles}
    MinAlertLevel = suggestion
    [*]
    BasedOnStyles = proselint, write-good
    write-good.E-Prime = NO
  '';
  hls-wrapper = writeShellScript "hls-wrapper" ''
    export PATH=${haskell-language-server}/bin:${ghc}/bin:$PATH
    exec ${haskell-language-server}/bin/haskell-language-server-wrapper "$@"
  '';
  default-init = writeText "default.el" ''
    (setq ispell-program-name "${aspell}/bin/aspell"
          magit-git-executable "${git}/bin/git"
          clang-format-executable "${clang-tools}/bin/clang-format"
          rust-rustfmt-bin "${rustfmt}/bin/rustfmt"
          haskell-mode-stylish-haskell-path
          "${stylish-haskell}/bin/stylish-haskell"
          flymake-vale-program "${vale}/bin/vale"
          flymake-vale-program-args '("--config=${valeConfig}")
          sh-shellcheck-program "${shellcheck}/bin/shellcheck"
          envrc-direnv-executable "${direnv}/bin/direnv"
          scad-command "${openscad}/bin/openscad"
          fish-completion-command "${fish}/bin/fish")
    (with-eval-after-load 'eglot
      (setq eglot-server-programs
            `(((c++-mode c-mode) .
               ,(eglot-alternatives
                 '("clangd" "${clang-tools}/bin/clangd")))
              (rust-mode .
               ,(eglot-alternatives
                 '("rust-analyzer" "${rust-analyzer}/bin/rust-analyzer")))
              (zig-mode .
               ,(eglot-alternatives
                 '("zls" "${zls}/bin/zls")))
              (nix-mode .
               ,(eglot-alternatives
                 '("nil" "rnix-lsp" "${nil}/bin/nil")))
              (haskell-mode .
               ,(eglot-alternatives
                 '(("haskell-language-server-wrapper" "--lsp")
                   ("${hls-wrapper}" "--lsp")))))))
  '';
  baseEmacs = emacsPgtk;
  emacsWithPackages = (emacsPackagesFor baseEmacs).emacsWithPackages;
in
emacsWithPackages (epkgs: attrVals configPackages epkgs
++ singleton (epkgs.trivialBuild {
  pname = "emacs-default-init";
  src = default-init;
}))
