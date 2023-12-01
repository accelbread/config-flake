{ config, pkgs, lib, inputs, ... }:
let
  inherit (builtins) mapAttrs;
in
{
  imports = [ inputs.self.homeModules.common ];

  nixpkgs.overlays = with inputs; [
    self.overlays.overrides
    emacs-overlay.overlays.package
    nixgl.overlays.default
    self.overlays.default
  ];

  nix = {
    package = pkgs.nix;
    registry = mapAttrs (_: v: { flake = v; }) inputs;
    settings.experimental-features = "nix-command flakes";
  };

  home = {
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    packages = with pkgs; [
      dejavu_fonts
      liberation_ttf
      noto-fonts
      noto-fonts-extra
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-emoji
    ];
    sessionVariables = {
      XDG_DATA_DIRS = "$HOME/.nix-profile/share:$XDG_DATA_DIRS";
      TERMINFO_DIRS = "$HOME/.nix-profile/share/terminfo:$TERMINFO_DIRS";
      ASPELL_CONF = "dict-dir $HOME/.nix-profile/lib/aspell";
      EDITOR = "zile";
    };
  };

  programs.home-manager.enable = true;
}
