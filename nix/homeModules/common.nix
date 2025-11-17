{ pkgs, lib, inputs, config, ... }:
let
  inherit (lib) mkOption types;
in
{
  imports = with inputs.self.homeModules; [ emacs gui-only-programs ];

  options.nixgl.package = mkOption {
    type = types.package;
    default = pkgs.nixgl.nixGLMesa;
  };

  config = {
    home = {
      packages = with pkgs; [
        (nixgl.nixGLCommon config.nixgl.package)
        man-pages
        man-pages-posix
        glibcInfo
        bash.info
        gnumake.info
        gcc_latest.info
        coreutils.info
        binutils.info
        guile.info
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
        gdb
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
      info.enable = true;
      bash.initExtra = ''
        if [[ -z "$LS_COLORS" ]]; then
            eval "$(${pkgs.coreutils}/bin/dircolors -b)"
        fi

        HISTCONTROL=ignoreboth

        unset HISTFILE
      '';
      git = {
        settings = {
          user = {
            name = "Archit Gupta";
            email = "archit@accelbread.com";
          };
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
        attributes = [
          "*.el diff=lisp"
          "*.sh diff=bash"
          "*.md diff=markdown"
          "*.tex diff=tex"
          "*.ini diff=ini"
          "*.c diff=cpp"
          "*.h diff=cpp"
          "*.cpp diff=cpp"
          "*.cxx diff=cpp"
          "*.cc diff=cpp"
          "*.c++ diff=cpp"
          "*.hpp diff=cpp"
          "*.hxx diff=cpp"
          "*.hh diff=cpp"
          "*.h++ diff=cpp"
          "*.rs diff=rust"
          "*.py diff=python"
          "*.scm diff=scheme"
          "*.css diff=css"
          "*.html diff=html"
          "*.java diff=java"
          "*.kt diff=kotlin"
          "*.go diff=golang"
        ];
        ignores = [ ".envrc" ];
      };
      less.config = ''
        #env
        LESS = -i -R
      '';
      readline = {
        bindings = {
          "\\C-p" = "history-search-backward";
          "\\C-n" = "history-search-forward";
        };
        variables = {
          bell-style = "audible";
          colored-stats = true;
          completion-ignore-case = true;
          completion-map-case = true;
          completion-prefix-display-length = 4;
          show-all-if-ambiguous = true;
          show-all-if-unmodified = true;
          visible-stats = true;
        };
      };
    };
  };
}
