## Set up host YubiKey

Plug in the YubiKey and ensure its the only plugged in key.

Disable features other than u2f/fido2 and set fido pin:

```sh
ykman info
ykman config usb -d otp -d oath -d piv -d openpgp -d hsmauth
ykman fido access change-pin
```

## Main YubiKey PIV setup

Set non-default PIV pin/key. Default pin is 123456

```sh
ykman piv access change-pin
ykman piv access change-puk
ykman piv access change-management-key -p -t -a AES256 -g
```

Create PIV keys.

```sh
ykman piv keys generate \
  -a ECCP384 --pin-policy always --touch-policy always 82 key.pub
ykman piv certificates generate \
  -a sha512 -d 365 -s "ssh key" 82 key.pub
ykman piv keys generate \
  -a RSA2048 --pin-policy always --touch-policy always 83 key.pub
ykman piv certificates generate \
  -a sha512 -d 365 -s "ssh key" 83 key.pub
ssh-keygen -D /etc/profiles/per-user/archit/lib/libykcs11.so
```

## Set up SSH CA YubiKey

Plug in the YubiKey and ensure its the only plugged in key.

Ensure the PIV feature is enabled (and disable others if not needed):

```sh
ykman info
ykman config usb -d otp -d u2f -d fido2 -d oath -d openpgp -d hsmauth
```

Remove the YubiKey and plug it back in (remove from power not just usb
connection).

Set non-default pin/key. Default pin is 123456 and puk is 12345678

```sh
ykman piv access change-pin
ykman piv access change-puk
ykman piv access change-management-key -t -a AES256 -g
```

Note above does not have `-p`. We can toss the management key when we are done
and just reset the PIV module if we ever need to change the PIV setup.

Generate the CA keys/certs.

```sh
ykman piv keys generate \
  -a ECCP384 --pin-policy always --touch-policy always 82 host.pub
ykman piv certificates generate \
  -a sha512 -d 3650 -s "SSH host CA" 82 host.pub
ykman piv keys generate \
  -a ECCP384 --pin-policy always --touch-policy always 83 user.pub
ykman piv certificates generate \
  -a sha512 -d 3650 -s "SSH user CA" 83 user.pub
ykman piv info
ssh-keygen -D /etc/profiles/per-user/archit/lib/libykcs11.so
```

Take the corresponding public keys from ssh-keygen output and save them in
`misc/ssh_ca_host_key.pub` and `misc/ssh_ca_user_key.pub`.
