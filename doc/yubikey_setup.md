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

## Set up CA YubiKey

Plug in the YubiKey and ensure its the only plugged in key.

Ensure the PIV feature is enabled (and disable others if not needed):

```sh
ykman info
ykman config usb -d otp -d u2f -d fido2 -d oath -d openpgp -d hsmauth
```

Remove the YubiKey and plug it back in (remove from power not just usb
connection).

```sh
ykman piv reset
ykman piv access change-pin
ykman piv access change-puk
ykman piv access change-management-key -t -a AES256 -g
```

Note above does not have `-p`. We can toss the management key when we are done
and just reset the PIV module if we ever need to change the PIV setup.

Generate the CA keys/certs.

```sh
ykman piv keys generate \
  -a ECCP384 --pin-policy always --touch-policy always 82 ssh_ca_key.pub
ykman piv certificates generate \
  -a sha512 -d 3650 -s "Personal CA" 82 ssh_ca_key.pub
ykman piv info
ssh-keygen -D /etc/profiles/per-user/archit/lib/libykcs11.so
```

Take the corresponding public key from ssh-keygen output and save it in
`misc/ssh_ca_key.pub`.

Generate the X.509 CA cert:

```sh
export OPENSSL_MODULES="$(nix build --no-link --print-out-paths self#libp11.out)/lib/ossl-module"
export PKCS11_MODULE_PATH="$(nix build --no-link --print-out-paths self#yubico-piv-tool.out)/lib/libykcs11.so"

openssl req -new -x509 \
  -provider pkcs11prov -provider default \
  -key 'pkcs11:id=%05;type=private' \
  -subj '/CN=Personal CA' \
  -sha512 -days 3650 \
  -addext 'basicConstraints=critical,CA:TRUE,pathlen:0' \
  -addext 'keyUsage=critical,keyCertSign,cRLSign' \
  -out misc/ca.pem
```

this writes `misc/ca.pem`.
