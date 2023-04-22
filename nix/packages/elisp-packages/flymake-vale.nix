{ elpaBuild
, fetchFromGitHub
}:
elpaBuild rec {
  pname = "flymake-vale";
  version = "0.0.1";

  src = (fetchFromGitHub {
    owner = "tpeacock19";
    repo = pname;
    rev = "914f30177dec0310d1ecab1fb798f2b70a018f24";
    sha256 = "sha256-csg8FvHFgP30laXOQr+TPDUBqbvgcLPJ+QDThF34Jbo=";
  }) + "/${pname}.el";
}
