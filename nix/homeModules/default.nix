{
  default = import ./non-nixos.nix;
  emacs = import ./emacs.nix;
  gui-only-programs = import ./gui-only-programs.nix;
}
