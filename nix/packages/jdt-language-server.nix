{ lib
, stdenv
, fetchzip
, python3
}:
stdenv.mkDerivation rec {
  pname = "jdt-language-server";
  version = "1.28.0";
  timestamp = "202309281329";

  src = fetchzip {
    url = "https://download.eclipse.org/jdtls/milestones/${version}/jdt-language-server-${version}-${timestamp}.tar.gz";
    sha256 = "sha256-Kz8+e/VKc5DeG3SZAn7cuKA0XaAygEHhXN4SvbQTVxQ=";
    stripRoot = false;
  };

  installPhase = ''
    install -Dm444 -t $out/plugins plugins/*
    install -Dm444 -t $out/features features/*
    install -Dm444 -t $out/config_linux config_linux/*
    install -Dm555 -t $out/bin bin/jdtls
    install -Dm444 -t $out/bin bin/jdtls.py
  '';

  buildInputs = [ python3 ];

  meta = with lib; {
    homepage = "https://github.com/eclipse/eclipse.jdt.ls";
    description = "Java language server";
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
    license = licenses.epl20;
  };
}
