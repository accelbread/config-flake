{ lib
, writeText
, emacsPgtk
, emacsPackagesFor
, aspell
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
  inherit (lib) pipe singleton attrVals;
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
    (setq ispell-program-name "${aspell}/bin/aspell"
          magit-git-executable "${git}/bin/git"
          flymake-vale-program "${vale}/bin/vale"
          flymake-vale-program-args '("--config=${valeConfig}")
          sh-shellcheck-program "${shellcheck}/bin/shellcheck"
          envrc-direnv-executable "${direnv}/bin/direnv"
          scad-command "${openscad}/bin/openscad"
          fish-completion-command "${fish}/bin/fish")
    (with-eval-after-load 'eglot
      (setq eglot-server-programs
            `(((c++-mode c-mode) .
               ,(eglot-alternatives '("clangd" "${clang-tools}/bin/clangd")))
              (nix-mode .
               ,(eglot-alternatives '("nil" "rnix-lsp" "${nil}/bin/nil")))
              . ,eglot-server-programs)))
  '';
  baseEmacs = emacsPgtk.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++
      [ ./misc/0001-Revert-Better-compilation-of-arguments-to-ignore.patch ];
  });
  emacsWithPackages = (emacsPackagesFor baseEmacs).emacsWithPackages;
in
emacsWithPackages (epkgs: attrVals configPackages epkgs
++ singleton (epkgs.trivialBuild {
  pname = "emacs-default-init";
  src = default-init;
}))
