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
    sha256 = "sha256-q7WpqAhmio2ecNGOI7eX7zFBicrsvX8bURF02Pru2rM=";
  };
  installPhase = ''
    mkdir -p $out/share/fonts/noto
    cp NotoEmoji-*.ttf $out/share/fonts/noto
  '';
}
