final: prev: {
  gnome-keyring = prev.gnome-keyring.overrideAttrs (old: {
    mesonFlags = final.lib.remove "-Dssh-agent=true" old.mesonFlags;
  });
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
      ./patches/amberol/shuffle_all.patch
    ];
  });
}
