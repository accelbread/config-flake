# Set nvme/hdd drives to 4k sectors

[See link](https://wiki.archlinux.org/title/Advanced_Format)

`nix shell nixpkgs#nvme-cli -c nvme format ${DISK} -b 4096`

# Configure system

```sh
nix run .#provision_disks -- -n ${MACHINE_NAME} -d ${DISK1} -d ${DISK2} \
    -g ${DISK_SIZE} -s ${SWAP_SIZE}
```

Get networking.hostId from `head -c4 /dev/urandom | od -A none -t x4`
Set drive ids in config

```sh
nixos-install --no-root-passwd --flake .#${MACHINE_NAME}
```
