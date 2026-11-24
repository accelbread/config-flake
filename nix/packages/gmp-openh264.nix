# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
{
  lib,
  stdenv,
  firefox-esr-unwrapped,
  openh264,
  nasm,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "gmp-openh264";
  inherit (openh264) version src;

  nativeBuildInputs = [ nasm ];
  strictDeps = true;
  enableParallelBuilding = true;

  postUnpack = ''
    tar -xf ${firefox-esr-unwrapped.src} -C "$sourceRoot" \
      --strip-components=4 --wildcards '*/dom/media/gmp/gmp-api/*.h'
  '';

  postPatch = ''
    substituteInPlace module/gmp-openh264.cpp \
      --replace-fail '#include <string>' $'#include <string>\n#include <vector>'
  '';

  buildFlags = [ "plugin" ];

  installPhase = ''
    runHook preInstall
    install -Dm755 libgmpopenh264.so \
      "$out/lib/gmp-gmpopenh264/${finalAttrs.version}/libgmpopenh264.so"
    install -m644 gmpopenh264.info \
      "$out/lib/gmp-gmpopenh264/${finalAttrs.version}/gmpopenh264.info"
    runHook postInstall
  '';

  meta = {
    description = "OpenH264 Gecko Media Plugin";
    homepage = "https://www.openh264.org";
    license = lib.licenses.bsd2;
    platforms = lib.platforms.linux;
  };
})
