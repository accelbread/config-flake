# Partition EFI + crypt and setup luks
mkfs.vfat -S 4096 -n EFI /dev/nvme0n1p1
cryptsetup open /dev/nvme0n1p2 shadowfang_luksunlocked
# Setup LVM on LUKS and create swap lv and root lv
zpool create -f -R /mnt -o ashift=12 -O mountpoint=none -O compression=on -O atime=off -O xattr=sa -O acltype=posixacl -O setuid=off -O devices=off -m none shadowfang /dev/shadowfang_vg/rootvol
zfs snapshot shadowfang/sys/root@blank
mount -t zfs -o noatime shadowfang/sys/root /mnt
mkdir /mnt/boot
mount /dev/nvme0n1p1 -o noatime /mnt/boot
zfs create -p -o mountpoint=legacy shadowfang/sys/nix
mkdir /mnt/nix
mount -t zfs -o noatime shadowfang/sys/nix /mnt/nix
zfs create -p -o mountpoint=legacy shadowfang/data/persist
mkdir /mnt/persist
mount -t zfs -o noatime shadowfang/data/persist /mnt/persist
zfs create -p -o mountpoint=legacy shadowfang/data/home
mkdir -p /mnt/persist/home/archit
mount -t zfs -o noatime shadowfang/data/home /mnt/persist/home/archit
zfs create -o refreservation=50G shadowfang/sys/reserved

# get networking.hostId from `head -c4 /dev/urandom | od -A none -t x4`

nixos-install --no-root-passwd --flake .../config-flake#shadowfang
mkdir /mnt/persist/vault
chmod 600 /mnt/persist/vault
# write password hash to /mnt/persist/vault/user_pass
zfs set com.sun:auto-snapshot=true shadowfang/data/home
