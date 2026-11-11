# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
{
  stdenvNoCC,
  fetchFromGitHub,
  adwaita-icon-theme,
}:
stdenvNoCC.mkDerivation (final: {
  pname = "gnome-accent-directories";
  version = "15";

  src = fetchFromGitHub {
    owner = "taiwbi";
    repo = final.pname;
    rev = "7d96809684632911d2b4c63742a3360aefa20e98";
    hash = "sha256-C8uCmDw9bMWKmbFEhUB0o6HxO7CY5g4wJk06dIaU1zQ=";
  };

  dontBuild = true;

  # TODO: Remove when fixed upstream
  postPatch = ''
    sed \
      -e 's/#438de6/#9141AC/g' \
      -e 's/#62a0ea/#a05bb7/g' \
      -e 's/#a4caee/#c69ed4/g' \
      -e 's/#afd4ff/#ceabda/g' \
      -e 's/#c0d5ea/#ceabda/g' \
      ${adwaita-icon-theme}/share/icons/Adwaita/scalable/places/folder-projects.svg \
      > icons/Adwaita-Purple/scalable/places/folder-projects.svg
  '';

  installPhase = ''
    runHook preInstall

    install -d $out/share/icons/
    cp -r icons/* $out/share/icons/

    runHook postInstall
  '';
})
