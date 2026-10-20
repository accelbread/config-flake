## Configure system

- Add nixos config for system.

From installation media:

```sh
export NIX_CONFIG="extra-experimental-features = nix-command flakes"
nix run .#system -- ${SYSTEM} full-install
```

## Post-install

### Secure Boot

After first boot, enable Secure Boot in firmware and put it in Setup Mode.

Verify secureboot with `bootctl status`.

### USBGuard

Plug in all necessary devices.

```sh
usbguard generate-policy > usbguard-rules.conf
```

Set `services.usbguard.rules`, and rebuild system.
