{ stdenv
, fetchFromGitHub
}:
stdenv.mkDerivation {
  pname = "vale-write-good";
  version = "v0.4.0";
  src = fetchFromGitHub {
    owner = "errata-ai";
    repo = "write-good";
    rev = "2d116619b7662d9d59201e8808254e715fc83cc8";
    sha256 = "sha256-A0vuV4BdumbCb14wxiH5Sc9S75Yx8xwQqWzpfi43+ls=";
  };
  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r write-good $out/
    runHook postInstall
  '';
}
