{ stdenv
, ncurses
}:
stdenv.mkDerivation {
  name = "emacsAccelbread-terminfo";
  dontUnpack = true;
  nativeBuildInputs = [ ncurses ];
  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/terminfo
    tic -x -o $out/share/terminfo ${../../misc/dumb-emacs-ansi.ti}
    runHook postInstall
  '';
}
