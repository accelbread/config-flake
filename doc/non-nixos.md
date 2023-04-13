## Home-manager on non-nixos

Install `nscd` on host system!

In .profile add:

```sh
export XDG_DATA_DIRS="$HOME/.nix-profile/share:$XDG_DATA_DIRS"
```
