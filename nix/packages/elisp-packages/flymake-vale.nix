{ elpaBuild
, fetchFromGitHub
, compat
}:
elpaBuild rec {
  pname = "flymake-vale";
  version = "0.0.1";

  packageRequires = [ compat ];

  src = (fetchFromGitHub {
    owner = "tpeacock19";
    repo = pname;
    rev = "28d4a675ed8a186b4f3d2c3613e2eeb0d97f090c";
    sha256 = "sha256-s+FI4rznhtyRg3swdxS/ZZXWdkAToNIG3p6xIfW2yCw=";
  }) + "/${pname}.el";
}
