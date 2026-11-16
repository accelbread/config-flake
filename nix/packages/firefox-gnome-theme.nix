# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
{ lib, fetchFromGitHub }:
lib.fix (
  src:
  fetchFromGitHub {
    owner = "rafaelmardojai";
    repo = "firefox-gnome-theme";
    rev = "fdc1af075073f93dc63e43b28a499b2251bcfcc2";
    hash = "sha256-0M5/QfbfHwI7gP+q6IGdidxl5caGXMaEalNj2E2Rxyg=";
    passthru = {
      version = "157.1-unstable-2026-10-19";
      inherit src;
    };
  }
)
