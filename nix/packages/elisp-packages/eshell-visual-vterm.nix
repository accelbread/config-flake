{ elpaBuild
, fetchFromGitHub
, vterm
, inheritenv
}:
elpaBuild rec {
  pname = "eshell-visual-vterm";
  version = "1.0.0";

  packageRequires = [ vterm inheritenv ];

  src = (fetchFromGitHub {
    owner = "accelbread";
    repo = pname;
    rev = version;
    sha256 = "sha256-iknBspzyp5Bdh9XKiHT/HV0myVhsf0Cd9ZDcgdoQ2lg=";
  }) + "/${pname}.el";
}
