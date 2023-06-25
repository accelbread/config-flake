{ linuxPackages_hardened
, diffutils
, bash
, fetchFromGitHub
, stdenv
}:
stdenv.mkDerivation (self: {
  pname = "lkrg-in-tree";
  version = "0.9.6";
  src = fetchFromGitHub {
    owner = "lkrg-org";
    repo = "lkrg";
    rev = "v${self.version}";
    sha256 = "sha256-jKiSTab05+6ZZXQDKUVPKGti0E4eZaVuMZJlBKR3zGY=";
  };
  buildPhase = ''
    runHook preBuild
    mkdir a
    (cd a; tar -xf ${linuxPackages_hardened.kernel.src} --strip-components=1)
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
