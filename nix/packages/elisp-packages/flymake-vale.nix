{ trivialBuild
, fetchFromGitHub
}:
trivialBuild {
  pname = "flymake-vale";
  src = fetchFromGitHub {
    owner = "tpeacock19";
    repo = "flymake-vale";
    rev = "27f070b9da6daa1b825d2f06cd3a8ceb4d0c2af8";
    sha256 = "sha256-/qs3BXm4un5FSWOEZ1NoLwGmzIypY/MmYnDpmEnEL+s=";
  };
  postBuild = ''
    emacs -L . --batch -l package --eval \
      '(package-generate-autoloads "flymake-vale" ".")'
  '';
}
