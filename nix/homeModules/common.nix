{ pkgs, inputs, ... }: {
  imports = with inputs.self.homeModules; [
    emacs
    gui-only-programs
    rnnoise
  ];

  home = {
    packages = with pkgs; [
      man-pages
      man-pages-posix
      glibcInfo
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
        merge.conflictStyle = "diff3";
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

  services.rnnoise.enable = true;
}
