{ stdenv
, fetchzip
}:
stdenv.mkDerivation {
  name = "noto-fonts-bw-emoji";
  src = fetchzip {
    name = "noto-emoji";
    url = "https://fonts.google.com/download?family=Noto%20Emoji";
    extension = "zip";
    stripRoot = false;
    hash = "sha256-NYWUlDy5D1hP0zAIPWLJJEZWwEXLFiAN2cRm0F52u/s=";
  };
  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/fonts/noto
    cp NotoEmoji-*.ttf $out/share/fonts/noto
    runHook postInstall
  '';
}
