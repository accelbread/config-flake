{ stdenvNoCC
, fetchFromGitHub
}:
stdenvNoCC.mkDerivation (final: {
  pname = "gnome-accent-directories";
  version = "15";

  src = fetchFromGitHub {
    owner = "taiwbi";
    repo = final.pname;
    rev = "f658665b0ced7f16b445a63010ecb5b7705cd805";
    hash = "sha256-uGLQ3DLiqCOBQElURz0bc/Tkn0T+sapWr8QrPKa/HfQ=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -d $out/share/icons/
    cp -r icons/* $out/share/icons/

    runHook postInstall
  '';
})
