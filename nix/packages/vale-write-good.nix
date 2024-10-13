{ stdenv
, fetchFromGitHub
}:
stdenv.mkDerivation {
  pname = "vale-write-good";
  version = "v0.4.0";
  src = fetchFromGitHub {
    owner = "errata-ai";
    repo = "write-good";
    rev = "90c06e68dc5b6dddbc06c5961d94ba56a96b60d4";
    sha256 = "sha256-W/eHlXklAVlAnY8nLPi/SIKsg8UUnH8UkH99BDo5yKk=";
  };
  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r write-good $out/
    runHook postInstall
  '';
}
