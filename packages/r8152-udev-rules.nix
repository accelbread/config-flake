{ stdenv
, fetchFromGitHub
}:
stdenv.mkDerivation rec {
  pname = "r8152-udev-rules";
  version = "v2.16.3.20221209";
  src = fetchFromGitHub {
    owner = "wget";
    repo = "realtek-r8152-linux";
    rev = version;
    sha256 = "sha256-RaYuprQFbWAy8CtSZOau0Qlo3jtZnE1AhHBgzASopSA=";
  };
  dontBuild = true;
  dontConfigure = true;
  installPhase = ''
    mkdir -p $out/lib/udev/rules.d
    cp 50-usb-realtek-net.rules $out/lib/udev/rules.d/
  '';
}
