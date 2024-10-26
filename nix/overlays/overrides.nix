final: prev: {
  nut = prev.nut.overrideAttrs (old: {
    postPatch = ">conf/Makefile.am";
    configureFlags = old.configureFlags ++ [
      "--with-drivers=usbhid-ups"
      "--without-dev"
      "--with-user=nut"
      "--with-group=nut"
      "--sysconfdir=/etc/nut"
      "--with-statepath=/var/lib/nut"
    ];
  });
  tpm2-pkcs11 = prev.tpm2-pkcs11.override { fapiSupport = false; };
  bees = prev.bees.overrideAttrs {
    utillinux = final.runCommand final.util-linux.name
      {
        inherit (final.util-linux) meta pname version;
        nativeBuildInputs = [ final.makeBinaryWrapper ];
      } ''
      cp -r ${final.util-linux} $out
      chmod -R u+w $out
      wrapProgram $out/bin/mount --add-flags "-o noatime"
    '';
  };
  amberol = assert builtins.compareVersions prev.gtk4.version "4.16.0" == -1;
    prev.amberol.override (builtins.mapAttrs (k: _: (final.appendOverlays [
      (final: prev: {
        gtk4 = prev.gtk4.overrideAttrs (finalAttrs: prevAttrs: {
          version = "4.16.3";
          src = final.fetchurl {
            url = with finalAttrs;
              "mirror://gnome/sources/gtk/${
            final.lib.versions.majorMinor version}/gtk-${version}.tar.xz";
            hash = "sha256-LsU+B9GMnwA7OeSmqDgFTZJZ4Ei2xMBdgMDQWqch2UQ=";
          };
          nativeBuildInputs = prevAttrs.nativeBuildInputs ++ [ final.docutils ];
        });
      })
    ]).${k}));
}
