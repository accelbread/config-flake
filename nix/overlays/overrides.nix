final: prev:
let
  inherit (builtins) compareVersions;
in
{
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
  clightd = assert compareVersions prev.clightd.version "5.8" < 0;
    prev.clightd.overrideAttrs (old: rec {
      version = "5.8";
      src = prev.fetchFromGitHub {
        owner = "FedeDP";
        repo = "Clightd";
        rev = version;
        sha256 = "sha256-Lmno/TJVCQVNzfpKNZzuDf2OM6w6rbz+zJTr3zVo/CM=";
      };
    });
}
