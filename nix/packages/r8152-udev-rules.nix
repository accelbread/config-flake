# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
{
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "r8152-udev-rules";
  version = finalAttrs.src.rev;
  src = fetchFromGitHub {
    owner = "wget";
    repo = "realtek-r8152-linux";
    rev = "v2.22.1.20261021";
    sha256 = "sha256-kj3scuUWUFpVZ5ldiLCRwFxsaEt9NM4SfAYb0u8JTEs=";
  };
  dontBuild = true;
  dontConfigure = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/udev/rules.d
    cp 50-usb-realtek-net.rules $out/lib/udev/rules.d/
    runHook postInstall
  '';
})
