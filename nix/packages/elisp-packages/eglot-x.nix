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
    rev = "46bca93291727454dd92567e761a1e2ab5622590";
    sha256 = "sha256-c8NzzK7SOYYDB803Osp3TOymrmwC07+dcvbI4waAfco=";
  }) + "/${pname}.el";
}
