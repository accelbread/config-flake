#!/usr/bin/env bash
set -euo pipefail

# TODO: Add tests to ensure tpm2-pkcs11 output format does not change

if ! tpm2_ptool listprimaries | grep "id: 1" >/dev/null; then
  tpm2_ptool init
fi

if ! tpm2_ptool listtokens --pid 1 | grep "label: ssh" >/dev/null; then
  sopin=$(head -c 15 /dev/urandom | base64)
  userpin=changeme
  tpm2_ptool addtoken --pid=1 --label=ssh --userpin="$userpin" --sopin="$sopin"
  tpm2_ptool addkey --label=ssh --userpin="$userpin" --algorithm=ecc256
  tpm2_ptool addkey --label=ssh --userpin="$userpin" --algorithm=rsa2048
fi
