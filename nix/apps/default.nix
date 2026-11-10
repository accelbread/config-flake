# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
{
  lib,
  src,
  nixVersions,
  writeShellScript,
  emacsAccelbread,
  bubblewrap,
  firefox,
  awscli2,
  jq,
  replaceVars,
  ...
}:
let
  inherit (builtins) readFile toJSON;
  inherit (lib) removePrefix removeSuffix;

  nix = ''${nixVersions.latest}/bin/nix --extra-experimental-features "${
    lib.concatStringsSep " " [
      "nix-command"
      "flakes"
      "ca-derivations"
      "pipe-operators"
    ]
  }"'';

  awsStack = replaceVars (src + /aws/stack.yaml) {
    ca =
      src + /misc/ca.pem
      |> readFile
      |> toJSON
      |> removePrefix "\""
      |> removeSuffix "\"";
  };
in
rec {
  default = emacs;
  emacs = writeShellScript "emacsWithConfig" ''
    set -eu
    emacs_dir=$(mktemp -d)
    cleanup() { rm -rf "$emacs_dir"; }
    trap cleanup EXIT
    ${emacsAccelbread}/bin/emacs --init-directory="$emacs_dir" "$@"
  '';

  system = writeShellScript "run-system-action" ''
    set -eu
    if [[ $# -eq 1 ]]; then
      set -- "$(</etc/hostname)" "$1"
    fi
    ref="${src}#nixosConfigurations.$1.config.ab.systemActions.$2"
    ${nix} build --no-link "$ref"
    script=$(${nix} eval --raw "$ref")
    exec $script
  '';

  aws-deploy = writeShellScript "deploy-aws" ''
    exec ${awscli2}/bin/aws cloudformation deploy \
      --region us-west-2 \
      --stack-name personal-infra \
      --template-file ${awsStack} \
      --capabilities CAPABILITY_IAM \
      --no-fail-on-empty-changeset \
      "$@"
  '';
  aws-outputs = writeShellScript "aws-outputs" ''
    set -euo pipefail
    ${awscli2}/bin/aws cloudformation describe-stacks \
      --region us-west-2 \
      --stack-name personal-infra \
      --query 'Stacks[0].Outputs' \
      --output json \
      --no-cli-pager \
      "$@" |
      ${jq}/bin/jq 'map({key: .OutputKey, value: .OutputValue}) | from_entries'
  '';

  firefoxNetworkDns = writeShellScript "firefoxNetworkDns" ''
    exec ${bubblewrap}/bin/bwrap --bind / / --dev-bind /dev /dev \
      --bind /run/NetworkManager/resolv.conf /etc/resolv.conf \
      -- ${firefox}/bin/firefox
  '';
}
