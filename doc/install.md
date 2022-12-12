## Set nvme/hdd drives to 4k sectors

[See link](https://wiki.archlinux.org/title/Advanced_Format)

`nix shell nixpkgs#nvme-cli -c nvme format ${DISK} -b 4096`

## Configure system

```sh
blkdiscard ${disk} # trim ssd devices
nix run .#provision-disks -- -n ${MACHINE_NAME} -d ${DISK1} -d ${DISK2} \
    -g ${DISK_SIZE} -s ${SWAP_SIZE}
```

Get networking.hostId from `head -c4 /dev/urandom | od -A none -t x4`.
Set drive ids in config.
Set `services.usbguard.implictPolicyTarget` to `"keep"`.

```sh
nixos-install --no-root-passwd --flake .#${MACHINE_NAME}
```

## Post-install

(as root, with necessary devices plugged in)
```sh
usbguard generate-policy > /var/lib/usbguard/rules.conf
```

Unset `services.usbguard.implictPolicyTarget`.
