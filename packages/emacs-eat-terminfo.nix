{ stdenv
, ncurses
, emacsPackagesFor
, emacs
}:
stdenv.mkDerivation {
  name = "emacs-eat-terminfo";
  src = (emacsPackagesFor emacs).eat.src;
  nativeBuildInputs = [ ncurses ];
  installPhase = ''
    mkdir -p $out/share/terminfo
    tic -x -o $out/share/terminfo eat.ti
  '';
}
