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
  amberol = prev.amberol.overrideAttrs (old: {
    patches = old.patches or [ ] ++ [
      ./patches/amberol/disable_cover_caching.patch
    ];
  });
}
