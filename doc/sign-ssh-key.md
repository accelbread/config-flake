## Create user key

With machine YubiKey plugged in:

```sh
ssh-keygen -t ed25519-sk -O verify-required -C 'archit@<hostname>'
```

## Sign user key

With SSH CA YubiKey plugged in:

```sh
ssh-keygen \
  -s /<path-to-flake>/misc/ssh_ca_user_key.pub \
  -D /etc/profiles/per-user/archit/lib/libykcs11.so \
  -I 'archit@<hostname>' -n archit ~/.ssh/id_ed25519_sk.pub
```

After entering pin, tap the Yubikey.

## Create host key

With machine YubiKey plugged in:

```sh
ssh-keygen -t ed25519-sk -O no-touch-required -N '' -C '<hostname>' \
  -f /persist/state/sshd/ssh_host_ed25519_sk_key
```

## Sign host key

With SSH CA YubiKey plugged in:

```sh
ssh-keygen \
  -s /<path-to-flake>/misc/ssh_ca_host_key.pub \
  -D /etc/profiles/per-user/archit/lib/libykcs11.so \
  -I <hostname> \
  -n <hostname>.fluffy-bebop.ts.net \
  -h \
  /persist/state/sshd/ssh_host_ed25519_sk_key.pub
```

After entering pin, tap the Yubikey.
