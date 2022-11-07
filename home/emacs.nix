{ pkgs, ... }:
let
  self = ../.;
in
{
  home = {
    packages = with pkgs; [
      emacsAccelbread
      emacsAccelbread-terminfo
      aspellDicts.en
      noto-fonts-bw-emoji
    ];
    file.".config/emacs" = {
      source = self + /dotfiles/emacs;
      recursive = true;
    };
  };

  programs = {
    bash.initExtra = ''
      if [[ "$INSIDE_EMACS" = 'vterm' ]] \
          && [[ -n "$EMACS_VTERM_PATH" ]] \
          && [[ -f "$EMACS_VTERM_PATH/etc/emacs-vterm-bash.sh" ]]; then
          source "$EMACS_VTERM_PATH/etc/emacs-vterm-bash.sh"
      fi
    '';
    zsh.initExtra = ''
      if [[ "$INSIDE_EMACS" = 'vterm' ]] \
          && [[ -n "$EMACS_VTERM_PATH" ]] \
          && [[ -f "$EMACS_VTERM_PATH/etc/emacs-vterm-zsh.sh" ]]; then
          source "$EMACS_VTERM_PATH/etc/emacs-vterm-zsh.sh"
      fi
    '';
    git.ignores = [ "/.evc" ".direnv" ];
  };

  xdg.desktopEntries = builtins.foldl'
    (a: v: a // {
      ${v} = { name = ""; exec = null; settings.Hidden = "true"; };
    })
    { }
    [ "emacsclient" "emacs-mail" "emacsclient-mail" ]
  // {
    emacs = {
      name = "Emacs";
      mimeType = [ "text/english" "text/plain" ];
      exec = "emacsclient -ca \"\" %F";
      icon = "emacs";
      startupNotify = true;
      settings.StartupWMClass = "Emacs";
      actions.new-instance = {
        name = "New Instance";
        exec = "emacs %F";
      };
    };
  };
}
