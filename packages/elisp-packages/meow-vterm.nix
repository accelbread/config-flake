{ elpaBuild
, fetchFromGitHub
, meow
, vterm
}:
elpaBuild rec {
  pname = "meow-vterm";
  version = "1.0.0";

  packageRequires = [ meow vterm ];

  src = (fetchFromGitHub {
    owner = "accelbread";
    repo = pname;
    rev = version;
    sha256 = "sha256-qdR3JnovqDG2mkpeXjOxtjC0ZkBTElxuiOj8qiN/LtY=";
  }) + "/${pname}.el";
}
