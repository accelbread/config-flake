{ pkgs, inputs, ... }: {
  imports = [ ./emacs.nix ];

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
      parted
      zeal
      podman
      direnv
    ];
    file.".fdignore".source = ../../dotfiles/fdignore;
  };

  fonts.fontconfig.enable = true;

  xdg.configFile."direnv/direnvrc".text =
    "source ${pkgs.nix-direnv}/share/nix-direnv/direnvrc";

  programs = builtins.mapAttrs (_: v: { enable = true; } // v) {
    man.generateCaches = true;
    bash.initExtra = ''
      if [[ -z "$LS_COLORS" ]]; then
          eval "$(${pkgs.coreutils}/bin/dircolors -b)"
      fi
    '';
    git = {
      extraConfig = {
        pull.ff = "only";
        user.useConfigOnly = true;
        advice.detachedHead = false;
        init = {
          defaultBranch = "master";
          templateDir = "${../../dotfiles/git-template}";
        };
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
