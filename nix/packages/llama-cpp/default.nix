{ lib
, cmake
, fetchFromGitHub
, stdenv
, rocmPackages
, pkg-config
, ninja
, git
}:

let
  inherit (lib) cmakeBool cmakeFeature;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "llama-cpp";
  version = "3046";

  src = fetchFromGitHub {
    owner = "ggerganov";
    repo = "llama.cpp";
    rev = "refs/tags/b${finalAttrs.version}";
    hash = "sha256-jD5x2hXJZr249Gj2fKBAcXUWOGYbVXCdf/r9AG109xA=";
    leaveDotGit = true;
    postFetch = ''
      git -C "$out" rev-parse --short HEAD > $out/COMMIT
      find "$out" -name .git -print0 | xargs -0 rm -rf
    '';
  };

  patches = [ ./0001-sampling-defaults.patch ];

  postPatch = ''
    substituteInPlace ./scripts/build-info.cmake \
      --replace-fail 'set(BUILD_NUMBER 0)' \
      'set(BUILD_NUMBER ${finalAttrs.version})' \
      --replace-fail 'set(BUILD_COMMIT "unknown")' \
      "set(BUILD_COMMIT \"$(cat COMMIT)\")"
  '';

  nativeBuildInputs = [ cmake ninja pkg-config git ];

  buildInputs = with rocmPackages; [ clr hipblas rocblas ];

  cmakeFlags = [
    (cmakeBool "LLAMA_NATIVE" false)
    (cmakeBool "LLAMA_LTO" true)
    (cmakeBool "LLAMA_HIPBLAS" true)
    (cmakeBool "LLAMA_BUILD_TESTS" false)
    (cmakeBool "LLAMA_BUILD_SERVER" true)
    (cmakeFeature "CMAKE_C_COMPILER" "hipcc")
    (cmakeFeature "CMAKE_CXX_COMPILER" "hipcc")
    "-DAMDGPU_TARGETS=gfx1100"
  ];

  meta = with lib; {
    description = "Port of Facebook's LLaMA model in C/C++";
    homepage = "https://github.com/ggerganov/llama.cpp/";
    license = licenses.mit;
    mainProgram = "main";
    platforms = platforms.unix;
  };
})
