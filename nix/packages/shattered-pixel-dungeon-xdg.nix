{ runCommand, writeText, shattered-pixel-dungeon }:
let
  desktopFile = writeText "shattered-pixel-dungeon.desktop" ''
    [Desktop Entry]
    Type=Application
    Version=${shattered-pixel-dungeon.version}
    Name=Shattered Pixel Dungeon
    Comment=An open-source traditional roguelike dungeon crawler
    Icon=shattered-pixel-dungeon
    Exec=${shattered-pixel-dungeon}/bin/shattered-pixel-dungeon
    Terminal=false
    Categories=Game;AdventureGame;
    Keywords=roguelike;dungeon;crawler;
    SingleMainWindow=true
  '';
in
runCommand shattered-pixel-dungeon.name { } ''
  mkdir -p $out/share/applications
  cp ${desktopFile} $out/share/applications/shattered-pixel-dungeon.desktop
  icon_path=${shattered-pixel-dungeon.src}/desktop/src/main/assets/icons
  for s in 16 32 48 64 128 256; do
    mkdir -p $out/share/icons/hicolor/''${s}x$s/apps
    cp $icon_path/icon_$s.png \
      $out/share/icons/hicolor/''${s}x$s/apps/shattered-pixel-dungeon.png
  done
''
