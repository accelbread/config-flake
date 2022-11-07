{ elpaBuild
, fetchFromGitHub
}:
elpaBuild rec {
  pname = "flymake-vale";
  version = "0.0.1";

  src = (fetchFromGitHub {
    owner = "tpeacock19";
    repo = pname;
    rev = "27f070b9da6daa1b825d2f06cd3a8ceb4d0c2af8";
    sha256 = "sha256-/qs3BXm4un5FSWOEZ1NoLwGmzIypY/MmYnDpmEnEL+s=";
  }) + "/${pname}.el";
}
