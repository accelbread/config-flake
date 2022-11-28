{ lib
, writeText
, emacsPgtkNativeComp
, emacsPackagesFor
, aspell
, vale
, shellcheck
, direnv
, fish
, clang-tools
, rust-analyzer
, rustfmt
, zls
, rnix-lsp
, openscad
, symlinkJoin
, vale-proselint
, vale-write-good
}:
let
  inherit (builtins) readDir attrNames filter;
  inherit (lib) pipe fix singleton hasSuffix removeSuffix genAttrs attrVals;
  self = ../.;
  elispPackages = pipe (readDir ./elisp-packages) [
    attrNames
    (filter (hasSuffix ".nix"))
    (map (removeSuffix ".nix"))
  ];
  extendEpkgs = epkgs: fix (self: epkgs // (genAttrs elispPackages
    (p: self.callPackage (./elisp-packages + "/${p}.nix") { })));
  emacsConfigPkgNames = pipe (self + /dotfiles/emacs/init.el) (with builtins; [
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
          clang-format-executable "${clang-tools}/bin/clang-format"
          rust-rustfmt-bin "${rustfmt}/bin/rustfmt"
          flymake-vale-program "${vale}/bin/vale"
          flymake-vale-program-args '("--config=${valeConfig}")
          sh-shellcheck-program "${shellcheck}/bin/shellcheck"
          envrc-direnv-executable "${direnv}/bin/direnv"
          scad-command "${openscad}/bin/openscad"
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
  attrVals emacsConfigPkgNames (extendEpkgs epkgs)
  ++ singleton (epkgs.trivialBuild {
    pname = "emacs-default-init";
    src = default-init;
  }))
