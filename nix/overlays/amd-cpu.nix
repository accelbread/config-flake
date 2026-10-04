# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
final: prev: {
  blas = prev.blas.override { blasProvider = final.amd-blis; };
  lapack = prev.lapack.override { lapackProvider = final.amd-libflame; };
}
