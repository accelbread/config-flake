{ elpaBuild
, fetchFromGitHub
, meow
}:
elpaBuild rec {
  pname = "meow-term";
  version = "1.0.0";

  packageRequires = [ meow ];

  src = (fetchFromGitHub {
    owner = "accelbread";
    repo = pname;
    rev = version;
    sha256 = "sha256-5lvzid2w1yFbQ/rVRaV3GGmZifAyIRMy/gEeBxVaeJA=";
  }) + "/${pname}.el";
}
