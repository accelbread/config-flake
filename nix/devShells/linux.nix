{ mkShell
, stdenv
, ncurses
, flex
, bison
}:
mkShell {
  packages = [ stdenv ncurses flex bison ];
}
