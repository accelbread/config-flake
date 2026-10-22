## Configure system

Add nixos config for system.

Build installer ISO (has pre-loaded artifacts):

```sh
nix build .#nixosConfigurations.${SYSTEM}.config.ab.installerImage
```

On target system, configure BIOS settings. Set BIOS password. Clear all secure
boot certs. Launch the ISO and run:

```sh
sudo sysinstall full-install
```

## Post-install

### Secure Boot

Bootloader should install secure boot certs. Afterwards, boot into BIOS settings
and enable secure boot.

Verify secureboot with `bootctl status`.

### USBGuard

Plug in all necessary devices.

```sh
usbguard generate-policy > usbguard-rules.conf
```

Set `services.usbguard.rules`, and rebuild system.

### Tailscale

```sh
run0 tailscale up
```

### SSH keys

```sh
# Plug in host YubiKey.
nix run self#system -- provision-yubikey
# Plug in SSH CA YubiKey too.
run0 nix run self#system -- provision-ssh
```

### Pass

Import the pass gpg key.

```sh
pass git pull
```
