{ elpaBuild
, fetchFromGitHub
, meow
}:
elpaBuild rec {
  pname = "meow-vterm";
  version = "1.0.0";

  packageRequires = [ meow ];

  src = (fetchFromGitHub {
    owner = "accelbread";
    repo = pname;
    rev = version;
    sha256 = "sha256-4o67WtQ2d+DyXD1jHT7S7OLVYwCBbzt3k509EHUBF3g=";
  }) + "/${pname}.el";
}
