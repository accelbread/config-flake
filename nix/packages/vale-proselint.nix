{ stdenv
, fetchFromGitHub
}:
stdenv.mkDerivation {
  pname = "vale-proselint";
  version = "v0.3.3";
  src = fetchFromGitHub {
    owner = "errata-ai";
    repo = "proselint";
    rev = "acedc7cb5400c65201ff06382ff0ce064bc338cb";
    sha256 = "sha256-faeWr1bRhnKsycJY89WqnRv8qIowUmz3EQvDyjtl63w=";
  };
  installPhase = ''
    mkdir -p $out
    cp -r proselint $out/
  '';
}
