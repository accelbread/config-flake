# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
{ lib
, writeText
, emacs31-pgtk
, emacsPackagesFor
, git
, vale
, shellcheck
, direnv
, fish
, guile
, llvmPackages_latest
, nixd
, rust-analyzer
, lean4
, tinymist
, openscad-unstable
, yaml-language-server
, tombi
, symlinkJoin
, vale-proselint
, vale-write-good
, makeFontsConf
, adwaita-fonts
, noto-fonts
, noto-fonts-cjk-sans
, noto-fonts-cjk-serif
, noto-fonts-color-emoji
, noto-fonts-monochrome-emoji
, hunspellDicts
, runCommand
, makeBinaryWrapper
, fetchurl
, jing-trang
}:
let
  inherit (builtins) attrNames filter head match readDir readFile
    split;
  inherit (lib) attrVals concatMap concatMapStringsSep flatten hasSuffix pipe
    removeSuffix splitString;

  binPkgMap = {
    inherit git vale shellcheck direnv guile fish rust-analyzer tinymist nixd
      yaml-language-server tombi;
    clangd = llvmPackages_latest.clang-tools;
    lake = lean4;
    openscad = openscad-unstable;
  };

  packageRequiresFromFile = file: pipe file [
    readFile
    (match ".*\n;; Package-Requires: \\(([^\n]*)\\)\n.*")
    (requires:
      if requires == null then [ ] else
      pipe requires [
        head
        (split "\\(([-a-z]+) \"[^\"]+\"\\)")
        flatten
        (concatMap (splitString " "))
        (filter (pkg: pkg != "" && pkg != "emacs"))
      ])
  ];

  buildPkg = epkgs: src:
    let
      pname = removeSuffix ".el" (baseNameOf src);
      file =
        if hasSuffix ".el" (toString src) then src
        else src + "/${baseNameOf src}.el";
    in
    epkgs.elpaBuild {
      inherit pname src;
      version = "0";
      packageRequires = attrVals (packageRequiresFromFile file) epkgs;
    };

  userLispDir = ../../dotfiles/emacs/user-lisp;
  userLispPkgsSrcs = map (f: userLispDir + "/${f}")
    (attrNames (readDir userLispDir));
  userLispPkgs = epkgs: map (buildPkg epkgs) userLispPkgsSrcs;

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
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      noto-fonts-monochrome-emoji
    ];
  };

  svgDtd = fetchurl {
    url = "https://www.w3.org/Graphics/SVG/1.1/DTD/svg11-flat-20110816.dtd";
    hash = "sha256-fCImbWVlWn01np55oQfRVuZLKah0kTE74gkr1myrO5s=";
  };

  svgSchema = runCommand "svg-xml-schema" { } ''
    mkdir $out
    cat << EOF > $out/schemas.xml
    <locatingRules xmlns="http://thaiopensource.com/ns/locating-rules/1.0">
      <namespace ns="http://www.w3.org/2000/svg" typeId="SVG" />
      <uri pattern="*.svg" typeId="SVG"/>
      <documentElement localName="svg" typeId="SVG"/>
      <typeId id="SVG" uri="svg.rnc"/>
    </locatingRules>
    EOF
    ${jing-trang}/bin/trang ${svgDtd} $out/svg.rnc
  '';

  treeSitterLangs = [
    "c"
    "cmake"
    "cpp"
    "css"
    "dockerfile"
    "go"
    "gomod"
    "html"
    "java"
    "javascript"
    "json"
    "lua"
    "php"
    "python"
    "ruby"
    "rust"
    "toml"
    "tsx"
    "typescript"
    "typst"
    "yaml"
    "zig"
  ];

  patchElpaPackage = package: patches: package.overrideAttrs (old:
    let sourceDir = "${old.pname}-${old.version}"; in {
      src = runCommand "${sourceDir}-patched.tar" { } ''
        mkdir source
        tar -xf ${old.src} -C source
        ${concatMapStringsSep "\n" (patchFile: ''
          patch -d source/${sourceDir} -p1 < ${patchFile}
        '') patches}
        tar --sort=name --mtime=@1 --owner=0 --group=0 --numeric-owner \
          -cf $out -C source ${sourceDir}
      '';
    });

  elpaPatches = {
    eat = [ ./misc/eat-cnl-cpl.patch ];
    typst-ts-mode = [ ./misc/typst-ts-mode-autoload.patch ];
  };

  execPaths = lib.concatStrings (lib.mapAttrsToList
    (k: v: "(\"${k}\" . \"${v}/bin/${k}\")")
    binPkgMap);

  early-default-init = writeText "early-default.el" ''
    (setq flymake-vale-program-args '("--config=${valeConfig}")
          hermetic-executable-paths '(${execPaths}))
    (with-eval-after-load 'rng-loc
      (add-to-list 'rng-schema-locating-files "${svgSchema}/schemas.xml"))
  '';

  baseEmacs = emacs31-pgtk;

  emacsPackages = (emacsPackagesFor baseEmacs).overrideScope
    (_: prev: lib.mapAttrs (k: v: patchElpaPackage prev.${k} v) elpaPatches);

  inherit (emacsPackages) emacsWithPackages;

  emacsWPkgs = emacsWithPackages (epkgs: userLispPkgs epkgs ++ [
    (epkgs.treesit-grammars.with-grammars
      (attrVals (map (l: "tree-sitter-" + l) treeSitterLangs)))
    (epkgs.trivialBuild {
      pname = "emacs-early-default-init";
      version = "0";
      src = early-default-init;
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
          --set FONTCONFIG_FILE ${fontConfig} \
          --set DICTDIR ${hunspellDicts.en_US}/share/hunspell
      done
      ln -s ${emacs}/share $out/share
    '';
in
wrapEmacs emacsWPkgs
