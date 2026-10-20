# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  pkg-config,
  gtk-doc,
  glib,
  libxml2,
  libnl,
  systemd,
  upower,
  coreutils,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "intel-lpmd";
  version = "0.1.1-git";
  src = fetchFromGitHub {
    owner = "intel";
    repo = "intel-lpmd";
    rev = "9bf8b8de3ed11c301817814fef79b3161e6294b6";
    hash = "sha256-mCR7ZGk79Hnl2zp8ywHSbi5Fk1ofNfsDt2joF61aHko=";
  };
  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    gtk-doc
  ];
  buildInputs = [
    glib
    libxml2
    libnl
    systemd
    upower
  ];
  postPatch = ''
    substituteInPlace data/org.freedesktop.intel_lpmd.service.in \
      --replace-fail /bin/false ${coreutils}/bin/false
    substituteInPlace data/Makefile.am \
      --replace-fail 'lpmd_configdir = $(lpmd_confdir)' \
      'lpmd_configdir = ${placeholder "out"}/etc/intel_lpmd'
  '';
  configureFlags = [
    "--with-dbus-sys-dir=${placeholder "out"}/share/dbus-1/system.d"
    "--with-systemdsystemunitdir=${placeholder "out"}/lib/systemd/system"
    "--localstatedir=/var"
    "--sysconfdir=/etc"
  ];
})
