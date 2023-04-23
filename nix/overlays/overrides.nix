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
  gnomeExtensions = prev.gnomeExtensions // {
    "espresso" =
      let
        uuid = "espresso@coadmunkee.github.com";
      in
      final.stdenv.mkDerivation rec {
        pname = "gnome-shell-extension-espresso";
        version = "git";
        src = prev.fetchFromGitHub {
          owner = "coadmunkee";
          repo = "gnome-shell-extension-espresso";
          rev = "8dfb8df2671fcf2052c0cb4533dd5de783a00afe";
          sha256 = "sha256-6VIXeCFFXQxqrfLQuPOZli8h8vITiTKdhE+tQg/J3Os=";
        };
        nativeBuildInputs = with final; [ gettext glib ];
        buildPhase = ''
          ${final.runtimeShell} ./update-locale.sh
          glib-compile-schemas --strict \
            --targetdir=espresso@coadmunkee.github.com/schemas/ \
            espresso@coadmunkee.github.com/schemas
        '';
        installPhase = ''
          runHook preInstall
          mkdir -p $out/share/gnome-shell/extensions
          cp -r ${uuid} $out/share/gnome-shell/extensions/
          runHook postInstall
        '';
        passthru = {
          extensionPortalSlug = pname;
          extensionUuid = uuid;
        };
      };
  };
}
