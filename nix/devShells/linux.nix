pkgs:
let
  inherit (pkgs) lib;
  nixos = pkgs.inputs.nixpkgs.lib.nixosSystem {
    modules = [
      pkgs.moduleArgs.config.propagationModule
      pkgs.outputs.nixosModules.kernel
      { nixpkgs.hostPlatform = { inherit (pkgs) system; }; }
    ];
  };
  inherit (nixos.config.boot.kernelPackages) kernel;
in
{
  inherit (kernel) stdenv;
  inputsFrom = [ kernel ];
  packages = with pkgs; [ b4 pkg-config ncurses ];
} // lib.optionalAttrs kernel.stdenv.cc.isClang {
  env.LLVM = "1";
}
