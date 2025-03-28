{ pkgs, lib, inputs, config, ... }:
let
  inherit (lib) mkOption types;
in
{
  imports = with inputs.self.homeModules; [ emacs gui-only-programs ];

  options.nixGL.package = mkOption {
    type = types.package;
    default = pkgs.nixgl.nixGLMesa;
  };

  config = {
    home = {
      packages = with pkgs; [
        (nixgl.nixGLCommon config.nixGL.package)
        man-pages
        man-pages-posix
        glibcInfo
        git
        git-absorb
        git-lfs
        ripgrep
        fd
        tree
        file
        moreutils
        jq
        gnutar
        strace
        parted
        zile
        podman
        gocryptfs
        awscli2
        bind.dnsutils
        bubblewrap
      ];
      file.".fdignore".source = ../../dotfiles/fdignore;
      sessionVariables.CMAKE_EXPORT_COMPILE_COMMANDS = "ON";
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

        HISTCONTROL=ignoreboth

        unset HISTFILE
      '';
      git = {
        userName = "Archit Gupta";
        userEmail = "archit@accelbread.com";
        extraConfig = {
          pull.ff = "only";
          clone.filterSubmodules = true;
          user.useConfigOnly = true;
          advice.detachedHead = false;
          diff = {
            algorithm = "histogram";
            submodule = "log";
            colorMoved = "zebra";
          };
          merge.conflictStyle = "diff3";
          status.submoduleSummary = true;
          init = {
            defaultBranch = "master";
            templateDir = "${../../dotfiles/git-template}";
          };
          remote.pushDefault = "origin";
          checkout.workers = 0;
          commit.verbose = true;
          branch.sort = "-committerdate";
          tag.sort = "version:refname";
          "diff \"lisp\"".xfuncname = "^(\\(def\\S+\\s+\\S+)";
        };
        attributes = [ "*.el diff=lisp" ];
        ignores = [ ".envrc" ];
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
  };
}
