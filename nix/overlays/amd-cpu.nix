final: prev: {
  blas = prev.blas.override { blasProvider = final.amd-blis; };
  lapack = prev.lapack.override { lapackProvider = final.amd-libflame; };
}
