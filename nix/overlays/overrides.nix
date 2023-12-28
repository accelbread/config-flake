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
  llama-cpp = prev.llama-cpp.override (old: {
    openblasSupport = !old.config.rocmSupport;
  });
}
