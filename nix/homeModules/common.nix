{ pkgs, ... }: {
  imports = [ ./emacs.nix ./gui-only-programs.nix ];

  home = {
    sessionVariables = {
      TPM2_PKCS11_STORE = "$HOME/.local/share/tpm2_pkcs11";
      TSS2_LOG = "fapi+NONE";
    };
    packages = with pkgs; [
      man-pages
      man-pages-posix
      git
      git-absorb
      ripgrep
      fd
      tree
      moreutils
      jq
      gnutar
      strace
      parted
      zile
      podman
    ];
    gui-packages = with pkgs; [ zeal ];
    file.".fdignore".source = ../../dotfiles/fdignore;
  };

  fonts.fontconfig.enable = true;

  xdg.configFile."direnv/direnvrc".text =
    "source ${pkgs.nix-direnv}/share/nix-direnv/direnvrc";

  programs = builtins.mapAttrs (_: v: { enable = true; } // v) {
    man.generateCaches = true;
    bash = {
      initExtra = ''
        if [[ -z "$LS_COLORS" ]]; then
            eval "$(${pkgs.coreutils}/bin/dircolors -b)"
        fi

        HISTCONTROL=ignoreboth
      '';
      profileExtra = ''
        export CMAKE_EXPORT_COMPILE_COMMANDS=ON
      '';
    };
    git = {
      extraConfig = {
        pull.ff = "only";
        user.useConfigOnly = true;
        advice.detachedHead = false;
        diff.algorithm = "histogram";
        init = {
          defaultBranch = "master";
          templateDir = "${../../dotfiles/git-template}";
        };
        checkout.workers = 0;
        "diff \"lisp\"".xfuncname = "^(\\(def\\S+\\s+\\S+)";
      };
      attributes = [ "*.el diff=lisp" ];
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
  };
}
