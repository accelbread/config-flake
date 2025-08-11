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
  colord = prev.colord.overrideAttrs (old: assert old.version == "1.4.6"; rec {
    version = "1.4.8";
    src = final.fetchFromGitHub {
      owner = "hughsie";
      repo = "colord";
      tag = version;
      hash = "sha256-tYA8AP1/LVO/oC/aXZ29O5JgQ9eAk6R9Jvnghw2xak8=";
    };
    mesonFlags = old.mesonFlags ++ [
      "-Dsystemd_root_prefix=${placeholder "out"}"
    ];
  });
}
