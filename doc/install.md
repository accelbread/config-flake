## Set nvme/hdd drives to 4k sectors

[See link](https://wiki.archlinux.org/title/Advanced_Format)

`nix shell nixpkgs#nvme-cli`

Check LBA formats available:

`nvme id-ns -H /dev/nvme0n1`

Format to LBA format #:

`nvme format --lbaf=<#> /dev/nvme0n1`

## Configure system

Add nixos config for system.
Get networking.hostId from `head -c4 /dev/urandom | od -A none -t x4`.
Set `services.usbguard.implictPolicyTarget = "keep"`.
On x86_64, `boot.lanzaboote.enable = lib.mkForce false`.

```sh
export NIX_CONFIG="extra-experimental-features = nix-command flakes"
nix run .#nixosFullInstall -- ${SYSTEM}
```

## Post-install

(with necessary devices plugged in)

```sh
usbguard generate-policy > usbguard-rules.conf
```

Replace `usbguard.implictPolicyTarget` with `usbguard.rules`.

```sh
sudo sbctl create-keys
```

Remove disabled lanzaboote and rebuild system.

```sh
sudo sbctl verify
```

bzimage not signed is ok.

Reboot.

```sh
sudo sbctl enroll-keys
```

Enable secureboot and check with `bootctl status`.
