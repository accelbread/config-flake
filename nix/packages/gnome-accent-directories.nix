# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
{
  stdenvNoCC,
  fetchFromGitHub,
  adwaita-icon-theme,
}:
stdenvNoCC.mkDerivation (final: {
  pname = "gnome-accent-directories";
  version = "0-unstable-2026-11-13";

  src = fetchFromGitHub {
    owner = "taiwbi";
    repo = final.pname;
    rev = "e77764bdde75144e879474247dd923b20d461a37";
    hash = "sha256-3xmvhAz/OMUGo2DOJSCGUusSHpGZqXVHT95o3wzV58I=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -d $out/share/icons/
    cp -r icons/* $out/share/icons/

    runHook postInstall
  '';
})
