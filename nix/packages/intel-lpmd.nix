{ lib
, stdenv
, fetchFromGitHub
, autoreconfHook
, pkg-config
, gtk-doc
, glib
, libxml2
, libnl
, systemd
, upower
, coreutils
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "intel-lpmd";
  version = lib.substring 1 (-1) finalAttrs.src.rev;
  src = fetchFromGitHub {
    owner = "intel";
    repo = "intel-lpmd";
    rev = "v0.1.0";
    hash = "sha256-eZBgWpR2tdSDeqYV4Y2h2j5UeJebQg2tXlXcUywwZEA=";
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
