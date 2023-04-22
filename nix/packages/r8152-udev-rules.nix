{ stdenv
, fetchFromGitHub
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "r8152-udev-rules";
  version = finalAttrs.src.rev;
  src = fetchFromGitHub {
    owner = "wget";
    repo = "realtek-r8152-linux";
    rev = "v2.16.3.20221209";
    sha256 = "sha256-RaYuprQFbWAy8CtSZOau0Qlo3jtZnE1AhHBgzASopSA=";
  };
  dontBuild = true;
  dontConfigure = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/udev/rules.d
    cp 50-usb-realtek-net.rules $out/lib/udev/rules.d/
    runHook postInstall
  '';
})
