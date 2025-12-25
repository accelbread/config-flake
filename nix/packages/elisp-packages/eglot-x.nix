{ elpaBuild
, fetchFromGitHub
, eglot
}:
elpaBuild rec {
  pname = "eglot-x";
  version = "0.0.1";

  packageRequires = [ eglot ];

  src = (fetchFromGitHub {
    owner = "nemethf";
    repo = pname;
    rev = "b92c44e6b34f8df0539d3c8ab5992c5a7eb815d5";
    sha256 = "sha256-VvamDqZ3NowM6XfRlC2exsM6ssRBqWUw6ziKgqdphwM=";
  }) + "/${pname}.el";
}
