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
  tpm2-pkcs11 = prev.tpm2-pkcs11.overrideAttrs (old: {
    configureFlags = old.configureFlags or [ ] ++ [ "--enable-fapi=no" ];
  });
  lkl = prev.lkl.overrideAttrs (old: {
    postFixup = ''
      ln -s $out/bin/lklfuse $out/bin/mount.fuse.lklfuse
    '';
  });
}
