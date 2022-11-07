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
, symlinkJoin
, vale-proselint
, vale-write-good
}:
let
  inherit (builtins) readDir attrNames filter listToAttrs;
  inherit (lib.strings) hasSuffix removeSuffix;
  inherit (lib.attrsets) nameValuePair;
  self = ../.;
  elispPackages = map (removeSuffix ".nix") (filter (hasSuffix ".nix")
    (attrNames (readDir ./elisp-packages)));
  extendPkgs = epkgs: epkgs // listToAttrs (map
    (p: nameValuePair p
      (epkgs.callPackage (./elisp-packages + "/${p}.nix") { }))
    elispPackages);
  cfgPkgNames = with builtins; (map head (filter isList (split "([-a-z]+)" (head
    (match ".*\\(setq package-selected-packages[[:space:]]+'\\(([^)]+).*"
      (readFile (self + /dotfiles/emacs/init.el)))))));
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
  lib.attrsets.attrVals cfgPkgNames (extendPkgs epkgs)
  ++ lib.singleton (epkgs.trivialBuild {
    pname = "emacs-default-init";
    src = default-init;
  }))
