{ lib
, writeText
, emacs-pgtk
, emacsPackagesFor
, git
, vale
, shellcheck
, direnv
, fish
, clang-tools
, nil
, openscad
, symlinkJoin
, vale-proselint
, vale-write-good
}:
let
  inherit (lib) pipe attrVals;
  configPackages = pipe (../../dotfiles/emacs/init.el) (with builtins; [
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
  default-init = writeText "default.el" ''
    (setq magit-git-executable "${git}/bin/git"
          flymake-vale-program "${vale}/bin/vale"
          flymake-vale-program-args '("--config=${valeConfig}")
          sh-shellcheck-program "${shellcheck}/bin/shellcheck"
          envrc-direnv-executable "${direnv}/bin/direnv"
          scad-command "${openscad}/bin/openscad"
          fish-completion-command "${fish}/bin/fish")
    (with-eval-after-load 'eglot
      (setq eglot-server-programs
            `(((c-ts-mode c++-ts-mode) .
               ,(eglot-alternatives '("clangd" "${clang-tools}/bin/clangd")))
              (nix-mode .
               ,(eglot-alternatives '("nil" "rnix-lsp" "${nil}/bin/nil")))
              . ,eglot-server-programs)))
  '';
  baseEmacs = emacs-pgtk;
  inherit (emacsPackagesFor baseEmacs) emacsWithPackages;
in
emacsWithPackages (epkgs: attrVals configPackages epkgs ++ [
  (epkgs.treesit-grammars.with-grammars (grammars: with grammars; [
    tree-sitter-c
    tree-sitter-cpp
  ]))
  (epkgs.trivialBuild {
    pname = "emacs-default-init";
    version = "0.0.1";
    src = default-init;
  })
])
