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
  python3 = prev.python3.override {
    packageOverrides = _: prev: {
      # TODO: Remove when fixed in nixpkgs
      tpm2-pytss = prev.tpm2-pytss.overridePythonAttrs {
        hardeningDisable = [ "fortify" ];
      };
    };
  };
}
