{ stdenv
, python3
, fetchFromGitHub
}:
stdenv.mkDerivation (self: {
  pname = "gnome-pass-search-provider";
  version = "1.3.0";
  src = fetchFromGitHub {
    owner = "jle64";
    repo = self.pname;
    rev = self.version;
    hash = "sha256-Ukr1PRjnzWNfoensP1VVfjMSZF2jt90pZs1M1m5E6G4=";
  };
  buildInputs = [
    (python3.withPackages (ps: [
      ps.dbus-python
      ps.pygobject3
      ps.thefuzz
    ]))
  ];
  installPhase = ''
    install -Dm0755 -t $out/libexec/gnome-pass-search-provider \
      gnome-pass-search-provider.py
    install -Dm0644 -t $out/share/gnome-shell/search-providers/ \
      conf/org.gnome.Pass.SearchProvider.ini
    install -Dm0644 -t $out/share/applications \
      conf/org.gnome.Pass.SearchProvider.desktop
    sed -i "s|/usr/lib|$out/libexec|" \
      conf/org.gnome.Pass.SearchProvider.service.dbus \
      conf/org.gnome.Pass.SearchProvider.service.systemd
    install -Dm0644 conf/org.gnome.Pass.SearchProvider.service.dbus \
      $out/share/dbus-1/services/org.gnome.Pass.SearchProvider.service
    install -Dm0644 conf/org.gnome.Pass.SearchProvider.service.systemd \
      $out/share/systemd/user/org.gnome.Pass.SearchProvider.service
  '';
})
