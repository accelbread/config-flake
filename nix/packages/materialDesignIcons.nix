# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
{ lib, fetchFromGitHub }:
lib.fix (
  src:
  fetchFromGitHub {
    owner = "Templarian";
    repo = "MaterialDesign";
    rev = "2424e748e0cc63ab7b9c095a099b9fe239b737c0";
    hash = "sha256-QMGl7soAhErrrnY3aKOZpt49yebkSNzy10p/v5OaqQ0=";
    passthru = {
      version = "0-unstable-2025-01-20";
      inherit src;
    };
  }
)
