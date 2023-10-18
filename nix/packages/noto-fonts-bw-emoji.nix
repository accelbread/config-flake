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
    hash = "sha256-uP355Zg3+zDfbjRdqN3VHGBkXKjtJseicTX+4CcxWUc=";
  };
  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/fonts/noto
    cp NotoEmoji-*.ttf $out/share/fonts/noto
    runHook postInstall
  '';
}
