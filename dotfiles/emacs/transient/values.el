((magit-rebase "--autosquash" "--autostash" "--update-refs")
 (magit-fetch "--prune")
 (magit-patch-create "--zero-commit" "--no-signature"))
