{ linuxPackages
, kernel-src ? linuxPackages.kernel.src
, diffutils
, bash
, fetchFromGitHub
, stdenv
}:
stdenv.mkDerivation (self: {
  pname = "lkrg-in-tree";
  version = "1.0.0";
  src = fetchFromGitHub {
    owner = "lkrg-org";
    repo = "lkrg";
    rev = "v${self.version}";
    hash = "sha256-Eb0+rgbI+gbY1NjVyPLB6kZgDsYoSCxjy162GophiMI=";
  };
  buildPhase = ''
    runHook preBuild
    mkdir a
    (cd a; tar -xf ${kernel-src} --strip-components=1)
    cp -r a b
    export KDIR=$(pwd)/b
    echo "y" | ${bash}/bin/bash ./scripts/copy-builtin.sh
    runHook postBuild
  '';
  installPhase = ''
    runHook preInstall
    set +e
    ${diffutils}/bin/diff -ruN a/ b/ > $out
    set -e
    runHook postInstall
  '';
})
