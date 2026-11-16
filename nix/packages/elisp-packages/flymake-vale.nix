# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
{
  elpaBuild,
  fetchFromGitHub,
  compat,
}:
elpaBuild rec {
  pname = "flymake-vale";
  version = "0-unstable-2026-09-21";

  packageRequires = [ compat ];

  src = fetchFromGitHub {
    owner = "tpeacock19";
    repo = pname;
    rev = "3ae16071d7e1ab7cf4b0d30a731584d65a6d1977";
    sha256 = "sha256-e8KXuKrWLbEqO/kOGz7Ki+dZTK63rKAn0YJGfUy91OE=";
  };

  preInstall = ''
    src=$src/${pname}.el
  '';
}
