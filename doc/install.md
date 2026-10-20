## Configure system

- Add nixos config for system.
- Set `services.usbguard.implicitPolicyTarget = "keep"`.
- On x86_64, `boot.lanzaboote.enable = lib.mkForce false`.

From installation media:

```sh
export NIX_CONFIG="extra-experimental-features = nix-command flakes"
nix run .#system -- ${SYSTEM} full-install
```

## Post-install

(with necessary devices plugged in)

```sh
usbguard generate-policy > usbguard-rules.conf
```

Replace `usbguard.implicitPolicyTarget` with `usbguard.rules`.

```sh
run0 sbctl create-keys
```

Remove disabled lanzaboote and rebuild system.

```sh
run0 sbctl verify
```

bzimage not signed is ok.

Reboot.

```sh
run0 sbctl enroll-keys
```

Enable secureboot and check with `bootctl status`.
