{ lib
, writeText
, emacs30-pgtk
, emacsPackagesFor
, git
, vale
, shellcheck
, direnv
, fish
, clang-tools
, nixd
, rust-analyzer
, openscad
, symlinkJoin
, vale-proselint
, vale-write-good
, makeFontsConf
, adwaita-fonts
, noto-fonts
, noto-fonts-extra
, noto-fonts-cjk-sans
, noto-fonts-cjk-serif
, noto-fonts-color-emoji
, noto-fonts-monochrome-emoji
, runCommand
, makeBinaryWrapper
}:
let
  inherit (lib) pipe attrVals;

  configPackages = pipe ../../dotfiles/emacs/init.el (with builtins; [
    readFile
    (match ".*\\(setopt package-selected-packages[[:space:]]+'\\(([^)]+).*")
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

  fontConfig = makeFontsConf {
    fontDirectories = [
      adwaita-fonts
      noto-fonts
      noto-fonts-extra
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      noto-fonts-monochrome-emoji
    ];
  };

  default-init = writeText "default.el" ''
    (setq magit-git-executable "${git}/bin/git"
          flymake-vale-program "${vale}/bin/vale"
          flymake-vale-program-args '("--config=${valeConfig}")
          sh-shellcheck-program "${shellcheck}/bin/shellcheck"
          envrc-direnv-executable "${direnv}/bin/direnv"
          scad-command "${openscad}/bin/openscad"
          fish-completion-command "${fish}/bin/fish"
          clangd-program "${clang-tools}/bin/clangd"
          nixd-program "${nixd}/bin/nixd"
          rust-analyzer-program "${rust-analyzer}/bin/rust-analyzer")
  '';

  baseEmacs = emacs30-pgtk;

  inherit (emacsPackagesFor baseEmacs) emacsWithPackages;

  emacsWPkgs = emacsWithPackages (epkgs: attrVals configPackages epkgs ++ [
    (epkgs.treesit-grammars.with-grammars (grammars: with grammars; [
      tree-sitter-zig
      tree-sitter-c
      tree-sitter-cpp
      tree-sitter-cmake
      tree-sitter-rust
      tree-sitter-python
      tree-sitter-java
      tree-sitter-json
      tree-sitter-toml
      tree-sitter-yaml
      tree-sitter-html
      tree-sitter-css
      tree-sitter-javascript
      tree-sitter-typescript
      tree-sitter-tsx
      tree-sitter-dockerfile
      tree-sitter-go
      tree-sitter-gomod
      tree-sitter-lua
      tree-sitter-php
      tree-sitter-ruby
    ]))
    (epkgs.trivialBuild {
      pname = "emacs-default-init";
      version = "0.0.1";
      src = default-init;
    })
  ]);

  wrapEmacs = emacs: runCommand emacs.name
    {
      nativeBuildInputs = [ makeBinaryWrapper ];
      inherit (emacs) meta;
    }
    ''
      mkdir -p $out/bin
      for bin in ${emacs}/bin/*; do
        makeWrapper "$bin" $out/bin/$(basename "$bin") --inherit-argv0 \
          --set FONTCONFIG_FILE ${fontConfig}
      done
      ln -s ${emacs}/share $out/share
    '';
in
wrapEmacs emacsWPkgs
