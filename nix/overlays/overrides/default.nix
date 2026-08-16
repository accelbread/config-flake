# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
final: prev: {
  ccacheWrapper = prev.ccacheWrapper.override {
    extraConfig = ''
      export CCACHE_COMPRESS=1
      export CCACHE_SLOPPINESS=random_seed
      export CCACHE_DIR=/var/cache/ccache
      export CCACHE_UMASK=007
    '';
  };
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
  rnote = final.runCommand prev.rnote.name { } ''
    cp -Lr ${prev.rnote} $out
    chmod -R u+w $out
    rm -r $out/share/fonts
  '';
} // builtins.mapAttrs
  (pkg: _: prev.${pkg}.overrideAttrs (old: {
    patches = old.patches or [ ] ++
      (map (p: builtins.path { path = p; })
        (builtins.filter
          (p: builtins.any (e: final.lib.hasSuffix e p) [ ".patch" ".mbx" ])
          (final.lib.filesystem.listFilesRecursive (./patches + "/${pkg}"))));
  }))
  (builtins.readDir ./patches)
