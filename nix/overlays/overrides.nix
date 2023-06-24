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
  linuxPackages_hardened = prev.linuxPackages_hardened.extend (_: lprev: {
    lkrg = lprev.lkrg.overrideAttrs (old:
      let
        systemd-coredump-pkg = final.symlinkJoin { name = "systemd"; paths = [ final.systemd ]; };
      in
      rec {
        version = "0.9.6";
        src = prev.fetchFromGitHub {
          owner = "lkrg-org";
          repo = "lkrg";
          rev = "v${version}";
          sha256 = "sha256-jKiSTab05+6ZZXQDKUVPKGti0E4eZaVuMZJlBKR3zGY=";
        };
        patches = [ ];
        meta = old.meta // { broken = false; };
        prePatch = old.prePatch + ''
          substituteInPlace src/modules/exploit_detection/syscalls/p_call_usermodehelper/p_call_usermodehelper.c \
            --replace \"/bin/false \"${final.coreutils}/bin/false\",\"/run/current-system/sw/bin/false \
            --replace \"/bin/true \"${final.coreutils}/bin/true\",\"/run/current-system/sw/bin/true \
            --replace \"/lib/systemd/systemd-cgroups-agent \"${final.systemd}/lib/systemd/systemd-cgroups-agent \
            --replace \"/lib/systemd/systemd-coredump \"${systemd-coredump-pkg}/lib/systemd/systemd-coredump \
            --replace \"/sbin/bridge-stp \"/run/current-system/sw/bin/bridge-stp \
            --replace \"/sbin/drbdadm \"/run/current-system/sw/bin/drbdadm \
            --replace \"/sbin/modprobe \"${final.kmod}/bin/modprobe \
            --replace \"/sbin/poweroff \"${final.systemd}/sbin/poweroff \
            --replace \"/sbin/request-key \"/run/current-system/sw/bin/request-key \
        '';
      });
  });
  clightd = assert builtins.compareVersions prev.clightd.version "5.8" < 0;
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
