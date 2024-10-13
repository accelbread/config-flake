{ stdenv
, fetchFromGitHub
}:
stdenv.mkDerivation {
  pname = "vale-proselint";
  version = "v0.3.3";
  src = fetchFromGitHub {
    owner = "errata-ai";
    repo = "proselint";
    rev = "f27b5e776bdeeb96adfc53eacfde425bb05e8c7e";
    sha256 = "sha256-ryKJDX1JrvDWVKLC5qQGctweDf74yuwEXxl/IqumM4s=";
  };
  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r proselint $out/
    runHook postInstall
  '';
}
