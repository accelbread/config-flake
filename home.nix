user:
{ config, pkgs, lib, ... }:
with builtins;
with lib; {
  imports = [ (import ./dconf.nix) ];
  home = {
    username = user.name;
    homeDirectory = user.home;
    stateVersion = "22.05";
    sessionVariables = {
      TPM2_PKCS11_STORE = "$HOME/.local/share/tpm2_pkcs11";
      TSS2_LOG = "fapi+NONE";
    };
    packages = with pkgs; [ aspellDicts.en zeal ];
    file = mapAttrs (name: value: value // { recursive = true; }) {
      ".config".source = ./dotfiles/config;
      ".librewolf".source = ./dotfiles/librewolf;
      ".ssh".source = ./dotfiles/ssh;
    };
  };

  programs = mapAttrs (name: value: value // { enable = true; }) {
    home-manager = { };
    man.generateCaches = true;
    bash.initExtra = ''
      if [[ "$INSIDE_EMACS" = 'vterm' ]] \
          && [[ -n ''${EMACS_VTERM_PATH} ]] \
          && [[ -f ''${EMACS_VTERM_PATH}/etc/emacs-vterm-bash.sh ]]; then
          source ''${EMACS_VTERM_PATH}/etc/emacs-vterm-bash.sh
      fi
      if [[ -z "$LS_COLORS" ]]; then
          eval "$(${pkgs.coreutils}/bin/dircolors -b)"
      fi
    '';
    emacs = {
      package = pkgs.emacsPgtkNativeComp;
      extraPackages = epkgs:
        attrsets.attrVals (map head (filter isList (split "([-a-z]+)" (head
          (match ".*\\(setq package-selected-packages[[:space:]]+'\\(([^)]+).*"
            (readFile ./dotfiles/config/emacs/init.el)))))) epkgs ++ singleton
        (epkgs.trivialBuild {
          pname = "nix-paths";
          src = pkgs.writeText "nix-paths.el" ''
            (setq ispell-program-name "${pkgs.aspell}/bin/aspell"
                  clang-format-executable "${pkgs.clang-tools}/bin/clang-format"
                  rust-rustfmt-bin "${pkgs.rustfmt}/bin/rustfmt"
                  nix-nixfmt-bin "${pkgs.nixfmt}/bin/nixfmt"
                  sh-shellcheck-program "${pkgs.shellcheck}/bin/shellcheck"
                  fish-completion-command "${pkgs.fish}/bin/fish")
            (with-eval-after-load 'eglot
              (setq eglot-server-programs
                    '(((c++-mode c-mode) "${pkgs.clang-tools}/bin/clangd")
                      (rust-mode "${pkgs.rust-analyzer}/bin/rust-analyzer")
                      (zig-mode "${pkgs.zls}/bin/zls")
                      (nix-mode "${pkgs.rnix-lsp}/bin/rnix-lsp"))))
            (provide 'nix-paths)
          '';
        });
    };
    git = {
      extraConfig = {
        pull.ff = "only";
        user.useConfigOnly = true;
      };
      ignores = [ "/.evc" ];
    };
    gpg.homedir = "${config.xdg.dataHome}/gnupg";
    password-store = {
      package = pkgs.pass-wayland.withExtensions (exts: [ exts.pass-otp ]);
      settings = {
        PASSWORD_STORE_CLIP_TIME = "10";
        PASSWORD_STORE_GENERATED_LENGTH = "16";
        PASSWORD_STORE_DIR = "${config.xdg.dataHome}/pass";
        PASSWORD_STORE_SIGNING_KEY = "570BE31ADF804E920FD226321F90781ED8448A79";
      };
    };
    less.keys = ''
      #env
      LESS = -i -R
    '';
    readline = {
      bindings = {
        "\\C-p" = "history-search-backward";
        "\\C-n" = "history-search-forward";
      };
      variables = {
        bell-style = "visible";
        colored-stats = true;
        completion-ignore-case = true;
        completion-prefix-display-length = 4;
        mark-symlinked-directories = true;
        show-all-if-ambiguous = true;
        show-all-if-unmodified = true;
        visible-stats = true;
      };
    };
    mpv.scripts = with pkgs.mpvScripts; [ autoload mpris sponsorblock ];
  };

  services.gpg-agent = {
    enable = true;
    pinentryFlavor = "gnome3";
  };

  xdg.desktopEntries.cups = {
    name = "Manage Printing";
    noDisplay = true;
    exec = null;
  };
}
