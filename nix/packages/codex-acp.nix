{ buildNpmPackage
, codex
, fetchFromGitHub
, lib
, makeWrapper
}:
buildNpmPackage rec {
  pname = "codex-acp";
  version = "1.10.0";

  src = fetchFromGitHub {
    owner = "agentclientprotocol";
    repo = "codex-acp";
    rev = "v${version}";
    hash = "sha256-D8uYd30NRXQYUSBFCi66Oq0iRZXpl8P7nWv2m3+KBig=";
  };

  patches = [ ./misc/codex-acp-remove-bundled-codex.patch ];

  npmDepsHash = "sha256-Rt3CtAK8eVdbehj6Y+BlrLDFRJU2XMiOAFDcfwHzC64=";

  nativeBuildInputs = [ makeWrapper ];

  postFixup = ''
    wrapProgram $out/bin/codex-acp \
      --set-default CODEX_PATH ${lib.getExe codex}
  '';

  meta = {
    description = "ACP adapter for the Codex app server";
    homepage = "https://github.com/agentclientprotocol/codex-acp";
    license = lib.licenses.asl20;
    mainProgram = "codex-acp";
    platforms = lib.platforms.unix;
  };
}
