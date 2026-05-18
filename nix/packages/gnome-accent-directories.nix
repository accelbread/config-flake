{ stdenvNoCC
, fetchFromGitHub
}:
stdenvNoCC.mkDerivation (final: {
  pname = "gnome-accent-directories";
  version = "15";

  src = fetchFromGitHub {
    owner = "taiwbi";
    repo = final.pname;
    rev = "7d96809684632911d2b4c63742a3360aefa20e98";
    hash = "sha256-C8uCmDw9bMWKmbFEhUB0o6HxO7CY5g4wJk06dIaU1zQ=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -d $out/share/icons/
    cp -r icons/* $out/share/icons/

    runHook postInstall
  '';
})
