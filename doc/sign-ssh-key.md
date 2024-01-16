## Sign user key

On host:

```sh
ssh-keygen -D /run/current-system/sw/lib/libtpm2_pkcs11.so \
  | grep ecdsa > tpm2.pub
```

Copy to signing machine.

```sh
ssh-keygen \
  -s /<path-to-flake>/misc/ssh_ca_user_key.pub \
  -D /run/current-system/sw/lib/libtpm2_pkcs11.so \
  -I 'archit@<hostname>' -n archit /<path-to-key>/tpm2.pub
```

Copy `tpm2-cert.pub` to host's `~/.ssh`.

## Sign host key

Copy `/persist/state/sshd/ssh_host_ed25519_key.pub` to signing machine.

```sh
ssh-keygen \
  -s /<path-to-flake>/misc/ssh_ca_host_key.pub \
  -D /run/current-system/sw/lib/libtpm2_pkcs11.so \
  -I <hostname> -h /<path-to-key>/ssh_host_ed25519_key.pub
```

Copy `ssh_host_ed25519_key-cert.pub` to host's `/persist/state/sshd/`.
